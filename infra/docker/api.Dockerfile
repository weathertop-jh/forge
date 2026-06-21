FROM python:3.12-slim
WORKDIR /workspace
COPY core/api/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
COPY core /workspace/core
CMD ["uvicorn", "core.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
