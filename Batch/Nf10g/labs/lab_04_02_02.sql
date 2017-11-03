
connect / as sysdba

drop tablespace tbssga including contents and datafiles;

create tablespace tbssga
datafile 'tbssga1.dbf' size 20m;

create table sgalab(a number, b number)
tablespace tbssga;

begin
 for i in 1..100000 loop
   insert into sgalab values (i, i);
 end loop;
end;
/

commit;

alter table sgalab parallel 48;
