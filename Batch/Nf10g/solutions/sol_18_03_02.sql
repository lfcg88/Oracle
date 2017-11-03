
set echo on

select sid, serial#
from   v$session
where  username = 'SH';

describe dbms_monitor

exec dbms_monitor.session_trace_enable ( -
session_id => &sid ,        -                  
serial_num => &serial ,     -             
waits      => true ,        -                 
binds      => true ) ;
