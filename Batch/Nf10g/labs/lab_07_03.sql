
set echo on

connect sh/sh

drop materialized view my_mv;

create materialized view my_mv
   build immediate
   enable query rewrite
as select prod_id
   ,      avg(amount_sold) as avg_amount
   from   sales
   where  channel_id = 9
   group  by prod_id;

rem gather statistics for the MV...

execute dbms_stats.gather_table_stats(USER,'MY_MV');

rem try the MV with an intended typo in the query:

select /*+ REWRITE_OR_ERROR */
       prod_id
,      avg(quantity_sold)
from   sales
where  channel_id = 9
group  by prod_id;

rem now without the typo:

select /*+ REWRITE_OR_ERROR */
       prod_id
,      avg(amount_sold)
from   sales
where  channel_id = 9
group  by prod_id;

rem showing the execution plan:

explain plan for
select prod_id
,      avg(amount_sold)
from   sales
where  channel_id = 9
group  by prod_id;

select * from table(dbms_xplan.display);

rem create rewrite_table...

drop table rewrite_table;
@$ORACLE_HOME/rdbms/admin/utlxrw

rem explain the MV...

execute dbms_mview.explain_rewrite -
( 'select prod_id                  -
   ,      avg(amount_sold)         -
   from   sales                    -
   where  channel_id = 9           -
   group  by prod_id'              -
, 'SH.MY_MV'                       -
, 'Practice 07-3'                  -
) ;

rem ... and show the two new columns:

column message format a40 word

select message
,      original_cost, rewritten_cost
from   rewrite_table;

rem cleanup

drop materialized view my_mv;
drop table rewrite_table;
