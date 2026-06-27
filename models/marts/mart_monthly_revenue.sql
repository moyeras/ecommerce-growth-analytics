with orders as (

    select *
    from {{ ref('fct_orders') }}

),

monthly as (

    select
        order_month,
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as unique_customers,

        sum(gross_revenue) as gross_revenue,
        sum(discount_amount) as discount_amount,
        sum(shipping_amount) as shipping_amount,
        sum(total_refund_amount) as refunded_amount,
        sum(net_revenue) as net_revenue,

        avg(net_revenue) as avg_order_value,

        count_if(order_status = 'completed') as completed_orders,
        count_if(order_status = 'refunded') as refunded_orders,
        count_if(order_status = 'cancelled') as cancelled_orders

    from orders
    group by order_month

),

final as (

    select
        order_month,
        total_orders,
        unique_customers,
        completed_orders,
        refunded_orders,
        cancelled_orders,

        gross_revenue,
        discount_amount,
        shipping_amount,
        refunded_amount,
        net_revenue,
        avg_order_value,

        round(refunded_orders / nullif(total_orders, 0), 4) as refund_order_rate,
        round(cancelled_orders / nullif(total_orders, 0), 4) as cancellation_rate,

        lag(net_revenue) over (order by order_month) as previous_month_net_revenue,

        round(
            (net_revenue - lag(net_revenue) over (order by order_month))
            / nullif(lag(net_revenue) over (order by order_month), 0),
            4
        ) as month_over_month_growth_rate

    from monthly

)

select *
from final