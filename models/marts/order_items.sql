WITH

order_items AS (

    SELECT * FROM {{ ref('stg_order_items') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

products AS (

    SELECT * FROM {{ ref('stg_products') }}

),

supplies AS (

    SELECT * FROM {{ ref('stg_supplies') }}

),

order_supplies_summary AS (

    SELECT
        product_id,

        sum(supply_cost) AS supply_cost

    FROM supplies

    GROUP BY 1

),

joined AS (

    SELECT
        order_items.*,

        orders.ordered_at,

        products.product_name,
        products.product_price,
        products.is_food_item,
        products.is_drink_item,

        order_supplies_summary.supply_cost

    FROM order_items

    LEFT JOIN orders ON order_items.order_id = orders.order_id

    LEFT JOIN products ON order_items.product_id = products.product_id

    LEFT JOIN order_supplies_summary
        ON order_items.product_id = order_supplies_summary.product_id

)

SELECT * FROM joined
