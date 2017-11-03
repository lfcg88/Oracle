
connect / as sysdba

drop user jfv cascade;

drop tablespace jfvtbs including contents and datafiles;

create smallfile tablespace jfvtbs
datafile 'jfvtbs1.dbf' size 500K
logging
extent management local
segment space management auto;

create user jfv identified by jfv
default tablespace jfvtbs
temporary tablespace temp;

grant connect, resource, dba to jfv;
