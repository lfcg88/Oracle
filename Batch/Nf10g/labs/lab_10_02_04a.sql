
-- Second session

declare
 b number;
 cursor c1 is select b from b;
begin
 open c1;
 loop
  fetch c1 into b;
  dbms_lock.sleep(1);
  exit when c1%notfound;
 end loop;
 close c1;
end;
/
