WITH

source AS (

    SELECT * FROM {{ source('ecom', 'raw_products') }}

),

renamed AS (

    SELECT

        ----------  ids
        sku AS product_id,

        ---------- text
        name AS product_name,
        type AS product_type,
        description AS product_description,

        ---------- numerics
        {{ cents_to_dollars('price') }} AS product_price,

        ---------- booleans
        coalesce(type = 'jaffle', false) AS is_food_item,

        coalesce(type = 'beverage', false) AS is_drink_item

    FROM source

)

SELECT * FROM renamed
