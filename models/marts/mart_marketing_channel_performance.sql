with orders as (

    select *
    from {{ ref('fct_orders') }}

),

web_sessions as (

    select *
    from {{ ref('stg_web_sessions') }}

),

marketing_spend as (

    select *
    from {{ ref('stg_marketing_spend') }}

),

orders_by_channel as (

    select
        order_month,
        marketing_channel,
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as purchasing_customers,
        sum(net_revenue) as net_revenue
    from orders
    where order_status != 'cancelled'
    group by order_month, marketing_channel

),

sessions_by_channel as (

    select
        date_trunc('month', session_date) as session_month,
        marketing_channel,
        sum(sessions) as sessions,
        sum(product_views) as product_views,
        sum(add_to_carts) as add_to_carts,
        sum(checkouts) as checkouts,
        sum(purchases) as web_purchases
    from web_sessions
    group by 1, 2

),

spend_by_channel as (

    select
        date_trunc('month', spend_date) as spend_month,
        marketing_channel,
        sum(spend_amount) as spend_amount,
        sum(impressions) as impressions,
        sum(clicks) as clicks
    from marketing_spend
    group by 1, 2

),

final as (

    select
        coalesce(
            orders_by_channel.order_month,
            sessions_by_channel.session_month,
            spend_by_channel.spend_month
        ) as month,

        coalesce(
            orders_by_channel.marketing_channel,
            sessions_by_channel.marketing_channel,
            spend_by_channel.marketing_channel
        ) as marketing_channel,

        coalesce(orders_by_channel.total_orders, 0) as total_orders,
        coalesce(orders_by_channel.purchasing_customers, 0) as purchasing_customers,
        coalesce(orders_by_channel.net_revenue, 0) as net_revenue,

        coalesce(sessions_by_channel.sessions, 0) as sessions,
        coalesce(sessions_by_channel.product_views, 0) as product_views,
        coalesce(sessions_by_channel.add_to_carts, 0) as add_to_carts,
        coalesce(sessions_by_channel.checkouts, 0) as checkouts,
        coalesce(sessions_by_channel.web_purchases, 0) as web_purchases,

        coalesce(spend_by_channel.spend_amount, 0) as spend_amount,
        coalesce(spend_by_channel.impressions, 0) as impressions,
        coalesce(spend_by_channel.clicks, 0) as clicks,

        round(coalesce(orders_by_channel.net_revenue, 0) / nullif(coalesce(spend_by_channel.spend_amount, 0), 0), 4) as roas,
        round(coalesce(spend_by_channel.spend_amount, 0) / nullif(coalesce(spend_by_channel.clicks, 0), 0), 4) as cost_per_click,
        round(coalesce(spend_by_channel.clicks, 0) / nullif(coalesce(spend_by_channel.impressions, 0), 0), 4) as click_through_rate,
        round(coalesce(orders_by_channel.total_orders, 0) / nullif(coalesce(sessions_by_channel.sessions, 0), 0), 4) as order_conversion_rate,
        round(coalesce(sessions_by_channel.add_to_carts, 0) / nullif(coalesce(sessions_by_channel.sessions, 0), 0), 4) as add_to_cart_rate,
        round(coalesce(sessions_by_channel.checkouts, 0) / nullif(coalesce(sessions_by_channel.sessions, 0), 0), 4) as checkout_rate

    from orders_by_channel
    full outer join sessions_by_channel
        on orders_by_channel.order_month = sessions_by_channel.session_month
        and orders_by_channel.marketing_channel = sessions_by_channel.marketing_channel
    full outer join spend_by_channel
        on coalesce(orders_by_channel.order_month, sessions_by_channel.session_month) = spend_by_channel.spend_month
        and coalesce(orders_by_channel.marketing_channel, sessions_by_channel.marketing_channel) = spend_by_channel.marketing_channel

)

select *
from final