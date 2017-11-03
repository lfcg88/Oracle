
set echo on

create table t1 (time_id date);

begin
  for i in 0..3 loop
    insert into t1 values (to_date('02-JAN-2001') + i);
  end loop;
end;
/

commit;

select * from t1;

