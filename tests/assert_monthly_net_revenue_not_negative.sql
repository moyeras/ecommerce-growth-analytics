select
    order_month,
    net_revenue
from {{ ref('mart_monthly_revenue') }}
where net_revenue < 0