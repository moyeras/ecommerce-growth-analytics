{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'refunds') }}

),

renamed as (

    select
        refund_id,
        order_id,
        refund_date::date as refund_date,
        refund_amount::number(10,2) as refund_amount,
        refund_reason
    from source
    where refund_id is not null

)

select *
from renamed