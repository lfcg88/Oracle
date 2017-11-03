
drop user addm cascade;

create user addm identified by addm
default tablespace tbsaddm
temporary tablespace temp;

grant connect, resource, dba to addm;
