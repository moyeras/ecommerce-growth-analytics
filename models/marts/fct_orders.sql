with order_financials as (

    select *
    from {{ ref('int_order_financials') }}

),

final as (

    select
        order_id,
        customer_id,
        order_date,
        date_trunc('month', order_date) as order_month,
        order_status,
        marketing_channel,

        gross_revenue,
        discount_amount,
        shipping_amount,
        order_total,
        total_paid_amount,
        total_refund_amount,
        net_revenue,
        has_refund,

        case
            when order_status = 'completed' then true
            else false
        end as is_completed_order,

        case
            when order_status = 'cancelled' then true
            else false
        end as is_cancelled_order

    from order_financials

)

select *
from final