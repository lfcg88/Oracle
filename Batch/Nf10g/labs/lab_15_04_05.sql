
set echo on

connect / as sysdba

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
