WITH

supplies AS (

    SELECT * FROM {{ ref('stg_supplies') }}

)

SELECT * FROM supplies
