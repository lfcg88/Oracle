/* Exibe comentarios de tabelas e de colunas */

column table_name  format a19
column t_comments  format a10
column column_name format a20
column c_comments  format a20

break on table_name skip 1

select t.table_name, 
       t.comments    t_comments, 
       c.column_name, 
       c.comments    c_comments
from user_tab_comments t,
     user_col_comments c
where t.table_name = c.table_name
order by t.table_name, c.column_name
/
