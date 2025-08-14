-- AUTHOR : Hugo Soubeyrat
-- Compute the total invoiced amount variation (in %) between months

-- I put all the dates on the first day of the month.
WITH orders AS (
    SELECT
        date_trunc('month', o.ordered_at)::date AS month_clean,   -- returns to the first day of the month for every row
        o.order_total::numeric AS order_total
    FROM {{ ref('stg_orders') }} AS o
    WHERE o.ordered_at IS NOT null
),

-- Calculation of the total amount for each month
monthly AS (
    SELECT
        month_clean,
        sum(order_total)::numeric(18, 2) AS total_invoiced_amount_ttc
    FROM orders
    GROUP BY month_clean
),

-- Add the column prev_total_invoiced_amount_ttc, which provides the total for the previous month for each row
with_prev AS (
    SELECT
        m.month_clean,
        m.total_invoiced_amount_ttc,
        lag(m.total_invoiced_amount_ttc) OVER (ORDER BY m.month_clean) AS prev_total_invoiced_amount_ttc
    FROM monthly AS m
)

SELECT
    month_clean,
    total_invoiced_amount_ttc,
    prev_total_invoiced_amount_ttc,
    CASE
        WHEN prev_total_invoiced_amount_ttc IS null OR prev_total_invoiced_amount_ttc = 0
            THEN null  -- no variation defined for the first month or if the previous month is 0
        ELSE
            round(
                100.0 * (total_invoiced_amount_ttc - prev_total_invoiced_amount_ttc) / prev_total_invoiced_amount_ttc, 2
            )
    END AS mom_variation_pct
FROM with_prev
ORDER BY month_clean
