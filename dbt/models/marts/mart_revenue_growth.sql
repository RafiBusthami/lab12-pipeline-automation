-- Part E3: month-over-month revenue growth.
-- LAG(revenue) looks one row back (the previous month) in the window ordered by month.
-- The first month has no previous month, so its growth columns are NULL.
with monthly as (
    select
        d.ym,
        count(distinct f.order_id) as orders,
        sum(f.total_amount)        as revenue
    from {{ ref('fact_sales') }} f
    join {{ ref('dim_date') }}   d on f.date_key = d.date_key
    group by d.ym
)

select
    ym,
    orders,
    revenue,
    lag(revenue) over w                     as prev_month_revenue,
    revenue - lag(revenue) over w           as revenue_change,
    round(
        100.0 * (revenue - lag(revenue) over w)
        / nullif(lag(revenue) over w, 0),   -- nullif: never divide by zero
        2
    )                                       as growth_pct
from monthly
window w as (order by ym)
order by ym
