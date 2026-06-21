"""Declared Forge MCP tool surface.

Mutation and operational tools intentionally remain disabled until Forge has
authentication, authorization, approvals, sandboxing, and deployment adapters.
"""

from __future__ import annotations

from pathlib import Path
from typing import NoReturn

from .security import audit_log, require_allowed_path


def _not_implemented(tool: str) -> NoReturn:
    audit_log(tool, "denied", {"reason": "placeholder tool is disabled"})
    raise NotImplementedError(f"{tool} is scaffolded but not enabled")


def list_project_files(project_path: str) -> list[str]:
    root = require_allowed_path(project_path)
    files = [str(path.relative_to(root)) for path in root.rglob("*") if path.is_file()]
    audit_log("list_project_files", "allowed", {"path": str(root), "count": len(files)})
    return sorted(files)


def read_file(path: str) -> str:
    source = require_allowed_path(path)
    content = source.read_text(encoding="utf-8")
    audit_log("read_file", "allowed", {"path": str(source), "bytes": len(content.encode())})
    return content


def write_file(path: str, content: str) -> NoReturn:
    require_allowed_path(path)
    _not_implemented("write_file")


def run_command(command: str) -> NoReturn:
    _not_implemented("run_command")


def git_status(project_path: str) -> NoReturn:
    require_allowed_path(project_path)
    _not_implemented("git_status")


def git_commit(project_path: str, message: str) -> NoReturn:
    require_allowed_path(project_path)
    _not_implemented("git_commit")


def deploy_app(app_name: str) -> NoReturn:
    _not_implemented("deploy_app")


def restart_service(service_name: str) -> NoReturn:
    _not_implemented("restart_service")


def view_logs(service_name: str, lines: int = 100) -> NoReturn:
    _not_implemented("view_logs")


def upload_asset(destination: str, content: bytes) -> NoReturn:
    require_allowed_path(Path(destination))
    _not_implemented("upload_asset")
