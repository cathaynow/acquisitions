# Acquisitions: Dockerized with Neon Local (dev) and Neon Cloud (prod)

This repo provides a dual-mode setup:
- Development: Run the Express API alongside Neon Local (a local proxy for Neon) using Docker Compose.
- Production: Run only the app container and connect to Neon Cloud using your Neon connection string.

Contents
- Dockerfile (multi-stage: development and production)
- docker-compose.dev.yml (app + Neon Local)
- docker-compose.prod.yml (app only)
- .env.development (local dev defaults)
- .env.production (template for production)

Prerequisites
- Docker and Docker Compose installed
- A Neon account, Project ID, and API key (for Neon Local)

Environment variables
- Development (app): DATABASE_URL=postgres://devuser:devpass@neon-local:5432/devdb
- Production (app): DATABASE_URL=postgresql://<user>:<password>@<your-project>-<endpoint>.neon.tech/<dbname>?sslmode=require

Neon Local requires:
- NEON_API_KEY
- NEON_PROJECT_ID
- Optionally, NEON_DEFAULT_BRANCH (default: main), NEON_DATABASE, NEON_ROLE, NEON_PASSWORD

Quick start (development)
1) Set the Neon Local credentials in your shell (recommended) or in a .env file in this folder:
   - PowerShell (Windows):
     $env:NEON_API_KEY="<your_neon_api_key>"
     $env:NEON_PROJECT_ID="<your_project_id>"

   Optional overrides:
     $env:NEON_DATABASE="devdb"
     $env:NEON_ROLE="devuser"
     $env:NEON_PASSWORD="devpass"
     $env:NEON_DEFAULT_BRANCH="main"
     $env:NEON_EPH_BRANCH_MODE="auto"  # enable ephemeral branches (see Neon Local docs)

2) Start services:
   docker compose -f docker-compose.dev.yml up --build

3) App endpoints:
   - Health: http://localhost:3000/health
   - Base: http://localhost:3000/api
   - Auth:
     POST /api/auth/sign-up
     POST /api/auth/sign-in
     POST /api/auth/sign-out

The app connects to Neon Local using DATABASE_URL from .env.development:
  postgres://devuser:devpass@neon-local:5432/devdb

Neon Local will create and proxy to ephemeral branches if configured via NEON_EPH_BRANCH_MODE. Refer to https://neon.com/docs/local/neon-local for detailed behavior and options.

Quick start (production)
1) Edit .env.production with your Neon Cloud DATABASE_URL and JWT_SECRET.

2) Build and run:
   docker compose -f docker-compose.prod.yml up --build -d

3) The app will be available at http://localhost:3000 and will connect to Neon Cloud.

Implementation details
- Database drivers:
  - Development: When DATABASE_URL points at neon-local (or localhost), the app uses the node-postgres (pg) driver with drizzle-orm/node-postgres.
  - Production: When DATABASE_URL points at Neon Cloud, the app uses @neondatabase/serverless (drizzle-orm/neon-http).
- This behavior is automatic based on NODE_ENV and DATABASE_URL; no code changes are needed when switching environments.

Running migrations
- You can run migrations inside the app container before starting the server if desired:
  docker compose -f docker-compose.prod.yml run --rm app npm run db:migrate

Notes and best practices
- Never commit real secrets. The .env.development is for local defaults only; for Neon Local credentials, use shell env vars.
- In production, ensure JWT_SECRET is set and unique.
- For CI/CD, inject DATABASE_URL and other secrets via your platform’s secret manager.
