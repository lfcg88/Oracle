rem *********
rem addpk.sql - Script para adicionar primary key a tabela
rem Autor     - Edison Junqueira Liesse
rem Versao    - 1.0
rem *********
rem
@init

define pr='&proprietario'
define tb='&tabela'
define cn='&nome_cnst'
define ac='&arquivo'
DEFINE TAS='&TABLESPACE'
define tai='&tabind'

set term on feed off ver off head off pause off wrap off
set pages 0 long 2000 longc 2000 space 0 sqlc mixed array 1

column dum1 noprint
column dum2 noprint
column dum3 noprint
column dum4 noprint

spool c:\pk&ac..sql

prompt /*************************************************
prompt ********** (pk) PRIMARY KEY CONSTRAINTS **********
prompt *************************************************/
prompt

select upper(x.table_name) dum1, x.constraint_name dum2, 0 dum3, 0 dum4
     , 'prompt Criando a primary key '||x.constraint_name||' da tabela "'||x.table_name||'"'
 from  all_constraints x
 where x.owner = nvl(upper('&pr'),user)
 and   upper(x.table_name) like nvl(upper('&tb'),'%')
 and   x.constraint_name like nvl(upper('&cn'),'%')
 and   x.constraint_type = 'P'
UNION
select upper(x.table_name), x.constraint_name, 10, 0
     , 'ALTER TABLE "'||x.table_name||'" ADD' 
 from  all_constraints x
 where x.owner = nvl(upper('&pr'),user)
 and   upper(x.table_name) like nvl(upper('&tb'),'%')
 and   x.constraint_name like nvl(upper('&cn'),'%')
 and   x.constraint_type = 'P'
UNION
select upper(x.table_name), x.constraint_name, 20, 0
     , '  CONSTRAINT '||
     decode(substr(x.constraint_name,1,5),'SYS_C',substr(upper(x.table_name),1,27)||'_PK',x.constraint_name)
 from  all_constraints x
 where x.owner = nvl(upper('&pr'),user)
 and   upper(x.table_name) like nvl(upper('&tb'),'%')
 and   x.constraint_name like nvl(upper('&cn'),'%')
 and   x.constraint_type = 'P'
-- and   x.constraint_name not like 'SYS_C%'
UNION
select upper(x.table_name), x.constraint_name, 30, y.position
     , decode(y.position,1,'  PRIMARY KEY ( "'||y.column_name||'"'
                          ,'              , "'||y.column_name||'"')
from   all_cons_columns y, all_constraints x
 where x.owner = nvl(upper('&pr'),user)
 and   upper(x.table_name) like nvl(upper('&tb'),'%')
 and   x.constraint_name like nvl(upper('&cn'),'%')
 and   x.owner = y.owner
 and   x.constraint_name = y.constraint_name
 and   upper(x.table_name)      = upper(y.table_name)
 and   x.constraint_type = 'P'
UNION
select upper(x.table_name), x.constraint_name, 40, 0
     , '  )'
from  all_constraints x
where x.owner = nvl(upper('&pr'),user)
and   upper(x.table_name) like nvl(upper('&tb'),'%')
and   x.constraint_name like nvl(upper('&cn'),'%')
and   x.constraint_type = 'P'
UNION
select upper(x.table_name), x.constraint_name, 50, 0
     , '  DISABLE'
from  all_constraints x
where x.owner = nvl(upper('&pr'),user)
and   upper(x.table_name) like nvl(upper('&tb'),'%')
and   x.constraint_name like nvl(upper('&cn'),'%')
and   x.constraint_type = 'P'
and   x.status = 'DISABLED'
UNION
select upper(x.table_name), x.constraint_name, 60, 1
     , '  USING INDEX PCTFREE '||to_char(pct_free)
from  all_constraints x, all_indexes i
where i.index_name = x.constraint_name
and   i.owner      = x.owner
and   x.owner = nvl(upper('&pr'),user)
and   upper(x.table_name) like nvl(upper('&tb'),'%')
and   x.constraint_name like nvl(upper('&cn'),'%')
and   x.constraint_type = 'P'
UNION
select upper(x.table_name), x.constraint_name, 60, 2
     , '              TABLESPACE '||NVL('&TAI',i.tablespace_name)
from  all_constraints x, all_indexes i
where i.index_name = x.constraint_name
and   i.owner      = x.owner
and   x.owner = nvl(upper('&pr'),user)
and   upper(x.table_name) like nvl(upper('&tb'),'%')
and   x.constraint_name like nvl(upper('&cn'),'%')
and   x.constraint_type = 'P'
UNION
select upper(x.table_name), x.constraint_name, 60, 3
     , '              INITRANS '||to_char(i.ini_trans)||'  MAXTRANS '||to_char(i.max_trans)
from  all_constraints x, all_indexes i
where i.index_name = x.constraint_name
and   i.owner      = x.owner
and   x.owner = nvl(upper('&pr'),user)
and   upper(x.table_name) like nvl(upper('&tb'),'%')
and   x.constraint_name like nvl(upper('&cn'),'%')
and   x.constraint_type = 'P'
UNION
select upper(x.table_name), x.constraint_name, 60, 4
     , '              STORAGE ( INITIAL '||
       DECODE(SIGN(500000-sum(e.bytes)),-1,500000,trunc(sum(e.bytes)*.2))
		               ||' NEXT '||
       DECODE(SIGN(500000-sum(e.bytes)*.2),-1,500000,trunc(sum(e.bytes)*.1))
		           ||' PCTINCREASE 0 maxextents unlimited)'  --||to_char(i.pct_increase)||' )'
from  all_constraints x, all_indexes i, dba_extents e
where i.index_name = x.constraint_name
and   i.owner      = x.owner
and   i.owner      = e.owner
and   i.index_name = e.segment_name
and   x.owner = nvl(upper('&pr'),user)
and   upper(x.table_name) like nvl(upper('&tb'),'%')
and   x.constraint_name like nvl(upper('&cn'),'%')
and   x.constraint_type = 'P'
group by upper(x.table_name), x.constraint_name
UNION
select upper(x.table_name), x.constraint_name, 70, 0
     , '/'
from  all_constraints x
where x.owner = nvl(upper('&pr'),user)
and   upper(x.table_name) like nvl(upper('&tb'),'%')
and   x.constraint_name like nvl(upper('&cn'),'%')
and   x.constraint_type = 'P'
order by 1,2,3,4
/
spool off

--host sed "s/ *$//g" $HOME/tmp/alterpk.tmp > $HOME/tmp/sql/alterpk.sql
--host rm $HOME/tmp/alterpk.tmp
 
