-- AUTHOR : Hugo Soubeyrat
-- Compute the total invoiced amount variation (in %) between months

-- I put all the dates on the first day of the month.
with orders as (
    select
        date_trunc('month', o.ordered_at)::date as month,    -- returns to the first day of the month for every row
        o.order_total::numeric as order_total
    from {{ ref('stg_orders') }} as o
    where o.ordered_at is not null
),

-- Calculation of the total amount for each month
monthly as (
    select
        month,
        sum(order_total)::numeric(18,2) as total_invoiced_amount_ttc
    from orders
    group by 1
),

-- Add the column prev_total_invoiced_amount_ttc, which provides the total for the previous month for each row
with_prev as (
    select
        m.month,
        m.total_invoiced_amount_ttc,
        lag(m.total_invoiced_amount_ttc) over (order by m.month) as prev_total_invoiced_amount_ttc
    from monthly m
)

select
    month,
    total_invoiced_amount_ttc,
    prev_total_invoiced_amount_ttc,
    case
        when prev_total_invoiced_amount_ttc is null or prev_total_invoiced_amount_ttc = 0
            then null  -- no variation defined for the first month or if the previous month is 0
        else round(100.0 * (total_invoiced_amount_ttc - prev_total_invoiced_amount_ttc) / prev_total_invoiced_amount_ttc, 2)
    end as mom_variation_pct
from with_prev
order by month