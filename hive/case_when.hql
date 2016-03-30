-- CASE WHEN语法：http://blog.sina.com.cn/s/blog_7de0b6230100ua06.html

SELECT
    CASE action_type
    WHEN "click" THEN "点击"
    WHEN "imp"   THEN "展示"
    WHEN "play"  THEN "播放"
    WHEN "close" THEN "关闭"
    ELSE NULL
    END AS action_type,"\t",
    count(1) AS pv,"\t",
    count(distinct user_id) AS uv
FROM tbl_access_log
WHERE event_day='20160304'
GROUP BY action_type;

--  点击    100     96
--  展示    109     76
--  播放    120     98
--  关闭    117     81
