rem ***********
rem criaind.sql - Script para criacao de indices
rem Autor       - Carlos Derinarde
rem Versao      - 1.0
rem ***********
rem
@init

prompt /*******************************************
prompt ************** (ind) INDEXES ***************
prompt *******************************************/
prompt

define tb='&tabela'
define pr='&proprietario'
define ac='&arquivo'
define tab='&tablespace'
define tai='&tabind'

col dum1 noprint
col dum2 noprint
col dum3 noprint

set termout off feed off ver off echo off hea off pages 0 pause off
set termout on

spool c:\ind&ac..sql

select i.index_name dum1, 0 dum2, 0 dum3,
       'prompt Criando o indice '||i.index_name||' da tabela '||i.table_name
from  DBA_indexes i
where i.owner                like nvl(upper('&pr'),'%')
and   upper(i.table_name)    like nvl(upper('&tb'),'%')
and   not i.index_name         in ( select  c.constraint_name
	 		                    from  DBA_constraints c
                                      where c.owner = i.owner
                                      and   c.constraint_type = 'P'
			                    and   i.index_name      = c.constraint_name)
union
select index_name,10, 0,
'create'||substr(decode(uniqueness,'UNIQUE',' unique',''),1,7)||
' index '||index_name||' on "'||table_name||'"'
from  DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner = DBA_indexes.owner
                                    and   constraint_type = 'P'
			                  and   index_name      = constraint_name) 
union
select index_name, 20, 0, '('
from  DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner = DBA_indexes.owner
                                    and   constraint_type = 'P'
			                  and   index_name      = constraint_name) 
union
select index_name, 30, column_position,
       decode(column_position,1,'  ',', ')||'"'||column_name||'"'
from  DBA_ind_columns c
where c.index_owner        like nvl(upper('&pr'),'%')
and   upper(c.table_name)  like nvl(upper('&tb'),'%')
and   exists (select 1
	         from  DBA_indexes i
               where i.owner                 = c.index_owner
               and   upper(i.table_name)     = upper(c.table_name)
	         and   i.index_name            = c.index_name
	         and   upper(i.table_name)  like nvl(upper('&tb'),'%'))
and not c.index_name         in (select  constraint_name
                                   from  DBA_constraints x
                                   where x.owner            = c.index_owner
                                   and   x.constraint_type  = 'P'
			                 and   c.index_name       = x.constraint_name)
union
select index_name, 40, 99, ') '
from DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner   = DBA_indexes.owner
                                    and   constraint_type         = 'P'
			                  and   index_name              = constraint_name) 
union
select index_name, 50, 99, 'Pctfree     5'  --||pct_free
from DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner   = DBA_indexes.owner
                                    and   constraint_type         = 'P'
			                  and   index_name              = constraint_name) 
union
select index_name, 60, 99, 'Initrans    '||nvl(ini_trans,5)
from DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner   = DBA_indexes.owner
                                    and   constraint_type         = 'P'
			                  and   index_name              = constraint_name) 
union
select index_name, 70, 99, 'Maxtrans    '||nvl(max_trans,255)
from DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner   = DBA_indexes.owner
                                    and   constraint_type         = 'P'
			                  and   index_name              = constraint_name) 
union
select index_name, 80, 99, 'Tablespace  '||
       nvl(upper('&tai'),tablespace_name)
from DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner   = DBA_indexes.owner
                                    and   constraint_type         = 'P'
			                  and   index_name              = constraint_name) 
union
select index_name, 90, 99, 'Storage'
from DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner   = DBA_indexes.owner
                                    and   constraint_type         = 'P'
			                  and   index_name              = constraint_name) 
union
select index_name,100, 99, '('
from DBA_indexes
where owner                like nvl(upper('&pr'),'%')
and   upper(table_name)    like nvl(upper('&tb'),'%')
and   not index_name         in ( select  constraint_name
	 		                  from  DBA_constraints
                                    where DBA_constraints.owner   = DBA_indexes.owner
                                    and   constraint_type         = 'P'
			                  and   index_name              = constraint_name) 
union
select i.index_name,110, 99, '  initial     '||
   -- trunc((sum(e.bytes))/8192+1)*8192
       decode(sign(nvl('&tam',sum(e.bytes)/1024)*1024-sum(e.bytes)),-1,nvl('&tam',sum(e.bytes)/1024)*1024,trunc((sum(e.bytes)*.2)/8192+1)*8192)
   --i.initial_extent
