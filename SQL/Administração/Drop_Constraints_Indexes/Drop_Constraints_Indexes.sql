select 'alter table ' || owner || '.' || table_name || ' drop primary key cascade;' from dba_constraints
where owner = 'SICAL2' and constraint_type = 'P'
order by table_name;

select 'alter table ' || owner || '.' || table_name || ' drop constraint ' || constraint_name ||  ';' from dba_constraints
where owner = 'SICAL2' and constraint_type in ('R')
order by table_name,constraint_name;

select 'drop index ' || owner || '.' || index_name || ';' from dba_indexes
where table_owner='SICAL2' 
order by table_name,index_name;



