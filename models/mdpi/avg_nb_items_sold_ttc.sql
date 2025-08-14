-- AUTHOR : Hugo Soubeyrat
-- For each product, the number of items sold as well as their average price, tax included
-- This model only gives us the average with the taxes for each store; we are missing the price of each line item for each order.

with order_items as (
    select
        oi.order_id,
        oi.product_id
    from {{ ref('stg_order_items') }} as oi
),

orders_with_location as (
    select
        ol.order_id,
        ol.location_id
    from {{ ref('stg_orders') }} as ol
),

products as (
    select
        p.product_id,
        p.product_name,
        p.product_price::numeric as unit_price_ht
    from {{ ref('stg_products') }} as p
),

locations as (
    select
        l.location_id,
        l.tax_rate::numeric as tax_rate
    from {{ ref('stg_locations') }} as l
),

-- Price including tax per sales line (one line = one item sold)
lines as (
    select
        oi.product_id,
        (p.unit_price_ht * (1 + l.tax_rate))::numeric(18,2) as unit_price_ttc
    from order_items oi
    join orders_with_location ow using (order_id)
    join locations l using (location_id)
    join products p using (product_id)
)

select
    p.product_id,
    p.product_name,
    count(*)::bigint as items_sold,    -- 1 row = 1 item
    avg(lines.unit_price_ttc)::numeric(18,2) as avg_unit_price_tax_included    -- ::numeric(18,2) converts the result to a number with a maximum of 18 digits and 2 decimal places.
from lines
join products p using (product_id)
group by p.product_id, p.product_name
order by items_sold desc, p.product_id
