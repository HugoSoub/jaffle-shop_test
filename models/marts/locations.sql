WITH

locations AS (

    SELECT * FROM {{ ref('stg_locations') }}

)

SELECT * FROM locations
