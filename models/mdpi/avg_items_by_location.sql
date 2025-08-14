-- AUTHOR : Hugo Soubeyrat
-- Average number of items per order, by location

-- For know how many items we have for each order
with items_per_order as (
  select
    oi.order_id,
    count(*) as items_in_order    -- We don't have a column of quantity so i expect 1 row = 1 qty
  from {{ ref('stg_order_items') }} oi
  group by 1
),

orders_with_location as (
  select
    o.order_id,
    o.location_id
  from {{ ref('stg_orders') }} o
),

locations as (
  select
    l.location_id,
    l.location_name
  from {{ ref('stg_locations') }} l
)

-- Calculate the average number of items per order for each location
select
  loc.location_id,
  loc.location_name,
  avg(ipo.items_in_order)::numeric(18,2) as avg_items_per_order   -- ::numeric(18,2) converts the result to a number with a maximum of 18 digits and 2 decimal places.
from items_per_order ipo
join orders_with_location ow on ow.order_id = ipo.order_id
join locations loc on loc.location_id = ow.location_id
group by loc.location_id, loc.location_name