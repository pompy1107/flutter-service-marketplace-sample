# Security notes

This repository is a sanitized portfolio copy of a production application.

Production credentials and customer data are deliberately excluded. Never commit real `.env` files, Firebase production configuration, `google-services.json`, `GoogleService-Info.plist`, Apple `.p8` private keys, Android signing keystores, Stripe secret/webhook keys, service-account files, or exports containing user records/password hashes/tokens.

The sample uses placeholder or environment-based configuration. Anyone running it must provide their own Firebase, Google Maps and payment configuration.
