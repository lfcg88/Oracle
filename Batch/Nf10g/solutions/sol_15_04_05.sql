connect / as sysdba

create tablespace tbsasm
datafile '+DGROUP1' size 100M;

create table t(c number) tablespace tbsasm;

insert into t values(42);
commit;

insert into t select * from t;
/
/
/
/
/
/
/
/
/

/
/
/
/
/

/
/
/
/

commit;

insert into t select * from t;

commit;
