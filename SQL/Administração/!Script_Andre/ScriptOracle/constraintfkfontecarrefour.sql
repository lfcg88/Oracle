rem ***********
rem addfk.sql   - Script para adicionar constraint foreign key a tabela
rem Autor       - Edison Junqueira Liesse
rem Versao      - 1.0
rem ***********
rem
@init

define pr='&proprietario'
define tb='&tabela'
define cn='&nome_cnst'
define ac='&arquivo'

set term on feed off ver off head off pause off wrap off
set pages 0 long 2000 longc 2000 space 0 sqlc mixed lines 300

column dum1 noprint
column dum2 noprint
column dum3 noprint
column dum4 noprint

spool lst/fk&ac..sql

prompt /*************************************************
prompt ********** (fk) FOREIGN KEY CONSTRAINTS **********
prompt *************************************************/
prompt

select upper(x.table_name) dum1, x.constraint_name dum2, 0 dum3, 0 dum4
     , 'prompt Criando foreign key '||x.constraint_name||' da tabela '||x.table_name
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
UNION
select upper(x.table_name), x.constraint_name, 10, 0
     , 'ALTER TABLE "'||x.table_name||'" ADD'
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
UNION
select upper(x.table_name), x.constraint_name, 20, 0
     , '  CONSTRAINT '||x.constraint_name
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
and   x.constraint_name not like 'SYS_C%'
UNION
select upper(x.table_name), x.constraint_name, 30, y.position
     , decode(y.position,1,'  FOREIGN KEY ( "'||y.column_name||'"'
                         , '              , "'||y.column_name||'"')
from  all_cons_columns y, all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.owner                  = y.owner
and   x.constraint_name        = y.constraint_name
and   upper(x.table_name)      = upper(y.table_name)
and   x.constraint_type        = 'R'
UNION
select upper(x.table_name), x.constraint_name, 40, 9999, '  )'
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
UNION
select upper(x.table_name), x.constraint_name, 50, 0,'  REFERENCES "'||z.table_name||'"'
from  all_constraints z, all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.r_owner                = z.owner
and   x.r_constraint_name      = z.constraint_name
and   x.constraint_type        = 'R'
and   z.constraint_type        = 'P'
UNION
select upper(x.table_name), x.constraint_name, 60, w.position
     , decode(w.position,1,'             ( "'||w.column_name||'"'
			  ,'             , "'||w.column_name||'"')
from  all_cons_columns w, all_constraints z
    , all_cons_columns y, all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.owner                  = y.owner
and   x.constraint_name        = y.constraint_name
and   upper(x.table_name)      = upper(y.table_name)
and   x.r_owner                = z.owner
and   x.r_constraint_name      = z.constraint_name
and   z.owner                  = w.owner
and   z.constraint_name        = w.constraint_name
and   upper(z.table_name)      = upper(w.table_name)
and   w.position               = y.position
and   x.constraint_type        = 'R'
and   z.constraint_type        = 'P'
UNION
select upper(x.table_name), x.constraint_name, 70, 0, '  )'
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
UNION
select upper(x.table_name), x.constraint_name, 80, 0
     , '  ON DELETE '||x.delete_rule
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
and   x.delete_rule            = 'CASCADE'
UNION
select upper(x.table_name), x.constraint_name, 90, 0
     , '  DISABLE'
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
and   x.status                 = 'DISABLED'
UNION
select upper(x.table_name), x.constraint_name, 100, 0, '/'
from  all_constraints x
where x.owner                  = nvl(upper('&pr'),user)
and   upper(x.table_name)   like nvl(upper('&tb'),'%')
and   x.constraint_name     like nvl(upper('&cn'),'%')
and   x.constraint_type        = 'R'
order by 1,2,3,4
/
spool off