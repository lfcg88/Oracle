rem $DBA/sesstats.sql
rem
rem Creates a report containing the statistics and the sql statement being
rem executed by a specific Oracle SID in the current database
rem
rem Requires that $DBA/dbosqli.sql first be executed to create the required
rem view and synonym.
rem
rem Last Change 01/16/97 by Brian Lomasky
rem
set echo off
set heading on
set pagesize 66
set termout on
set verify off

accept sid CHAR PROMPT 'Enter Oracle SID number to gather statistics for: '

set pagesize 9999
col username format a10
col name format a57 heading "Statistic name"
col value format 999999999 heading "Value"
set termout off

column adate new_value now
column dbname1 new_value dbname noprint

select to_char(sysdate, 'MM/DD/YY') adate, name dbname1 from v$database;
ttitle left &now center 'SESSTATS - Statistics for database ' &&dbname ' SID ' -
'&SID' skip 2
set concat +

spool c:\sesstats.lis
set concat .

select /*+ use_nl(c,a) */ a.username, b.name, c.value
from v$session a, v$statname b, v$sesstat c
where a.sid = c.sid and b.statistic# = c.statistic# and a.sid = &SID and
c.value > 0
order by b.name;

column sql_text format a64 heading "SQL Text"
select sql_text from dbo_sql_text where sid = &SID order by piece;

spool off