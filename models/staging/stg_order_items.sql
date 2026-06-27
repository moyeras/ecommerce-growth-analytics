{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'order_items') }}

),

renamed as (

    select
        order_item_id,
        order_id,
        product_id,
        quantity::integer as quantity,
        unit_price::number(10,2) as unit_price,
        line_total::number(10,2) as line_total
    from source

)

select *
from renamed