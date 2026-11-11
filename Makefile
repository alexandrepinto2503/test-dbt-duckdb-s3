.PHONY: build-image up run seed  down logs terminal download

build-image:
	docker build -t test-dbt-duckdb:local .

terminal:
	docker compose run --rm -it --entrypoint /bin/bash dbt

run:
	dbt build --profiles-dir . --target local

seed:
	aws s3api head-bucket --bucket dsc-sandbox-input 2>/dev/null || aws s3 mb s3://dsc-sandbox-input
	aws s3api head-bucket --bucket dsc-sandbox-output 2>/dev/null || aws s3 mb s3://dsc-sandbox-output
	aws s3 cp input/ s3://dsc-sandbox-input/test-dbt-duckdb/ --recursive

down:
	docker compose down

logs:
	docker compose logs -f dbt

download: 
	aws s3 cp s3://dsc-sandbox-output/test-dbt-duckdb/ output/ --recursive
