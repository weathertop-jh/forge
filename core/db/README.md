# Core Database

This folder owns shared database conventions, migrations, and connection helpers for Postgres.

The local Compose stack uses the `pgvector/pgvector` Postgres image so vector columns and indexes can be introduced without replacing the database service. Enable the extension in a future migration with:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Keep project-specific schemas and queries with their application. Only stable, cross-project persistence logic belongs here. Redis is available as a separate service for caching, queues, and ephemeral coordination; durable state stays in Postgres.
