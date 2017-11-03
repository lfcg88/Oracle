
-- First session

begin
 for i in 1..100 loop
  update b set b=+1, s=rpad('t',100);
  commit;
 end loop;
end;
/
