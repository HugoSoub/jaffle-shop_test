-- AUTHOR : Hugo Soubeyrat
-- Top 3 customers by invoiced amount by month

WITH orders AS (
    SELECT
        o.customer_id,
        date_trunc('month', o.ordered_at)::date AS month_clean, -- returns to the first day of the month for every row
        o.order_total::numeric AS order_total
    FROM {{ ref('stg_orders') }} AS o
    WHERE o.ordered_at IS NOT null
),

-- Monthly amount per customer
customer_amounts_monthly AS (
    SELECT
        customer_id,
        month_clean,
        sum(order_total)::numeric(18, 2) AS invoiced_amount_ttc
    FROM orders
    GROUP BY customer_id, month_clean
),

-- Top 3 ranking by month
ranked AS (
    SELECT
        cam.month_clean,
        cam.customer_id,
        cam.invoiced_amount_ttc,
        -- Create a rank for each month and give the same place if we have a equal score
        dense_rank() OVER (PARTITION BY cam.month_clean ORDER BY cam.invoiced_amount_ttc DESC) AS monthly_rank
    FROM customer_amounts_monthly AS cam
)

SELECT
    r.month_clean,
    r.customer_id,
    c.customer_name,
    r.invoiced_amount_ttc,
    r.monthly_rank
FROM ranked AS r
INNER JOIN {{ ref('stg_customers') }} AS c ON r.customer_id = c.customer_id
WHERE r.monthly_rank <= 3
ORDER BY r.month_clean ASC, r.monthly_rank ASC, r.invoiced_amount_ttc DESC, r.customer_id ASC
