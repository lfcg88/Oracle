SELECT s.sequence_owner, s.sequence_name, s.min_value, s.max_value, s.increment_by,
       s.cycle_flag, s.order_flag, s.cache_size, s.last_number, 
       o.created, o.last_ddl_time
FROM   DBA_SEQUENCES s, DBA_OBJECTS o
WHERE  s.sequence_owner = o.owner
AND    s.sequence_name = o.object_name
AND    o.object_type = 'SEQUENCE'
AND    s.cycle_flag = 'N'
AND    s.max_value < 9999999999999999999
AND    s.increment_by > 0
AND    ROUND(DECODE(s.max_value, 0, 0, (s.last_number / s.max_value) * 100 ), 3) > 90
ORDER BY 1,2