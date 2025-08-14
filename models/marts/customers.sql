WITH

customers AS (

    SELECT * FROM {{ ref('stg_customers') }}

),

orders AS (

    SELECT * FROM {{ ref('orders') }}

),

customer_orders_summary AS (

    SELECT
        orders.customer_id,

        count(DISTINCT orders.order_id) AS count_lifetime_orders,
        count(DISTINCT orders.order_id) > 1 AS is_repeat_buyer,
        min(orders.ordered_at) AS first_ordered_at,
        max(orders.ordered_at) AS last_ordered_at,
        sum(orders.subtotal) AS lifetime_spend_pretax,
        sum(orders.tax_paid) AS lifetime_tax_paid,
        sum(orders.order_total) AS lifetime_spend

    FROM orders

    GROUP BY 1

),

joined AS (

    SELECT
        customers.*,

        customer_orders_summary.count_lifetime_orders,
        customer_orders_summary.first_ordered_at,
        customer_orders_summary.last_ordered_at,
        customer_orders_summary.lifetime_spend_pretax,
        customer_orders_summary.lifetime_tax_paid,
        customer_orders_summary.lifetime_spend,

        CASE
            WHEN customer_orders_summary.is_repeat_buyer THEN 'returning'
            ELSE 'new'
        END AS customer_type

    FROM customers

    LEFT JOIN customer_orders_summary
        ON customers.customer_id = customer_orders_summary.customer_id

)

SELECT * FROM joined
