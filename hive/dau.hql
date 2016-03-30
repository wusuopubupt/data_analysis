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
SELECT channel_from, count(distinct user_id)
FROM tbl_access_log
WHERE event_day='20160304'
GROUP BY channel_from

-- next day retention of 20160304
SELECT count(*)
FROM
(
    SELECT DISTINCT user_id 
    FROM tbl_access_log
    WHERE event_day='20160304'
    AND action_type='install' -- install at 20160304
    AND channel_from='github'
    AND user_agent LIKE '%chrome%'
)tb1
Left Semi Join
(
    SELECT DISTINCT user_id
    FROM tbl_access_log 
    WHERE event_day='20160305'
    AND action_type='launch'  -- launch at 20150305
    AND channel_from='github'
    AND user_agent LIKE '%chrome%'
)tb2
ON tb1.user_id=tb2.user_id;
