
set echo on

connect / as sysdba

select banner
from v$version
where rownum = 1;

@$HOME/labs/lab_18_01_02a.sql

@$HOME/labs/lab_18_01_02b.sql


