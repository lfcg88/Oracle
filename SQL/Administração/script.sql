SELECT name, 1 - (physical_reads / (db_block_gets + consistent_gets)) "HIT_RATIO"  FROM
V$BUFFER_POOL_STATISTICS     WHERE db_block_gets + consistent_gets > 0;  

select * from v$shared_pool_advice ;

Select * from v$DB_CACHE_ADVICE;

