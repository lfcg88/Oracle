setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
call set_date_time
rem É gerado backup binário em d:\oracle\backup e texto em user dump dest

echo spool %BK_Batches_Logs%\Backup_cf_%DTH%.log > backup_cf.sql
echo connect /@%1 as sysoper >> backup_cf.sql
echo alter database backup controlfile to '%BK_Oracle_Backup%\%1\Backup_cf_%DTH%.ctl'; >> backup_cf.sql
echo alter database backup controlfile to trace; >> backup_cf.sql
echo quit; >> backup_cf.sql

sqlplus /nolog @backup_cf.sql

:EOJ
endlocal