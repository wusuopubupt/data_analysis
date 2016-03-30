-- PV stat event_day=20160304 and channel_from=github and ua like '%chrome%'
SELECT count(1)
FROM tbl_access_log
WHERE
event_day='20160304'
AND channel_from='github'
AND user_agent LIKE '%chrome%'

-- GROUP BY channel_from
SELECT channel_from,count(1)
FROM tbl_access_log
WHERE event_day='20160304'
GROUP BY channel_from
LIMIT 10

-- UV stat group by channel_from
SELECT channel_from, count(distinct uid)
FROM tbl_access_log
WHERE event_day='20160304'
GROUP BY channel_from
