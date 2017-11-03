
set echo on

connect / as sysdba

host rman target / nocatalog

SQL "alter tablespace tbsasmmig offline";

backup as copy tablespace tbsasmmig format '+DGROUP1';

switch tablespace tbsasmmig to copy;

SQL "alter tablespace tbsasmmig online";

exit

select file_name,tablespace_name
from dba_data_files;

select * from t2;
