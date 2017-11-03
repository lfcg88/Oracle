
ALTER TABLE "SYS"."EMPLOYEES1" SHRINK SPACE;
ALTER TABLE "SYS"."EMPLOYEES2" SHRINK SPACE;
ALTER TABLE "SYS"."EMPLOYEES3" SHRINK SPACE;
 
-- 48.10%
select (select sum(bytes) 
        from dba_extents 
        where tablespace_name='TBSALERT')*100/5177344
from dual;
