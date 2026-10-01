# Flutter Service Marketplace — Production Architecture Sample

Sanitized portfolio version of a production Flutter marketplace application for local services.

This repository is derived from a real production codebase and is intended to demonstrate architecture, workflow design and implementation patterns without exposing production credentials, customer data or signing material.

## What this sample demonstrates

- Flutter multi-role app architecture (Client / Professional / Admin)
- Firebase Authentication and Firestore integration
- Role-aware onboarding and profile completion flows
- Job lifecycle and marketplace workflow
- Quotes / offers
- Real-time chat and unread counters
- Push and local notification architecture
- Multi-country / multi-currency support (RO / UK)
- Localization (Romanian / English)
- Google Maps / geocoding integration via environment-based configuration
- Stripe Connect backend patterns using Firebase secret management
- Firebase Cloud Functions

## Security / sanitization

The public repository intentionally excludes or replaces:

- production Firebase configuration
- Google API keys
- Apple private signing/auth keys
- user exports and password hashes
- production webhook/Stripe secrets
- production-only service URLs and identifiers
- signing keystores and certificates
- large production datasets and store/build artifacts

See `SECURITY.md` and `.env.example` for details.

## Configuration

Provide your own Firebase / Google configuration through environment values or local platform configuration. Never commit production credentials.

Example values are documented in `.env.example`.

## Note

Some production-only assets, datasets and infrastructure configuration are deliberately omitted. The goal of this repository is to show real application architecture and implementation while keeping the production system isolated.
