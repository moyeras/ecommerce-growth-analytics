with customers as (

    select *
    from {{ ref('stg_customers') }}

),

orders as (

    select *
    from {{ ref('int_order_financials') }}

),

customer_metrics as (

    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as total_orders,
        sum(net_revenue) as lifetime_revenue,
        avg(net_revenue) as avg_order_net_revenue
    from orders
    where order_status != 'cancelled'
    group by customer_id

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customers.email,
        customers.country,
        customers.acquisition_channel,
        customers.created_at,

        customer_metrics.first_order_date,
        customer_metrics.most_recent_order_date,
        coalesce(customer_metrics.total_orders, 0) as total_orders,
        coalesce(customer_metrics.lifetime_revenue, 0) as lifetime_revenue,
        coalesce(customer_metrics.avg_order_net_revenue, 0) as avg_order_net_revenue,

        case
            when coalesce(customer_metrics.total_orders, 0) >= 2 then true
            else false
        end as is_repeat_customer

    from customers
    left join customer_metrics
        on customers.customer_id = customer_metrics.customer_id

)

select *
from final