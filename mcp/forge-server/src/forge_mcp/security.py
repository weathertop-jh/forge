"""Deny-by-default security primitives for future Forge MCP tools."""

from __future__ import annotations

import json
import os
import re
from datetime import UTC, datetime
from pathlib import Path
from typing import Any, Iterable

SECRET_KEY_PATTERN = re.compile(
    r"(api[_-]?key|authorization|cookie|password|secret|token)", re.IGNORECASE
)
REDACTED = "[REDACTED]"


class SecurityViolation(PermissionError):
    """Raised when an MCP request falls outside an explicit allowlist."""


def _configured_items(name: str) -> tuple[str, ...]:
    return tuple(item.strip() for item in os.getenv(name, "").split(",") if item.strip())


def allowed_roots() -> tuple[Path, ...]:
    """Return resolved roots configured for MCP file access."""
    return tuple(Path(item).expanduser().resolve() for item in _configured_items("FORGE_MCP_ALLOWED_ROOTS"))


def require_allowed_path(path: str | Path, roots: Iterable[Path] | None = None) -> Path:
    """Resolve a path and reject it unless it is inside an allowed root."""
    resolved = Path(path).expanduser().resolve()
    configured_roots = tuple(roots) if roots is not None else allowed_roots()
    if not configured_roots:
        raise SecurityViolation("No file roots are allowlisted")
    if not any(resolved == root or resolved.is_relative_to(root) for root in configured_roots):
        raise SecurityViolation(f"Path is outside the allowlist: {resolved}")
    return resolved


def require_allowed_command(command: str) -> str:
    """Reject shell syntax and executables absent from the command allowlist."""
    if any(token in command for token in (";", "&&", "||", "|", "`", "$(", "\n")):
        raise SecurityViolation("Shell composition is not allowed")
    executable = command.split(maxsplit=1)[0] if command.strip() else ""
    if executable not in _configured_items("FORGE_MCP_ALLOWED_COMMANDS"):
        raise SecurityViolation(f"Command is not allowlisted: {executable or '<empty>'}")
    return command


def redact_secrets(value: Any) -> Any:
    """Recursively redact values whose keys commonly contain secrets."""
    if isinstance(value, dict):
        return {
            key: REDACTED if SECRET_KEY_PATTERN.search(str(key)) else redact_secrets(item)
            for key, item in value.items()
        }
    if isinstance(value, list):
        return [redact_secrets(item) for item in value]
    if isinstance(value, tuple):
        return tuple(redact_secrets(item) for item in value)
    return value


def audit_log(action: str, outcome: str, details: dict[str, Any] | None = None) -> None:
    """Append a redacted JSON audit event; fail closed if no log is configured."""
    log_path = os.getenv("FORGE_MCP_AUDIT_LOG")
    if not log_path:
        raise SecurityViolation("FORGE_MCP_AUDIT_LOG must be configured")
    destination = Path(log_path).expanduser()
    destination.parent.mkdir(parents=True, exist_ok=True)
    event = {
        "timestamp": datetime.now(UTC).isoformat(),
        "action": action,
        "outcome": outcome,
        "details": redact_secrets(details or {}),
    }
    with destination.open("a", encoding="utf-8") as stream:
        stream.write(json.dumps(event, sort_keys=True) + "\n")
