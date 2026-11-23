-- Part E4: customers ranked by total spending (rank 1 = highest).
-- Every customer who bought something is kept, so a dashboard can show the top 5, 10, ...
-- by filtering on spending_rank. RANK() gives equal spenders the same rank.
with spend as (
    select
        c.customer_id,
        c.customer_name,
        c.region,
        count(distinct f.order_id) as orders,
        sum(f.quantity)            as units_bought,
        sum(f.total_amount)        as total_spent,
        min(f.date_key)            as first_order_date,
        max(f.date_key)            as last_order_date
    from {{ ref('fact_sales') }}   f
    join {{ ref('dim_customer') }} c on f.customer_id = c.customer_id
    group by c.customer_id, c.customer_name, c.region
)

select
    rank() over (order by total_spent desc) as spending_rank,
    customer_id,
    customer_name,
    region,
    orders,
    units_bought,
    total_spent,
    round(total_spent / orders, 2)          as avg_order_value,
    first_order_date,
    last_order_date
from spend
order by spending_rank, customer_id
