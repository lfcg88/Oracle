
col object_name format a50

select object_name, object_type from user_objects;

select constraint_name, constraint_type, table_name from user_constraints;
