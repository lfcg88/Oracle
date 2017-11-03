declare
t number;
begin
for t in 1..2222 loop
insert into addm values (Null,'a');
commit;
end loop;
end;
/
exit
