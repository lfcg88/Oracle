
connect addm/addm

drop table addm purge;
create table addm(id number, name varchar2(2000)) tablespace TBSADDM2;

exec DBMS_STATS.GATHER_TABLE_STATS(-
ownname=>'ADDM', tabname=>'ADDM',-
estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE);

exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT();

