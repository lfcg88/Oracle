
set echo on

connect sh/sh

rem cleanup

drop materialized view my_mv;
drop table rewrite_table;