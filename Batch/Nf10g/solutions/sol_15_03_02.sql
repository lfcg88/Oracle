
set echo on

connect / as sysdba

host rman target / nocatalog @sol_15_03_02a.sql

select file_name,tablespace_name
from dba_data_files;

select * from t2;
