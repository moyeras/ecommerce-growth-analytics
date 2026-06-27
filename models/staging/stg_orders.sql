{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        order_date::date as order_date,
        status as order_status,
        currency,
        gross_revenue::number(10,2) as gross_revenue,
        discount_amount::number(10,2) as discount_amount,
        shipping_amount::number(10,2) as shipping_amount,
        order_total::number(10,2) as order_total,
        marketing_channel
    from source

)

select *
from renamed