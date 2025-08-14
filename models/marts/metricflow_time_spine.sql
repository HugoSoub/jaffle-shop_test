{{ config(materialized='table') }}
-- Daily time spine over the last 10 years until tomorrow
SELECT gs::date AS date_day
FROM generate_series(
    (current_date - interval '3650 days'),
    (current_date + interval '1 day'),
    interval '1 day'
) AS gs
