
connect / as sysdba

-- Should take around 1 minute
begin
for i in 1..60 loop
for j in 1..6 loop
update t set c=2;
commit;
end loop;
dbms_lock.sleep(1);
end loop;
end;
/
