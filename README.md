# dbt + DuckDB + local S3 (MinIO)

This project uses dbt-duckdb to read `raw_orders.csv` from `dsc-sandbox-input` and write the external `customer_totals.csv` model to `dsc-sandbox-output`. Both buckets are hosted locally by MinIO, not AWS. The SQL models still use ordinary `s3://` paths.

## Prerequisites

- Docker with Docker Compose v2

Compose starts MinIO and waits for it to be healthy before opening the dbt container. It supplies local-only credentials (`minioadmin` / `minioadmin`) and does not mount your AWS credentials. These credentials and the unencrypted endpoint are for local testing only. Inside the container, `make seed` creates both buckets if needed before uploading the seed files.

The Dockerfile pins the DuckDB CLI to the same DuckDB release used by the installed dbt-duckdb adapter so CLI and Python use compatible DuckDB extensions.
The container needs network access to DuckDB's official extension repository to download `httpfs` on first use. The `aws` extension is not needed because the local S3 secret uses explicitly configured credentials.

## Run

From the project directory, build the image and open the interactive container:

```sh
make build-image
make terminal
```

Inside the container, upload the seed CSV to S3 and run dbt:

```sh
make seed
make run
```

`make seed` uses AWS CLI to check/create the input and output buckets, then copy the files from `input/` to `s3://dsc-sandbox-input/test-dbt-duckdb/`. It can be rerun when the buckets already exist. Run it inside the container: `AWS_ENDPOINT_URL_S3` directs AWS CLI to MinIO automatically. `make run` runs `dbt build --profiles-dir .`; the staging model reads the uploaded object and the external model writes to `s3://dsc-sandbox-output/test-dbt-duckdb/customer_totals.csv`. You can download the output files from S3 (MiniO) to output/ using `make download`.

Inside the Docker network, the endpoint is `http://minio:9000`; DuckDB's secret uses `minio:9000` with SSL disabled and path-style addressing. On the host, the S3 API is available at `http://localhost:9002` and the MinIO console at `http://localhost:9003`. Sign into the console with the local credentials above to inspect input and output objects.

MinIO data persists in the `minio-data` Docker volume across container restarts and `make down`. Removing that volume deletes the local buckets and their contents. DuckDB itself runs in memory, so its dbt relations do not persist between commands; run the full `make build` each time.

Run `./push_iamge` to push the Docker image to ECR (qlsandbox), so it can be executed in ECS.