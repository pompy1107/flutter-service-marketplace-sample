# Sanitization manifest

The source application was reviewed before this public portfolio snapshot was created.

## Removed
- Apple private authentication/signing key files
- Firebase Authentication user exports
- Android/iOS production Firebase configuration files
- signing keystores and local key-property files
- IDE caches, build output and generated workspace state
- large production-only datasets and archives

## Replaced
- Firebase project/app identifiers → environment placeholders
- Google Maps / Places keys → environment placeholders
- production callback/service URLs → example URLs or callable-function names
- server payment credentials → Firebase Secret Manager references

## Retained
- Flutter architecture and role-aware workflows
- Firestore service patterns
- job lifecycle / offer logic
- chat and notification patterns
- multi-country / multi-currency design
- Firebase Functions + Stripe Connect architecture sample

The production repository and its Git history are not part of this public repository.
