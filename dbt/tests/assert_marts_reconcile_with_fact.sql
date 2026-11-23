-- Part E5: the marts that cover ALL sales must add up to the same total revenue as fact_sales.
-- If a join silently drops rows (for example a customer missing from dim_customer),
-- a mart total will differ from the fact total and this test returns that mart = FAIL.
-- (mart_top5_products_per_category is left out on purpose: it keeps only the top 5 per category.)
with totals as (
    select 'mart_sales_region_month' as model, sum(revenue)     as revenue from {{ ref('mart_sales_region_month') }}
    union all
    select 'mart_revenue_growth'     as model, sum(revenue)     as revenue from {{ ref('mart_revenue_growth') }}
    union all
    select 'mart_top_customers'      as model, sum(total_spent) as revenue from {{ ref('mart_top_customers') }}
),

fact as (
    select sum(total_amount) as revenue from {{ ref('fact_sales') }}
)

select t.model, t.revenue as mart_revenue, f.revenue as fact_revenue
from totals t
cross join fact f
where t.revenue is distinct from f.revenue
