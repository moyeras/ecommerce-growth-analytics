with customers as (

    select *
    from {{ ref('dim_customers') }}

),

orders as (

    select *
    from {{ ref('fct_orders') }}
    where order_status != 'cancelled'

),

customer_orders as (

    select
        customer_id,
        order_id,
        order_date,
        order_month,
        net_revenue,

        row_number() over (
            partition by customer_id
            order by order_date
        ) as order_sequence_number,

        lag(order_date) over (
            partition by customer_id
            order by order_date
        ) as previous_order_date

    from orders

),

customer_summary as (

    select
        customer_id,

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,

        count(distinct order_id) as total_orders,
        sum(net_revenue) as lifetime_value,
        avg(net_revenue) as average_order_value,

        count_if(order_sequence_number = 1) as first_orders,
        count_if(order_sequence_number > 1) as repeat_orders,

        datediff('day', min(order_date), max(order_date)) as customer_lifespan_days,

        avg(
            case
                when previous_order_date is not null
                then datediff('day', previous_order_date, order_date)
            end
        ) as avg_days_between_orders

    from customer_orders
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

        customer_summary.first_order_date,
        customer_summary.most_recent_order_date,

        coalesce(customer_summary.total_orders, 0) as total_orders,
        coalesce(customer_summary.lifetime_value, 0) as lifetime_value,
        coalesce(customer_summary.average_order_value, 0) as average_order_value,
        coalesce(customer_summary.repeat_orders, 0) as repeat_orders,

        coalesce(customer_summary.customer_lifespan_days, 0) as customer_lifespan_days,
        customer_summary.avg_days_between_orders,

        case
            when coalesce(customer_summary.total_orders, 0) = 0 then 'no_purchase'
            when coalesce(customer_summary.total_orders, 0) = 1 then 'one_time_customer'
            when coalesce(customer_summary.total_orders, 0) between 2 and 3 then 'repeat_customer'
            when coalesce(customer_summary.total_orders, 0) >= 4 then 'loyal_customer'
        end as customer_segment,

        case
            when coalesce(customer_summary.total_orders, 0) >= 2 then true
            else false
        end as is_repeat_customer

    from customers
    left join customer_summary
        on customers.customer_id = customer_summary.customer_id

)

select *
from final