select
    month,
    marketing_channel,
    roas
from {{ ref('mart_marketing_channel_performance') }}
where roas < 0