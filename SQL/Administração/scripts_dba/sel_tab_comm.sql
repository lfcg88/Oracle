/* Exibe comentarios de tabelas que o usuario e' dono */

set linesize 80
set pagesize 66
set pause off
clear columns

column table_name format a30 
column comments   format a40

select a.table_name,
       c.comments  
from   all_tables a,
       user_tab_comments c
where  a.owner = USER and
       a.table_name = c.table_name
order by a.table_name
/
