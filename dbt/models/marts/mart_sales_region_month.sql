-- Part E1: sales per region per month.
-- One row per (month, region): the fact table joined to dim_customer (for the region)
-- and dim_date (for the month).
select
    d.ym,
    c.region,
    count(distinct f.order_id)    as orders,
    count(distinct f.customer_id) as customers,
    sum(f.quantity)               as units_sold,
    sum(f.total_amount)           as revenue
from {{ ref('fact_sales') }}   f
join {{ ref('dim_customer') }} c on f.customer_id = c.customer_id
join {{ ref('dim_date') }}     d on f.date_key    = d.date_key
group by d.ym, c.region
order by d.ym, revenue desc
