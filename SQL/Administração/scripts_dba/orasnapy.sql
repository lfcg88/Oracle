/* Counts das tabelas que tem snapshot */

set pause off
set pages 0
set head off
set lines 8
set feedb off

col c format 999999

select count(*) c from AEROT001;
select count(*) c from CACRT001;
select count(*) c from CAMBT001;
select count(*) c from CASAT001;
select count(*) c from COTAT001;
select count(*) c from DEAET001;
select count(*) c from EMPRT001;
select count(*) c from EMPRT002;
select count(*) c from FILIT001;
select count(*) c from FNECT001;
select count(*) c from FNECT002;
select count(*) c from FNECT003;
select count(*) c from GRUPT001;
select count(*) c from ITEMT001;
select count(*) c from ITEMT006;
select count(*) c from ITEMT007;
select count(*) c from LOJAT001;
select count(*) c from MARCT001;
select count(*) c from MOEDT001;
select count(*) c from PAIST001;
select count(*) c from PRECT001;
select count(*) c from PTVET001;
select count(*) c from SEGMT001;
select count(*) c from SGRPT001;
select count(*) c from TIPOT001;
select count(*) c from TRAVT001;

exit
