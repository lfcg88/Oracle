select * 
  from dba_jobs 
 where broken = 'Y' 
   and schema_user not in ('SYS', 'SYSTEM')
/

PROMPT -----------------------------------------Refresh Children--------------------------------------------------------------------------------------------------------------------

select * 
  from dba_refresh_children a 
 where job in (select job 
                 from dba_jobs b 
                where b.broken = 'Y' 
                  and a.job = b.job)
/