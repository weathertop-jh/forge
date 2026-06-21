# Local Development

1. Install Docker with the Compose plugin, Python 3.11+, and Node.js 20+.
2. Copy `.env.example` to `.env` and replace placeholder secrets.
3. Run `./scripts/bootstrap.sh` for local environment checks.
4. Run `./scripts/dev.sh` to start Postgres, Redis, the API, and MCP placeholder.
5. Verify the API at `http://localhost:8000/health`.

Applications are scaffolded as folders only; initialize each Next.js application when product work begins.
