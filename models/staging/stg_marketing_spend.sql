{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ecommerce_raw', 'marketing_spend') }}

),

renamed as (

    select
        spend_date::date as spend_date,
        marketing_channel,
        campaign_name,
        spend::number(10,2) as spend_amount,
        impressions::integer as impressions,
        clicks::integer as clicks
    from source

)

select *
from renamed