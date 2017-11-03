connect / as sysdba

startup mount;

select name from v$datafile;

alter database datafile '+DGROUP1/orcl/datafile/tbsasm.256.1' offline drop;

alter database open;

drop tablespace tbsasm including contents and datafiles;
