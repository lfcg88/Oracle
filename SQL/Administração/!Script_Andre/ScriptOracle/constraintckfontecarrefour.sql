rem *********
rem addck.sql - Script para adicionar constraint check na tabela
rem Autor     - Edison Junqueira Liesse
rem Versao    - 1.0
rem *********
rem
@init

define pr='&proprietario'
define tb='&tabela'
define cn='&nome_cnst'
define ac='&arquivo'

set term on feed off ver off head off pause off wrap off array 5
set pages 0 long 2000 longc 2000 space 0 sqlc mixed

column dum1 noprint
column dum2 noprint
column dum3 noprint
column dum4 noprint
column a format a78 fold_after
column b format a78 fold_after
column c format a10
column d format a60 wor
column e format a10 fold_before
column f format a1 fold_before
column g format a78 fold_after

spool lst/ck&ac..sql

prompt /*******************************************
prompt ********** (ck) CHECK CONSTRAINTS **********
prompt *******************************************/
prompt

select upper(x.table_name) dum1, 10 dum2, x.constraint_name dum3, 0 dum4
  ,'prompt Criando check constraint '||x.constraint_name||' da tabela '||x.table_name g
  ,'ALTER TABLE "'||x.table_name||'"' a,
  '  ADD CONSTRAINT '||x.constraint_name||decode(x.status,'DISABLED',' DISABLE') b,
  '  CHECK ( ' c,x.search_condition d,'  )' e,
  '/' f
from all_constraints x
where x.owner                 = nvl(upper('&pr'),user)
and   upper(x.table_name)  like nvl(upper('&tb'),'%')
and   x.constraint_name    like nvl(upper('&cn'),'%')
and   x.constraint_type       = 'C'
and   exists (select 1 from loader_constraint_info l
	      where l.owner                = x.owner
	      and   upper(l.table_name)    = upper(x.table_name)
	      and   l.constraint_name      = x.constraint_name
	      and   l.type                 = 1)
order by 1,2,3,4
/
spool off

--host sed "s/ *$//g" $HOME/tmp/alterck.tmp > $HOME/tmp/sql/alterck.sql
--host rm $HOME/tmp/alterck.tmp

