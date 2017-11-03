
connect addm/addm

drop tablespace TBSADDM2 including contents and datafiles;

CREATE SMALLFILE TABLESPACE tbsaddm2
DATAFILE 'addm2_1.dbf' SIZE 50M
LOGGING
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

@lab_04_01_07.sql
