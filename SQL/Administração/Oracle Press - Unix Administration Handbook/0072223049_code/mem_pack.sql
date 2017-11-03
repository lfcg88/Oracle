SET PAGESIZE 60;

COLUMN EXECUTIONS FORMAT 999,999,999;
COLUMN Mem_used   FORMAT 999,999,999;

SELECT SUBSTR(owner,1,10) Owner,
       SUBSTR(type,1,12)  Type,
       SUBSTR(name,1,20)  Name,
       executions,
       sharable_mem       Mem_used,
       SUBSTR(kept||' ',1,4)   "Kept?"
 FROM v$db_object_cache
 WHERE TYPE IN ('PACKAGE')
 ORDER BY EXECUTIONS DESC;

