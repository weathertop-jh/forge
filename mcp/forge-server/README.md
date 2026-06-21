# Forge MCP Server

Placeholder MCP server for future Codex-to-VPS control. The initial surface names file, Git, command, deployment, service, log, and asset operations without implementing privileged behavior.

Security is deny-by-default: paths and commands require allowlist checks, secrets must be redacted, and every sensitive operation must produce an audit event. Production deployment should add authentication, authorization, approval policies, rate limits, and isolated execution before enabling mutation tools.
