-- E1 check: mart_sales_region_month must have exactly one row per (ym, region).
-- Any row returned = a duplicated month/region pair = test FAILS.
select ym, region, count(*) as n_rows
from {{ ref('mart_sales_region_month') }}
group by ym, region
having count(*) > 1
