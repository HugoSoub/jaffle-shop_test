-- models/marts/metricflow_time_spine.sql
{{ config(materialized='table') }}

-- Time spine quotidienne sur les 10 dernières années jusqu'à demain
WITH spine AS (
  {{ dbt_utils.date_spine(
      datepart="day",
      start_date="(current_date - interval '3650 days')::date",
      end_date="(current_date + interval '1 day')::date"
  ) }}
)

SELECT date_day::date AS date_day FROM spine
