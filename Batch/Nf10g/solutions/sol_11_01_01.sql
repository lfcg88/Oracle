connect / as sysdba

drop tablespace tbsbf including contents and datafiles;

CREATE BIGFILE TABLESPACE tbsbf
DATAFILE 'tbsbf.dbf' SIZE 5M;
