{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'customers') }}

),

renamed as (

    select
        customer_id,
        first_name,
        last_name,
        lower(email) as email,
        country,
        acquisition_channel,
        created_at::date as created_at
    from source

)

select *
from renamed