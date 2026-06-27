{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'web_sessions') }}

),

renamed as (

    select
        session_id,
        nullif(customer_id, '') as customer_id,
        session_date::date as session_date,
        marketing_channel,
        device_type,
        sessions::integer as sessions,
        product_views::integer as product_views,
        add_to_carts::integer as add_to_carts,
        checkouts::integer as checkouts,
        purchases::integer as purchases
    from source

)

select *
from renamed