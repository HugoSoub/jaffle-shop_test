-- AUTHOR : Hugo Soubeyrat
-- Top 3 customers by invoiced amount by month

with orders as (
    select
        o.customer_id,
        date_trunc('month', o.ordered_at)::date as month, -- returns to the first day of the month for every row
        o.order_total::numeric as order_total
    from {{ ref('stg_orders') }} as o
    where o.ordered_at is not null
),

-- Monthly amount per customer
customer_amounts_monthly as (
    select
        customer_id,
        month,
        sum(order_total)::numeric(18,2) as invoiced_amount_ttc
    from orders
    group by 1,2
),

-- Top 3 ranking by month
ranked as (
    select
        cam.month,
        cam.customer_id,
        cam.invoiced_amount_ttc,
        dense_rank() over (partition by cam.month order by cam.invoiced_amount_ttc desc) as monthly_rank -- Create a rank for each month and give the same place if we have a equal score
    from customer_amounts_monthly cam
)

select
    r.month,
    r.customer_id,
    c.customer_name,
    r.invoiced_amount_ttc,
    r.monthly_rank
from ranked r
join {{ ref('stg_customers') }} c using (customer_id)
where r.monthly_rank <= 3
order by r.month asc, r.monthly_rank asc, r.invoiced_amount_ttc desc, r.customer_id