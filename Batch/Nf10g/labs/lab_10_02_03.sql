
-- Second session

drop table b purge;

create table b(b int, s varchar2(100)) tablespace tbsalert;

begin
for i in 1..100 loop
 insert into b values(i, rpad('s',100));
end loop;
end;
/

commit;
