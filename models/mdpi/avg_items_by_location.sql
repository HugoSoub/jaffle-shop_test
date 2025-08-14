-- AUTHOR : Hugo Soubeyrat
-- Average number of items per order, by location

-- For know how many items we have for each order
WITH items_per_order AS (
    SELECT
        oi.order_id,
        count(*) AS items_in_order    -- We don't have a column of quantity so i expect 1 row = 1 qty
    FROM {{ ref('stg_order_items') }} AS oi
    GROUP BY oi.order_id
),

orders_with_location AS (
    SELECT
        o.order_id,
        o.location_id
    FROM {{ ref('stg_orders') }} AS o
),

locations AS (
    SELECT
        l.location_id,
        l.location_name
    FROM {{ ref('stg_locations') }} AS l
)

-- Calculate the average number of items per order for each location
SELECT
    loc.location_id,
    loc.location_name,
    -- ::numeric(18,2) converts the result to a number with a maximum of 18 digits and 2 decimal places.
    avg(ipo.items_in_order)::numeric(18, 2) AS avg_items_per_order
FROM items_per_order AS ipo
INNER JOIN orders_with_location AS ow ON ipo.order_id = ow.order_id
INNER JOIN locations AS loc ON ow.location_id = loc.location_id
GROUP BY loc.location_id, loc.location_name
