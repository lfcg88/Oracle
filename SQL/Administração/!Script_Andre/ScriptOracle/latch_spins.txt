-------------------------------------------------------------------------------
--
-- Script:	latch_spins.sql
-- Purpose:	shows latch spin statistics
--
-- Copyright:	(c) 1998 Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@reset_sqlplus

column name        format a30 heading "LATCH TYPE"
column spin_gets              heading "SPIN GETS"
column sleep_gets             heading "SLEEP GETS"
column hit_rate    format a13 heading "SPIN HIT RATE"

select
  l.name,
  l.spin_gets,
  l.misses - l.spin_gets  sleep_gets,
  lpad(to_char(100 * l.spin_gets / l.misses, '990.00') || '%', 13)  hit_rate
from
  sys.v_$latch  l
where
  l.misses > 0
order by
  l.misses - l.spin_gets desc
/

set heading off

select
  'ALL LATCHES'  name,
  sum(l.spin_gets)  spin_gets,
  sum(l.misses - l.spin_gets)  sleep_gets,
  lpad(
    to_char(100 * sum(l.spin_gets) / sum(l.misses), '990.00') || '%',
    13
  )  hit_rate
from
  sys.v_$latch  l
where
  l.misses > 0
/

set heading on

@reset_sqlplus
