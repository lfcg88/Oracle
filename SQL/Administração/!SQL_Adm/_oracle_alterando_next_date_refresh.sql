begin
DBMS_REFRESH.CHANGE(
     name => '"CSN"."GRUPO_01"',
     next_date => to_date('28-09-2040 23:00:00','DD-MM-YYYY HH24:MI:SS')
);
commit;
end;