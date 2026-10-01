# Flutter Service Marketplace — Production Architecture Sample

Sanitized portfolio version of a production Flutter marketplace application for local services.

This repository is derived from a real production codebase and demonstrates architecture, workflow design and implementation patterns without exposing production credentials, customer data or signing material.

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
- Stripe Connect backend patterns using secret management
- Firebase Cloud Functions architecture

## Security / sanitization
The public repository intentionally excludes or replaces production Firebase configuration, Google API keys, Apple private signing/auth keys, user exports/password hashes, Stripe/webhook secrets, production-only URLs and identifiers, signing keystores/certificates, large production datasets and build/store artifacts.

See `SECURITY.md` and `.env.example` for details.

## Configuration
Provide your own Firebase / Google configuration through environment values or local platform configuration. Never commit production credentials.

## Note
Some production-only assets, datasets and infrastructure configuration are deliberately omitted. The goal is to show real application architecture and implementation while keeping the production system isolated.
