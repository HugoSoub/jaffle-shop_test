-- AUTHOR : Hugo Soubeyrat
-- Total cost paid by supplier ("supply") and product type in 2016
--  - When analyzing the database via Adminer, we see that the oldest order dates from 2024-09-01.
--  - I will therefore modify the request to calculate the cost of products for each year starting from the oldest year.

-- Save just the year for every row
WITH orders AS (
    SELECT
        o.order_id,
        extract(YEAR FROM o.ordered_at)::int AS year_clean
    FROM {{ ref('stg_orders') }} AS o
    WHERE o.ordered_at IS NOT null
),

order_items AS (
    SELECT
        oi.order_id,
        oi.product_id
    FROM {{ ref('stg_order_items') }} AS oi
),

-- Number of items per year and product (1 line = 1 item)
items_by_year_product AS (
    SELECT
        o.year_clean,
        oi.product_id,
        count(*)::numeric AS items_count
    FROM order_items AS oi
    INNER JOIN orders AS o ON oi.order_id = o.order_id
    GROUP BY o.year_clean, oi.product_id
),

supplies AS (
    SELECT
        s.product_id,
        s.supply_cost::numeric AS supply_cost_unit
    FROM {{ ref('stg_supplies') }} AS s
),

products AS (
    SELECT
        p.product_id,
        p.product_type
    FROM {{ ref('stg_products') }} AS p
)

SELECT
    i.year_clean,
    p.product_type,
    sum(i.items_count * coalesce(s.supply_cost_unit, 0))::numeric(18, 2) AS total_purchase_cost
FROM items_by_year_product AS i
INNER JOIN products AS p
    ON i.product_id = p.product_id
LEFT JOIN supplies AS s
    ON i.product_id = s.product_id
GROUP BY i.year_clean, p.product_type
ORDER BY i.year_clean, p.product_type
