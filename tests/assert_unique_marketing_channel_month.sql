select
    month,
    marketing_channel,
    count(*) as row_count
from {{ ref('mart_marketing_channel_performance') }}
group by month, marketing_channel
having count(*) > 1