ARG DUCKDB_CLI_VERSION=2.0.0
FROM duckdb/duckdb:${DUCKDB_CLI_VERSION} AS duckdb-cli

FROM python:3.12-slim

COPY --from=duckdb-cli /duckdb /usr/local/bin/duckdb

ENV PYTHONUNBUFFERED=1

WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends make git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt

RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt awscli \
    && rm /tmp/requirements.txt

COPY models ./models
COPY dbt_project.yml ./dbt_project.yml
COPY profiles.yml ./profiles.yml

CMD ["dbt", "build", "--profiles-dir", ".", "--target", "aws"]