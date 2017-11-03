
connect / as sysdba

drop table t purge;

create table t(c number) tablespace users;

insert into t values(1);

commit;
