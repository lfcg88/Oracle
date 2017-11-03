
set echo on

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
