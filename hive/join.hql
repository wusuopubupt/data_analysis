-- left outer join和left semi join的区别
-- 参考： http://www.crazyant.net/1470.html
-- 
-- table_1       table_2

-- id    name    id  class
-- 1     a        1    Java
-- 2     b        1    Python
-- 3     c        2    C
--                2    PHP
--                4    Java 


SELECT table_1.id, table_1.name, table_2.class 
FROM table_1 
LEFT OUTER JOIN table_2
ON table_1.id=table_2.id

-- 结果(left outer join左边表的数据都列出来了，如果右边表没有对应的列，则写成了NULL值, 同时注意到，如果左边的主键在右边找到了N条，那么结果也是会叉乘得到N条的，比如这里主键为1的显示了右边的2条)

-- 1   a    Java
-- 1   a    Python
-- 2   a    C 
-- 2   a    PHP
-- 3   c    NULL


SELECT *
FROM table_1
LEFT SEMI JOIN table_2
ON table_1.id=table_2.id

-- 结果(left semi join 只打印出了左边的表中的列，规律是如果主键在右边表中存在，则打印，否则过滤掉了)
-- 类似IN语句

-- 1   a    
-- 2   a   

