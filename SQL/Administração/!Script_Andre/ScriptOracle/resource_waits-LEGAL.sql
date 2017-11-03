-------------------------------------------------------------------------------
--
-- Script:	resource_waits.sql
-- Purpose:	to show the total waiting time for resource types
--
-- Copyright:	(c) 1998 Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@reset_sqlplus

column average_wait format 9999990.00

select
  substr(e.event, 1, 40)  event,
  e.time_waited,
  e.time_waited / (
    e.total_waits - decode(e.event, 'latch free', 0, e.total_timeouts)
  )  average_wait
from
  sys.v_$system_event  e,
  sys.v_$instance  i
where
  e.event = 'buffer busy waits' or
  e.event = 'enqueue' or
  e.event = 'free buffer waits' or
  e.event = 'global cache freelist wait' or
  e.event = 'latch free' or
  e.event = 'log buffer space' or
  e.event = 'parallel query qref latch' or
  e.event = 'pipe put' or
  e.event = 'write complete waits' or
  e.event like 'library cache%' or
  e.event like 'log file switch%' or
  ( e.event = 'row cache lock' and
    i.parallel = 'NO'
  )
union all
select
  'non-routine log file syncs',
  round(e.average_wait * greatest(e.total_waits - s.value, 0)),
  e.average_wait
from
  sys.v_$system_event e,
  sys.v_$sysstat s
where
  e.event = 'log file sync' and
  s.name = 'user commits'
order by
  2 desc
/

@reset_sqlplus



EVENT                                    TIME_WAITED AVERAGE_WAIT
---------------------------------------- ----------- ------------
log file switch (checkpoint incomplete)        82921        30.61
log file switch completion                     10499         9.57
library cache lock                              7968         3.37
log file switch (private strand flush in        7122         7.68
buffer busy waits                               6966         0.48
library cache: mutex X                          1322         0.01
library cache load lock                         1157        17.27
latch free                                       749         0.03
row cache lock                                    41         0.31
library cache pin                                 19         4.75
non-routine log file syncs                         0         0.10
write complete waits                               0         0.00

12 linhas selecionadas.



