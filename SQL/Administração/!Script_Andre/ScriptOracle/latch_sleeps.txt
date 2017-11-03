-------------------------------------------------------------------------------
--
-- Script:	latch_sleeps.sql
-- Purpose:	shows latch sleep statistics
--
-- Copyright:	(c) 1998 Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@reset_sqlplus

column name        format a30 heading "LATCH TYPE"
column sleep_rate  format a10 heading "SLEEP RATE"
column impact      format 9999999999 heading "IMPACT"

select
  l.name,
  l.sleeps * l.sleeps / (l.misses - l.spin_gets)  impact,
  lpad(to_char(100 * l.sleeps / l.gets, '990.00') || '%', 10)  sleep_rate,
  l.waits_holding_latch,
  l.level#
from
  sys.v_$latch  l
where
  l.sleeps > 0
order by
  2 desc
/

@reset_sqlplus
