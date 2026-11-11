AWS_ACCOUNT_ID=606046046870
AWS_REGION=ap-southeast-2
REPO=test-dbt-duckdb-s3
IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO"
aws ecr get-login-password --region "$AWS_REGION" --profile qlsandbox | docker login --username AWS --password-stdin \
	"$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
docker build -t "${IMAGE}:latest" . --no-cache
docker push "${IMAGE}:latest"