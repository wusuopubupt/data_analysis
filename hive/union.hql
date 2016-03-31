-- union的用法(要求2个select操作的列完全相同)

-- Union，对两个结果集进行并集操作，不包括重复行，同时进行默认规则的排序；
-- Union All，对两个结果集进行并集操作，包括重复行，不进行排序；
-- Intersect，对两个结果集进行交集操作，不包括重复行，同时进行默认规则的排序；
-- Minus，对两个结果集进行差操作，不包括重复行，同时进行默认规则的排序。


-- table_A:

-- id var1 var2
-- 1   a    b
-- 2   c    d

-- Table_B:

-- id var1 var2  
-- 2   c    d
-- 3   e    f
-- 4   g    h

SELECT unioned.id, unioned.var1, unioned.var2
FROM (
  SELECT a.id, a.var1, a.var2  
  FROM table_A a  
  UNION ALL  
  SELECT b.id, b.var1, b.var2  
  from table_B b
) unioned;

-- 结果:

-- 1   a    b
-- 2   c    d
-- 2   c    d -- union all 包含重复行
-- 3   e    f
-- 4   g    h
