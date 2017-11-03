
drop user fd cascade;

create user fd identified by fd
default tablespace tbsfd
temporary tablespace temp;

grant connect, resource, dba to fd;
