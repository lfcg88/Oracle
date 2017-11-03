create database link "rjd14_prod.brasifnet.com.br"
connect to system
identified by "admkx"
using 'rjd14_prod'

##############################################################################

SELECT TABLESPACE_NAME
FROM dba_tablespaces@rjd14_prod.brasifnet.com.br
minus
SELECT TABLESPACE_NAME
FROM dba_tablespaces;

select unique default_tablespace from dba_users@rjd14_prod.brasifnet.com.br
minus
select tablespace_name  from dba_tablespaces

##############################################################################

ALTER USER SYSTEM IDENTIFIED BY ADMKY;

ALTER USER SYS IDENTIFIED BY ADMKY;

##############################################################################

--produção
select owner, count(1) 
from dba_segments@rjd5_prod.brasifnet.com.br
group by rollup (owner)
order by 1;

--desenv
select owner, count(1) 
from dba_segments
group by rollup (owner)
order by 1

##############################################################################

select owner || '.' || object_name OBJETO, object_type
  from dba_objects@rjd5_prod.brasifnet.com.br
 where owner not in ('SYS', 'SYSTEM')
   AND OBJECT_NAME NOT LIKE 'SYS_C%'
minus
select owner || '.' || object_name, object_type
  from dba_objects
 where owner not in ('SYS', 'SYSTEM')
   AND OBJECT_NAME NOT LIKE 'SYS_C%'

##############################################################################

select UNIQUE 'ALTER USER '||owner||' IDENTIFIED BY '||OWNER||';' COMANDO
 from dba_objects
where owner not in ('SYS','SYSTEM','PUBLIC','DBSNMP','OUTLN');


select UNIQUE '  '||owner||' => '||OWNER LINHA
 from dba_objects
where owner not in ('SYS','SYSTEM','PUBLIC','DBSNMP','OUTLN');

