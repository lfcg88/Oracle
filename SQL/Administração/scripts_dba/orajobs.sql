/* orajobs.sql */
/* Lista jobs que estao com status "broken" */

set echo off
set verify off
set feedb 1
set pause off
set pages 100

select  job,
	broken,
	failures,
	what
from sys.dba_jobs
where broken = 'Y'
or failures > 0
order by what
/

-- exit

