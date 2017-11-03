
connect / as sysdba

create user dp identified by dp
default tablespace example
temporary tablespace temp;

grant connect, resource, dba to dp;
