
/* orasnapz.sql                                           */
/* Lista data/hora de execucao do Snapshot no site remoto */

set echo off
set verify off
set feedb off
set head off
set pause off
set pages 0
set lines 80

def incremento="translate(substr(next,instr(next,'+'),99),') ',' ')"
def prox_refresh="last_refresh+decode(&incremento,'+1/2',0.5,'+1/4',0.25,'+1/3',0.333,&incremento)"

select 'Ult Ref ' || owner ||'.'|| name || ' em ' ||
       to_char(last_refresh,'dd/mm/yy hh24:mi'),
       'Prox (' || rtrim(next) || ') = ' ||
       to_char(start_with,' dd/mm/yy hh24:mi') ||
       decode(sign(start_with-sysdate),-1,' ***','')
from sys.dba_snapshots@&1
where owner in ('GEMCO')
order by start_with
/
-- exit
