
/* orasnap2.sql                                           */
/* Lista data/hora de execucao do Snapshot no site remoto */
/* Parm 1: nome do snapshot                               */

set echo off
set verify off
set feedb off
set head off
set pause off
set pages 0

def prox_refresh="last_refresh+decode(rtrim(substr(next,8,99)),'+1/2',0.5,'+1/4',0.25,'+1/3',0.333,substr(next,8,99))"

select * from global_name;

select 'Ult refresh ' || name || ' em ' ||
       to_char(last_refresh,'DD/MM/YYYY-HH24:MI') ||
       ' Prox (' || rtrim(next) || ') = ' ||
       to_char(start_with,'DD/MM/YYYY-hh24:MI') ||
       decode(sign(start_with-sysdate),-1,' ***','')
from sys.dba_snapshots
where name = '&1'
/

-- exit

