-------------------------------------------------------------------------------
--
-- Script:	hidden_parameters.sql
-- Purpose:	to list the hidden parameters
-- For:		7.3
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
--
--  para o script funcionar é necessario executar o produto gerado pelo comando abiaxo
--  utiliza sys ou internal
----select
--  'create or replace view X_$' || substr(name, 3) ||
--  ' as select * from ' || name || ';'
--from
--  sys.v_$fixed_table
--where
--  name like 'X$%'
--/
-------------------------------------------------------------------------------
@save_sqlplus_settings

set linesize 128
column name format a42

select
  x.ksppinm  name,
  decode(bitand(ksppiflg/256,1),1,'TRUE','FALSE')  sesmod,
  decode(
    bitand(ksppiflg/65536,3),
    1,'IMMEDIATE',
    2,'DEFERRED',
    3,'IMMEDIATE',
    'FALSE'
  )  sysmod,
  ksppdesc  description
from
  sys.x_$ksppi  x
where
  translate(ksppinm,'_','#') like '#%'
order by
  1
/

@restore_sqlplus_settings
