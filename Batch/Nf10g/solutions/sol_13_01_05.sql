
drop table emp;

show recyclebin

select object_name,original_name,space from recyclebin;

select object_name,original_name,space from user_recyclebin;

select object_name,original_name,type from dba_recyclebin;
