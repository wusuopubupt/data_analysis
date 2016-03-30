-- Find out the top 50 queries.

SELECT event_query, COUNT(event_query) AS query_count 
FROM tbl_query 
WHERE event_day='20160304' AND event_hour='12' 
GROUP BY event_query 
ORDER BY query_count DESC
LIMIT 50;
