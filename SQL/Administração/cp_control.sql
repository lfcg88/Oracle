alter system switch logfile;

-- # host copy /tribunal/oracle8/admin/orcl/arch/*.* /pub/bkp_oracle/backup_online/

ALTER DATABASE BACKUP CONTROLFILE TO '/pub/bkp_oracle/backup_online/control_bkp.ctl';
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;

exit