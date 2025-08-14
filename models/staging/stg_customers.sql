WITH

source AS (

    SELECT * FROM {{ source('ecom', 'raw_customers') }}

),

renamed AS (

    SELECT

        ----------  ids
        id AS customer_id,

        ---------- text
        name AS customer_name

    FROM source

)

SELECT * FROM renamed
