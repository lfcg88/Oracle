
connect / as sysdba

-- Should take around 3 minutes
begin
for i in 1..300 loop
for j in 1..8 loop
update t set c=2;
commit;
end loop;
dbms_lock.sleep(1);
end loop;
end;
/
