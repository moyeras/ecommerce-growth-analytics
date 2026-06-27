with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

orders as (

    select *
    from {{ ref('stg_orders') }}

),

products as (

    select *
    from {{ ref('stg_products') }}

),

joined as (

    select
        order_items.order_item_id,
        order_items.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        orders.marketing_channel,
        order_items.product_id,
        products.product_name,
        products.category,
        products.metal_color,
        order_items.quantity,
        order_items.unit_price,
        order_items.line_total,
        products.unit_cost,
        order_items.quantity * products.unit_cost as estimated_item_cost,
        order_items.line_total - (order_items.quantity * products.unit_cost) as estimated_gross_profit
    from order_items
    left join orders
        on order_items.order_id = orders.order_id
    left join products
        on order_items.product_id = products.product_id

)

select *
from joined