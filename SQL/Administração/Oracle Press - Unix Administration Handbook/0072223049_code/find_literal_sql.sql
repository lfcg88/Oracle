spool t.lst;

SELECT 
   S.sql_text
FROM 
   v$sql  S,
   (select 
      substr(sql_text,1,&&size) sqltext, 
      count(*)
   from 
      v$sql
   group by 
      substr(sql_text,1,&&size)
   having
      count(*) > 10
        )  D
WHERE 
   substr(S.sql_text,1,&&size) =  D.sqltext
and sql_text not like '%insert%'
and sql_text not like '%EXPLAIN%'
and executions = 1
;

spool off;
