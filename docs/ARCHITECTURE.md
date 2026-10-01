# Architecture overview

This repository is a curated, sanitized snapshot of a production service marketplace.

## Client application

The Flutter application separates authentication, role selection, profile/onboarding, screens, domain models and Firebase-backed services. A single account can hold both Client and Professional roles and switch the active role.

## Marketplace workflow

A typical job moves through a state machine similar to:

`open → assigned → payment_held → in_progress → work_completed_waiting_confirmation → completed`

Alternative terminal / exception states include `cancelled` and `disputed`.

Professionals can submit and update quotes. Once a quote is accepted, the selected professional becomes associated with the job and other offers can be rejected. Chat and notifications are tied to the job workflow.

## Payments

The production backend uses Firebase Cloud Functions and Stripe Connect. Server credentials are loaded from Firebase Secret Manager rather than committed to source control. The public backend sample demonstrates checkout/session creation, webhook validation and release-state handling without production account identifiers or keys.

## Notifications

Firestore notification records provide an in-app inbox and unread count. Firebase Cloud Messaging tokens are maintained per user, while backend triggers can generate push/in-app notifications when job state changes.

## Internationalization

The production application supports Romania and the United Kingdom with country-aware phone prefixes, currencies and localized content. The public snapshot keeps the country/currency architecture while removing production infrastructure identifiers.

## Sanitization boundary

The following are intentionally outside this repository: production Firebase files, Apple private keys, Android signing material, user/auth exports, production service identifiers, store/build artifacts, large locality datasets and secrets.
