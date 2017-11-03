-- show results:
--  recommened redo log file size in megabytes (should be much larger than 10)
--  number of writes due to smallest log file size (should be very large)
--  number of writes due to MTTR (should be close to 0) 
select target_mttr, estimated_mttr, writes_mttr, writes_logfile_size,
       optimal_logfile_size 
from v$instance_recovery;
