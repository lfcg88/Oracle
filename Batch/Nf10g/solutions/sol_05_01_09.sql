
connect system/oracle

set serveroutput on

-- Threshold modification
exec sys.sa_dequeue;
-- Warning
exec sys.sa_dequeue;
-- Cleared
exec sys.sa_dequeue;
-- Critical
exec sys.sa_dequeue;
-- Updated
exec sys.sa_dequeue;
-- Cleared
exec sys.sa_dequeue;
-- Error
exec sys.sa_dequeue;
exec sys.sa_dequeue;
exec sys.sa_dequeue;
exec sys.sa_dequeue;
