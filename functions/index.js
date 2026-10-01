const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const Stripe = require('stripe');

admin.initializeApp();
const db = admin.firestore();

// Production uses Firebase secret management. No secret values are committed.
const stripeSecret = defineSecret('STRIPE_SECRET_KEY');
const stripeWebhookSecret = defineSecret('STRIPE_WEBHOOK_SECRET');

function stripeClient() {
  return new Stripe(stripeSecret.value());
}

exports.createClientCheckoutSession = onCall({ secrets: [stripeSecret] }, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication required.');
  const jobId = request.data?.jobId;
  if (!jobId) throw new HttpsError('invalid-argument', 'jobId is required.');

  const jobRef = db.collection('jobs').doc(jobId);
  const snap = await jobRef.get();
  const job = snap.data();
  if (!job) throw new HttpsError('not-found', 'Job not found.');
  if (job.client_id !== request.auth.uid) throw new HttpsError('permission-denied', 'Not your job.');

  const amount = Math.round(Number(job.agreed_price || 0) * 100);
  const currency = String(job.currencyCode || 'RON').toLowerCase();
  const stripe = stripeClient();

  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    line_items: [{ price_data: { currency, unit_amount: amount, product_data: { name: 'Marketplace service' } }, quantity: 1 }],
    success_url: 'https://example.com/payment/success',
    cancel_url: 'https://example.com/payment/cancel',
    metadata: { jobId, clientId: request.auth.uid },
  });

  await jobRef.set({ payment_status: 'checkout_created', checkoutSessionId: session.id }, { merge: true });
  return { url: session.url };
});

exports.releasePaymentToMeserias = onCall({ secrets: [stripeSecret] }, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication required.');
  const jobId = request.data?.jobId;
  const jobRef = db.collection('jobs').doc(jobId);
  const snap = await jobRef.get();
  const job = snap.data();
  if (!job) throw new HttpsError('not-found', 'Job not found.');

  // Production version validates payment state, connected-account status,
  // fees and transfer amounts before creating the transfer.
  await jobRef.set({ payment_status: 'release_requested', releaseRequestedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  return { ok: true };
});

exports.stripeWebhook = onRequest({ secrets: [stripeSecret, stripeWebhookSecret] }, async (req, res) => {
  const stripe = stripeClient();
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, req.headers['stripe-signature'], stripeWebhookSecret.value());
  } catch (err) {
    res.status(400).send('Invalid signature');
    return;
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const jobId = session.metadata?.jobId;
    if (jobId) {
      await db.collection('jobs').doc(jobId).set({
        payment_status: 'held',
        status: 'payment_held',
        paymentIntentId: session.payment_intent,
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
  }
  res.status(200).send('ok');
});

exports.notifyOnJobUpdated = require('firebase-functions/v2/firestore').onDocumentUpdated('jobs/{jobId}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === after.status) return;
  const recipients = [after.client_id, after.meserias_id].filter(Boolean);
  for (const userId of recipients) {
    await db.collection('notifications').add({
      user_id: userId,
      title: 'Job updated',
      body: `Status changed to ${after.status}`,
      type: 'job_status_changed',
      jobId: event.params.jobId,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
});
