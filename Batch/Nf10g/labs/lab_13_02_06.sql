
connect jfv/jfv

begin
 for i in 1..10000 loop
  update emp set salary=salary+1;
 end loop;
 commit;
end;
/

select undoblks from v$undostat;

select * from V$FLASHBACK_DATABASE_LOG;

select * from V$FLASHBACK_DATABASE_STAT;

host ls -l $ORACLE_BASE/flash_recovery_area/ORCL*/flashback
