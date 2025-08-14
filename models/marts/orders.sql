WITH

orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

order_items AS (

    SELECT * FROM {{ ref('order_items') }}

),

order_items_summary AS (

    SELECT
        order_id,

        sum(supply_cost) AS order_cost,
        sum(product_price) AS order_items_subtotal,
        count(order_item_id) AS count_order_items,
        sum(
            CASE
                WHEN is_food_item THEN 1
                ELSE 0
            END
        ) AS count_food_items,
        sum(
            CASE
                WHEN is_drink_item THEN 1
                ELSE 0
            END
        ) AS count_drink_items

    FROM order_items

    GROUP BY 1

),

compute_booleans AS (

    SELECT
        orders.*,

        order_items_summary.order_cost,
        order_items_summary.order_items_subtotal,
        order_items_summary.count_food_items,
        order_items_summary.count_drink_items,
        order_items_summary.count_order_items,
        order_items_summary.count_food_items > 0 AS is_food_order,
        order_items_summary.count_drink_items > 0 AS is_drink_order

    FROM orders

    LEFT JOIN
        order_items_summary
        ON orders.order_id = order_items_summary.order_id

),

customer_order_count AS (

    SELECT
        *,

        row_number() OVER (
            PARTITION BY customer_id
            ORDER BY ordered_at ASC
        ) AS customer_order_number

    FROM compute_booleans

)

SELECT * FROM customer_order_count
