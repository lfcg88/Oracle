rem memory.sql - Lists all packages and in-memory objects.
set pagesize 60;

ttitle "dbname Database|Shared Pool Objects";
spool memory.lst

column executions format 999,999,999;
column Mem_used   format 999,999,999;

SELECT SUBSTR(owner,1,10) Owner,
       SUBSTR(type,1,12)  Type,
       SUBSTR(name,1,20)  Name,
       executions,
       sharable_mem       Mem_used,
       SUBSTR(kept||' ',1,4)   "Kept?"
  FROM v$db_object_cache
 WHERE type in ('TRIGGER','PROCEDURE','PACKAGE BODY','PACKAGE')
 ORDER BY executions desc;
