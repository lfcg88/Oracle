SELECT s.sequence_owner, s.sequence_name, s.min_value, s.max_value, s.increment_by,
       s.cycle_flag, s.order_flag, s.cache_size, s.last_number, 
       o.created, o.last_ddl_time
FROM   DBA_SEQUENCES s, DBA_OBJECTS o
WHERE  s.sequence_owner = o.owner
AND    s.sequence_name = o.object_name
AND    (o.owner = 'SYS' OR o.owner IN ('CRP'))
AND    o.object_type = 'SEQUENCE'
ORDER BY 1,2