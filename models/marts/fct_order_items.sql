with order_items as (

    select *
    from {{ ref('int_order_items_enriched') }}

),

final as (

    select
        order_item_id,
        order_id,
        customer_id,
        order_date,
        date_trunc('month', order_date) as order_month,
        order_status,
        marketing_channel,

        product_id,
        product_name,
        category,
        metal_color,

        quantity,
        unit_price,
        line_total,
        unit_cost,
        estimated_item_cost,
        estimated_gross_profit

    from order_items

)

select *
from final