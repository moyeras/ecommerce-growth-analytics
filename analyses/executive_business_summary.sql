-- Executive Business Summary
-- eCommerce Growth Analytics Project

-- 1. Monthly revenue trend
select
    order_month,
    total_orders,
    unique_customers,
    round(net_revenue, 2) as net_revenue,
    round(avg_order_value, 2) as avg_order_value,
    refund_order_rate,
    cancellation_rate,
    month_over_month_growth_rate
from {{ ref('mart_monthly_revenue') }}
order by order_month;


-- 2. Best marketing channels by ROAS
select
    marketing_channel,
    round(sum(net_revenue), 2) as total_net_revenue,
    round(sum(spend_amount), 2) as total_spend,
    round(sum(net_revenue) / nullif(sum(spend_amount), 0), 2) as overall_roas,
    round(sum(total_orders) / nullif(sum(sessions), 0), 4) as order_conversion_rate
from {{ ref('mart_marketing_channel_performance') }}
group by marketing_channel
order by overall_roas desc;


-- 3. Customer value by acquisition channel
select
    acquisition_channel,
    count(*) as customers,
    round(sum(lifetime_value), 2) as total_lifetime_value,
    round(avg(lifetime_value), 2) as avg_lifetime_value,
    round(avg(total_orders), 2) as avg_orders_per_customer,
    round(avg(case when is_repeat_customer then 1 else 0 end), 4) as repeat_customer_rate
from {{ ref('mart_customer_lifetime_value') }}
group by acquisition_channel
order by avg_lifetime_value desc;


-- 4. Customer segment summary
select
    customer_segment,
    count(*) as customers,
    round(sum(lifetime_value), 2) as total_lifetime_value,
    round(avg(lifetime_value), 2) as avg_lifetime_value,
    round(avg(total_orders), 2) as avg_orders_per_customer
from {{ ref('mart_customer_lifetime_value') }}
group by customer_segment
order by total_lifetime_value desc;


-- 5. Product category performance
select
    category,
    count(distinct product_id) as products,
    sum(total_units_sold) as total_units_sold,
    round(sum(total_product_revenue), 2) as total_product_revenue,
    round(sum(estimated_gross_profit), 2) as estimated_gross_profit,
    round(sum(estimated_gross_profit) / nullif(sum(total_product_revenue), 0), 4) as estimated_gross_margin
from {{ ref('dim_products') }}
group by category
order by total_product_revenue desc;


-- 6. Top products by revenue
select
    product_name,
    category,
    metal_color,
    total_units_sold,
    round(total_product_revenue, 2) as total_product_revenue,
    round(estimated_gross_profit, 2) as estimated_gross_profit
from {{ ref('dim_products') }}
order by total_product_revenue desc
limit 10;