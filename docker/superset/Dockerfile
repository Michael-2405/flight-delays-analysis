# docker/superset/Dockerfile
FROM apache/superset:latest

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev gcc && \
    /app/.venv/bin/python -m ensurepip && \
    /app/.venv/bin/python -m pip install psycopg2-binary && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER superset
