set trimspool on
set linesize 1000
set pagesize 24

column username format a10 wrap
column name     format a45 wrap
column value    format 999G999G999g999
col sid_serial  format a10

break on username on sid_serial

select s.username, 
       s.sid||','||s.SERIAL# sid_serial,
       n.name,
       t.value
from v$session     s,
     v$statname    n,
     v$sesstat     t
where n.statistic# = t.statistic#
  and t.sid        = s.sid
  and t.value > 0
  and s.username = upper ('&1')
order by s.username, sid_serial, n.name;

clear columns;
clear breaks;
