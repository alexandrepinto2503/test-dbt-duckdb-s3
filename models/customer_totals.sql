{{ config(materialized='external', location='s3://dsc-sandbox-output/test-dbt-duckdb/customer_totals.csv', format='csv') }}

select
    customer_id,
    count(*)    as order_count,
    sum(amount) as total_spent
from {{ ref('stg_orders') }}
group by customer_id