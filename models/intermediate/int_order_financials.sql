with orders as (

    select *
    from {{ ref('stg_orders') }}

),

payments as (

    select
        order_id,
        sum(payment_amount) as total_paid_amount
    from {{ ref('stg_payments') }}
    group by order_id

),

refunds as (

    select
        order_id,
        sum(refund_amount) as total_refund_amount
    from {{ ref('stg_refunds') }}
    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        orders.marketing_channel,
        orders.gross_revenue,
        orders.discount_amount,
        orders.shipping_amount,
        orders.order_total,

        coalesce(payments.total_paid_amount, 0) as total_paid_amount,
        coalesce(refunds.total_refund_amount, 0) as total_refund_amount,

        case
            when orders.order_status = 'cancelled' then 0
            else orders.order_total - coalesce(refunds.total_refund_amount, 0)
        end as net_revenue,

        case
            when coalesce(refunds.total_refund_amount, 0) > 0 then true
            else false
        end as has_refund

    from orders
    left join payments
        on orders.order_id = payments.order_id
    left join refunds
        on orders.order_id = refunds.order_id

)

select *
from final