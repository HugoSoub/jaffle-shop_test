WITH

source AS (

    SELECT * FROM {{ source('ecom', 'raw_stores') }}

),

renamed AS (

    SELECT

        ----------  ids
        id AS location_id,

        ---------- text
        name AS location_name,

        ---------- numerics
        tax_rate,

        ---------- timestamps
        {{ dbt.date_trunc('day', 'opened_at') }} AS opened_date

    FROM source

)

SELECT * FROM renamed
