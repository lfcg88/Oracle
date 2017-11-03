-- Cleanup

connect / as sysdba

drop user fd cascade;
drop tablespace tbsfd including contents and datafiles;
