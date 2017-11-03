
/* orasnap1.sql                                              */
/* Lista data/hora de acesso ao Snapshot Log da maquina rjd0 */
/* Parm 1: nome da tabela master                             */

set echo off
set verify off
set feedb off
set head off
set pause off
set pages 0

select * from global_name;

select 'Log Snapshot de ' || master || ' acessado em ' || 
       to_char(current_snapshots,'dd/mm/yy hh24:mi')
from sys.dba_snapshot_logs
where master = '&1'
order by master,current_snapshots;

-- exit
