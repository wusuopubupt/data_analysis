-- hive regex_extract()函数用法
--
--  函数描述:
--
--  regexp_extract(str, regexp[, idx]) - extracts a group that matches regexp
--  
--  
--  参数解释:
--  
--  str     被解析的字符串
--  regexp  正则表达式
--  idx     返回结果 取表达式的哪一部分  默认值为1。
--  0       表示把整个正则表达式对应的结果全部返回
--  1       表示返回正则表达式中第一个() 对应的结果 以此类推 

SELECT regexp_extract('x=a3&x=18abc&x=2&y=3&x=4','x=([0-9]+)([a-z]+)',1) 
FROM tbl_access_log

-- 18

