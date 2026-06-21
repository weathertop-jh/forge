FROM python:3.12-slim
WORKDIR /workspace/mcp/forge-server
COPY mcp/forge-server/pyproject.toml mcp/forge-server/README.md ./
COPY mcp/forge-server/src ./src
RUN pip install --no-cache-dir .
CMD ["forge-mcp"]
