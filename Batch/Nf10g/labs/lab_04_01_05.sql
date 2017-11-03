connect addm/addm

exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT();

exec DBMS_STATS.GATHER_TABLE_STATS(-
ownname=>'ADDM', tabname=>'ADDM',-
estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE);



