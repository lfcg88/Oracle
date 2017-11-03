Create Tablespace TS_RMAN_D_01 Datafile 
  'E:\ORACLE\ORADATA\RCVCAT\DATAFILE\DF_RMAN_D_01_01.DBF' SIZE 30M AUTOEXTEND OFF
LOGGING
ONLINE
PERMANENT
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 160K;

create user rman identified by senharman
default tablespace TS_RMAN_D_01
temporary tablespace TEMP;

grant connect, resource to rman;

grant recovery_catalog_owner to rman;