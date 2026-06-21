"""Forge MCP server entry point."""

from mcp.server.fastmcp import FastMCP

from . import tools

mcp = FastMCP("Forge")
mcp.tool()(tools.list_project_files)
mcp.tool()(tools.read_file)


def main() -> None:
    """Run the initial read-only MCP server over stdio."""
    mcp.run()


if __name__ == "__main__":
    main()
