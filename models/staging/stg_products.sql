{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'products') }}

),

renamed as (

    select
        product_id,
        product_name,
        category,
        metal_color,
        retail_price::number(10,2) as retail_price,
        unit_cost::number(10,2) as unit_cost,
        is_active::boolean as is_active
    from source

)

select *
from renamed