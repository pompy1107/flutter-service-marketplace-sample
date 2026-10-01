# Security note

This repository is a sanitized portfolio snapshot derived from a production application.

Production API keys, Apple private keys, signing credentials, Firebase configuration files, user exports, tokens and production-only infrastructure configuration are intentionally excluded.

The repository must never contain:
- `users.json` or other user exports
- Apple `.p8` private keys
- Android signing keys / `key.properties`
- Firebase service-account credentials
- production `.env` files
- live Stripe secrets or webhook secrets
