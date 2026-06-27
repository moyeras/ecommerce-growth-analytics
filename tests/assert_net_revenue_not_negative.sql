select
    order_id,
    net_revenue
from {{ ref('int_order_financials') }}
where net_revenue < 0