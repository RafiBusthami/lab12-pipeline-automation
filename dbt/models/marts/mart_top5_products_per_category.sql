-- Part E2: the 5 best-selling products (by revenue) in each category.
-- ROW_NUMBER() numbers the products inside each category from best to worst,
-- QUALIFY keeps only numbers 1-5 (QUALIFY = a WHERE that runs after window functions).
with product_sales as (
    select
        p.category,
        p.product_id,
        p.product_name,
        sum(f.quantity)     as units_sold,
        sum(f.total_amount) as revenue
    from {{ ref('fact_sales') }}  f
    join {{ ref('dim_product') }} p on f.product_id = p.product_id
    group by p.category, p.product_id, p.product_name
)

select
    category,
    row_number() over (
        partition by category
        order by revenue desc, units_sold desc, product_id   -- tie-breakers keep the order stable
    )                                                                   as rank_in_category,
    product_id,
    product_name,
    units_sold,
    revenue,
    round(100.0 * revenue / sum(revenue) over (partition by category), 2) as pct_of_category_revenue
from product_sales
qualify rank_in_category <= 5
order by category, rank_in_category
