{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'payments') }}

),

renamed as (

    select
        payment_id,
        order_id,
        payment_date::date as payment_date,
        payment_method,
        amount::number(10,2) as payment_amount,
        payment_status
    from source

)

select *
from renamed