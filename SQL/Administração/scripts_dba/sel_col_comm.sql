/* Exibe comentarios de colunas de tabelas que o usuario e' dono */

set linesize 132
set pagesize 66
set pause off
clear columns

column table_name  format a30 
column column_name format a30
column c_comments  format a62 heading "Descricao"

select a.table_name,
       c.column_name,
       c.comments    c_comments
from   all_tables a,
       user_col_comments c
where  a.owner = USER and
       a.table_name = c.table_name
order by a.table_name
/
