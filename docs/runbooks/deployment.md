# Deployment

Forge targets a Docker Compose-managed VPS behind nginx.

Before production deployment, configure secrets outside Git, restrict exposed ports, add TLS, pin image versions, enable backups, and implement authenticated MCP authorization and sandboxing. Deployment and restart MCP tools remain disabled in this scaffold.
