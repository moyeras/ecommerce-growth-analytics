with products as (

    select *
    from {{ ref('stg_products') }}

),

order_items as (

    select *
    from {{ ref('int_order_items_enriched') }}

),

product_metrics as (

    select
        product_id,
        count(distinct order_id) as total_orders,
        sum(quantity) as total_units_sold,
        sum(line_total) as total_product_revenue,
        sum(estimated_gross_profit) as estimated_gross_profit
    from order_items
    where order_status != 'cancelled'
    group by product_id

),

final as (

    select
        products.product_id,
        products.product_name,
        products.category,
        products.metal_color,
        products.retail_price,
        products.unit_cost,
        products.is_active,

        coalesce(product_metrics.total_orders, 0) as total_orders,
        coalesce(product_metrics.total_units_sold, 0) as total_units_sold,
        coalesce(product_metrics.total_product_revenue, 0) as total_product_revenue,
        coalesce(product_metrics.estimated_gross_profit, 0) as estimated_gross_profit

    from products
    left join product_metrics
        on products.product_id = product_metrics.product_id

)

select *
from final