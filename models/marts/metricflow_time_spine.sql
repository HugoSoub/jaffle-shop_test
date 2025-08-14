-- metricflow_time_spine.sql
WITH

days AS (

    --for BQ adapters use "DATE('01/01/2000','mm/dd/yyyy')"
    {{ dbt_date.get_base_dates(n_dateparts=365*10, datepart="day") }}),

cast_to_date AS (

    SELECT cast(date_day AS date) AS date_day

    FROM days

)

SELECT * FROM cast_to_date
