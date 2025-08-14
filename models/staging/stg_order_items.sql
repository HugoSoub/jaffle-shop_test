WITH

source AS (

    SELECT * FROM {{ source('ecom', 'raw_items') }}

),

renamed AS (

    SELECT

        ----------  ids
        id AS order_item_id,
        order_id,
        sku AS product_id

    FROM source

)

SELECT * FROM renamed