from DBA_indexes i, DBA_extents e
where i.owner              like nvl(upper('&pr'),'%')
and   upper(i.table_name)  like nvl(upper('&tb'),'%')
and   e.owner                 = i.owner
and   e.segment_name          = i.index_name
and   not i.index_name       in ( select  c.constraint_name
	 		                  from  DBA_constraints c
                                    where c.owner                 = i.owner
                                    and   c.constraint_type       = 'P'
			                  and   i.index_name            = c.constraint_name)
group by i.index_name 
union
select i.index_name,120, 99, '  next        '||
-- trunc((sum(e.bytes)*.2)/8192+1)*8192
       decode(sign(nvl('&tam',sum(e.bytes)/1024)*1024-sum(e.bytes)),-1,nvl('&tam',sum(e.bytes)/1024)*1024,trunc((sum(e.bytes)*.1)/8192+1)*8192)
-- i.initial_extent
from DBA_indexes i , dba_extents e
where i.owner              like nvl(upper('&pr'),'%')
and   upper(i.table_name)  like nvl(upper('&tb'),'%')
and   e.owner                 = i.owner
and   e.segment_name          = i.index_name
and   not i.index_name       in ( select  c.constraint_name
	 		                  from  DBA_constraints c
                                    where c.owner                 = i.owner
                                    and   c.constraint_type       = 'P'
			                  and   i.index_name            = c.constraint_name) 
group by i.index_name 
union
select index_name,130, 99, '  minextents  '||nvl(min_extents,1)
from DBA_indexes
where owner              like nvl(upper('&pr'),'%')
and   upper(table_name)  like nvl(upper('&tb'),'%')
and   not index_name       in ( select  constraint_name
	 		                from  DBA_constraints
                                  where DBA_constraints.owner     = DBA_indexes.owner
                                  and   constraint_type           = 'P'
			                and   index_name                = constraint_name) 
union
select index_name,140, 99, '  maxextents  unlimited'   --||max_extents
from DBA_indexes
where owner              like nvl(upper('&pr'),'%')
and   upper(table_name)  like nvl(upper('&tb'),'%')
and   not index_name       in ( select  constraint_name
	 		                from  DBA_constraints
                                  where DBA_constraints.owner     = DBA_indexes.owner
                                  and   constraint_type           = 'P'
			                and   index_name                = constraint_name) 
union
select index_name,150, 99, '  pctincrease 0'    --||pct_increase
from DBA_indexes
where owner              like nvl(upper('&pr'),'%')
and   upper(table_name)  like nvl(upper('&tb'),'%')
and   not index_name       in ( select  constraint_name
	 		                from  DBA_constraints
                                  where DBA_constraints.owner     = DBA_indexes.owner
                                  and   constraint_type           = 'P'
			                and   index_name                = constraint_name) 
union
select index_name,160, 99, ') nologging'
from DBA_indexes
where owner              like nvl(upper('&pr'),'%')
and   upper(table_name)  like nvl(upper('&tb'),'%')
and   not index_name       in ( select  constraint_name
	 		                from  DBA_constraints
                                  where DBA_constraints.owner     = DBA_indexes.owner
                                  and   constraint_type           = 'P'
			                and   index_name                = constraint_name) 
union
select index_name,170, 99, '/'
from DBA_indexes
where owner              like nvl(upper('&pr'),'%')
and   upper(table_name)  like nvl(upper('&tb'),'%')
and   not index_name       in ( select  constraint_name
	 		                from  DBA_constraints
                                  where DBA_constraints.owner     = DBA_indexes.owner
                                  and   constraint_type           = 'P'
			                and   index_name                = constraint_name) 
union
select index_name,180, 99, '  '
from DBA_indexes
where owner              like nvl(upper('&pr'),'%')
and   upper(table_name)  like nvl(upper('&tb'),'%')
and   not index_name       in ( select  constraint_name
	 		                from  DBA_constraints
                                  where DBA_constraints.owner     = DBA_indexes.owner
                                  and   constraint_type           = 'P'
			                and   index_name                = constraint_name) 
order by 1,2,3
/
spool off

clear col
set ver on feed on hea on pages 23 pause on termout on

--host sed "s/ *$//g" $HOME/tmp/&ac..tmp > $HOME/tmp/sql/&ac..sql
--host rm $HOME/tmp/&ac..tmp
