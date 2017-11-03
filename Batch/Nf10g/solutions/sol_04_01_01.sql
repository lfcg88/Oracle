
connect / as sysdba

drop tablespace tbsaddm including contents and datafiles;

CREATE SMALLFILE TABLESPACE "TBSADDM"
DATAFILE 'addm1.dbf' SIZE 50M
LOGGING
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT MANUAL;
