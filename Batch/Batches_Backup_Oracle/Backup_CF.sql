spool d:\batches_Novo\logs\Backup_cf_20032904_210405.log 
connect /@miafis as sysoper 
alter database backup controlfile to 'e:\oracle\Backup\MIAFIS\Backup_cf_20032904_210405.ctl'; 
alter database backup controlfile to trace; 
quit; 
