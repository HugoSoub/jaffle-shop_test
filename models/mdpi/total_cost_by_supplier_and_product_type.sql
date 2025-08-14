-- AUTHOR : Hugo Soubeyrat
-- Total cost paid by supplier ("supply") and product type in 2016
--  - When analyzing the database via Adminer, we see that the oldest order dates from 2024-09-01.
--  - I will therefore modify the request to calculate the cost of products for each year starting from the oldest year.

-- Save just the year for every row
with orders as (
    select
        o.order_id,
        extract(year from o.ordered_at)::int as year
    from {{ ref('stg_orders') }} o
    where o.ordered_at is not null
),

order_items as (
    select
        oi.order_id,
        oi.product_id
    from {{ ref('stg_order_items') }} oi
),

-- Number of items per year and product (1 line = 1 item)
items_by_year_product as (
    select
        o.year,
        oi.product_id,
        count(*)::numeric as items_count
    from order_items oi
    join orders o using (order_id)
    group by 1,2
),

supplies as (
    select
        s.product_id,
        s.supply_cost::numeric as supply_cost_unit
    from {{ ref('stg_supplies') }} s
),

products as (
    select
        p.product_id,
        p.product_type
    from {{ ref('stg_products') }} p
)

select
    i.year,
    p.product_type,
    sum(i.items_count * coalesce(s.supply_cost_unit, 0))::numeric(18,2) as total_purchase_cost
from items_by_year_product i
join products p using (product_id)
left join supplies s using (product_id)
group by i.year, p.product_type
order by i.year, p.product_type