
set echo on

show parameter user_dump

host ls -lt /u01/app/oracle/admin/orcl/udump

-- Specify the most recent one (first on the previous list)
host view /u01/app/oracle/admin/orcl/udump/orcl_ora_"&tracenum".trc
