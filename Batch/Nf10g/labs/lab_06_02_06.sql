
connect / as sysdba;

exec dbms_sqltune.drop_sqlset('MY_STS_WORKLOAD');

drop materialized view log on sh.customers;

drop materialized view log on sh.channels;

drop materialized view log on sh.times;

drop materialized view log on sh.sales;

select mview_name from dba_mviews;

-- Use the last value returned by the previous query. Something like MV$$_01620002

drop materialized view &mvname;

