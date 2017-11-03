connect / as sysdba

alter tablespace tbsasm online;

select count(*) from t;

drop tablespace tbsasm including contents and datafiles;

select * from v$asm_client;
