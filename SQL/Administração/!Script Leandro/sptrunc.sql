prompt return Entered - starting truncate operation

truncate table STATS$FILESTATXS;
truncate table STATS$LATCH;
truncate table STATS$LATCH_CHILDREN;
truncate table STATS$LATCH_MISSES_SUMMARY;
truncate table STATS$LATCH_PARENT;
truncate table STATS$LIBRARYCACHE;
truncate table STATS$BUFFER_POOL_STATISTICS;
truncate table STATS$ROLLSTAT;
truncate table STATS$ROWCACHE_SUMMARY;
truncate table STATS$SGA;
truncate table STATS$SGASTAT;
truncate table STATS$SYSSTAT;
truncate table STATS$SESSTAT;
truncate table STATS$SYSTEM_EVENT;
truncate table STATS$SESSION_EVENT;
truncate table STATS$BG_EVENT_SUMMARY;
truncate table STATS$WAITSTAT;
truncate table STATS$ENQUEUESTAT;
truncate table STATS$SQL_SUMMARY;
truncate table STATS$SQL_STATISTICS;
truncate table STATS$SQLTEXT;
truncate table STATS$PARAMETER;

delete from STATS$SNAPSHOT;
delete from STATS$DATABASE_INSTANCE;

commit;

prompt
prompt Truncate operation complete
prompt
