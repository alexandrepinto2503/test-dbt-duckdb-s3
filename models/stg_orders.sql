select
    order_id,
    customer_id,
    amount
from read_csv('s3://dsc-sandbox-input/test-dbt-duckdb/raw_orders.csv')
where status = 'completed'