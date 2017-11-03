
connect fd/fd

select blocks from dba_free_space where tablespace_name='TBSFD';

col segment_name format a50

select segment_name,blocks from user_segments;

select constraint_name, constraint_type, table_name from user_constraints;
