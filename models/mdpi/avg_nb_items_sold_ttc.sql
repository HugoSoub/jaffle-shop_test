-- AUTHOR : Hugo Soubeyrat
-- For each product, the number of items sold as well as their average price, tax included
-- This model only gives us the average with the taxes for each store; we are missing
-- the price of each line item for each order.

WITH order_items AS (
    SELECT
        oi.order_id,
        oi.product_id
    FROM {{ ref('stg_order_items') }} AS oi
),

orders_with_location AS (
    SELECT
        ol.order_id,
        ol.location_id
    FROM {{ ref('stg_orders') }} AS ol
),

products AS (
    SELECT
        p.product_id,
        p.product_name,
        p.product_price::numeric AS unit_price_ht
    FROM {{ ref('stg_products') }} AS p
),

locations AS (
    SELECT
        l.location_id,
        l.tax_rate::numeric AS tax_rate
    FROM {{ ref('stg_locations') }} AS l
),

-- Price including tax per sales line (one line = one item sold)
lines AS (
    SELECT
        oi.product_id,
        (p.unit_price_ht * (1 + l.tax_rate))::numeric(18, 2) AS unit_price_ttc
    FROM order_items AS oi
    INNER JOIN orders_with_location AS ow
        ON oi.order_id = ow.order_id
    INNER JOIN locations AS l
        ON ow.location_id = l.location_id
    INNER JOIN products AS p
        ON oi.product_id = p.product_id
)

SELECT
    p.product_id,
    p.product_name,
    count(*)::bigint AS items_sold,    -- 1 row = 1 item
    -- ::numeric(18,2) converts the result to a number with a maximum of 18 digits and 2 decimal places.
    avg(lines.unit_price_ttc)::numeric(18, 2) AS avg_unit_price_tax_included
FROM lines
INNER JOIN products AS p
    ON lines.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY items_sold DESC, p.product_id ASC
