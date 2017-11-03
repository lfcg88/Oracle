-- verificar tempo de espera
SELECT W.SID, W.EVENT, W.SECONDS_IN_WAIT
FROM V$SESSION_WAIT W
WHERE W.EVENT NOT LIKE 'SQL*Net%'
AND W.EVENT NOT IN ('pmon timer', 'smon timer', 'rdbms ipc message', 'wakeup time manager', 'jobq slave wait',
'PL/SQL lock timer') ORDER BY W.SECONDS_IN_WAIT, W.SID;



-- verificar i/o
SELECT sess.SID, sess.username, sess.osuser, sess.program,
sess.machine, s.statistic#, NAME, VALUE
FROM v$sesstat s, v$statname n, v$session sess
WHERE n.statistic# = s.statistic#
AND sess.SID = s.SID
AND n.statistic# IN (9, 42)



-- pegar o sql_id da sess�o
SELECT * 
FROM V$SESSION 
WHERE SID = 116


-- ver a query que esta rodando
SELECT sql_id, rows_processed, sql_text
FROM v$sql
WHERE sql_id = 'cm2n73scqbd1r'








-- SESSION I/O POR USUARIO
--Username - Name of the Oracle process user
--OS User - Name of the operating system user
--PID - Process ID of the session
--SID - Session ID of the session
--Serial# - Serial# of the session
--Physical Reads - Physical reads for the session
--Block Gets - Block gets for the session
--Consistent Gets - Consistent gets for the session
--Block Changes - Block changes for the session
--Consistent Changes - Consistent changes for the session

    select	nvl(ses.USERNAME,'ORACLE PROC') username,
    	OSUSER os_user,
    	PROCESS pid,
    	ses.SID sid,
    	SERIAL#,
    	PHYSICAL_READS,
    	BLOCK_GETS,
    	CONSISTENT_GETS,
    	BLOCK_CHANGES,
    	CONSISTENT_CHANGES
    from	v$session ses, 
    	v$sess_io sio
    where 	ses.SID = sio.SID
    order 	by PHYSICAL_READS, ses.USERNAME




-- CPU USAGE BY SESSION NOTES:
--Username - Name of the user
--SID - Session id
--CPU Usage - CPU centiseconds used by this session (divide by 100 to get real CPU seconds)

    select 	nvl(ss.USERNAME,'ORACLE PROC') username,
    	se.SID,
    	VALUE cpu_usage
    from 	v$session ss, 
    	v$sesstat se, 
    	v$statname sn
    where  	se.STATISTIC# = sn.STATISTIC#
    and  	NAME like '%CPU used by this session%'
    and  	se.SID = ss.SID
    order  	by VALUE desc





--RESOURCE USAGE BY USER NOTES:
--SID - Session ID
--Username - Name of the user
--Statistic - Name of the statistic
--Value - Current value

    select 	ses.SID,
    	nvl(ses.USERNAME,'ORACLE PROC') username,
    	sn.NAME statistic,
    	sest.VALUE
    from 	v$session ses, 
    	v$statname sn, 
    	v$sesstat sest
    where 	ses.SID = sest.SID
    and 	sn.STATISTIC# = sest.STATISTIC#
    and 	sest.VALUE is not null
    and 	sest.VALUE != 0            
    order 	by ses.USERNAME, ses.SID, sn.NAME



--SESSION STAT NOTES:
--Username - Name of the user
--SID - Session ID
--Statistic - Name of the statistic
--Usage - Usage according to Oracle

    select  nvl(ss.USERNAME,'ORACLE PROC') username,
    	se.SID,
    	sn.NAME stastic,
    	VALUE usage
    from 	v$session ss, 
    	v$sesstat se, 
    	v$statname sn
    where  	se.STATISTIC# = sn.STATISTIC#
    and  	se.SID = ss.SID
    and	se.VALUE > 0
    order  	by sn.NAME, se.SID, se.VALUE desc




--CURSOR USAGE BY SESSION NOTES:
--Username - Name of the user
--Recursive Calls - Total number of recursive calls
--Opened Cursors - Total number of opened cursors
--Current Cursors - Number of cursor currently in use

    select 	user_process username,
    	"Recursive Calls",
    	"Opened Cursors",
    	"Current Cursors"
    from  (
    	select 	nvl(ss.USERNAME,'ORACLE PROC')||'('||se.sid||') ' user_process, 
    			sum(decode(NAME,'recursive calls',value)) "Recursive Calls",
    			sum(decode(NAME,'opened cursors cumulative',value)) "Opened Cursors",
    			sum(decode(NAME,'opened cursors current',value)) "Current Cursors"
    	from 	v$session ss, 
    		v$sesstat se, 
    		v$statname sn
    	where 	se.STATISTIC# = sn.STATISTIC#
    	and 	(NAME  like '%opened cursors current%'
    	or 	 NAME  like '%recursive calls%'
    	or 	 NAME  like '%opened cursors cumulative%')
    	and 	se.SID = ss.SID
    	and 	ss.USERNAME is not null
    	group 	by nvl(ss.USERNAME,'ORACLE PROC')||'('||se.SID||') '
    )
    orasnap_user_cursors
    order 	by USER_PROCESS,"Recursive Calls"




--USER HIT RATIO NOTES:
--Username - Name of the user
--Consistent Gets - The number of accesses made to the block buffer to retrieve data in a consistent mode.
--DB Blk Gets - The number of blocks accessed via single block gets (i.e. not through the consistent get mechanism).
--Physical Reads - The cumulative number of blocks read from disk.

--Logical reads are the sum of consistent gets and db block gets.
--The db block gets statistic value is incremented when a block is read for update and when segment header blocks are accessed.
--Hit ratio should be > 90%

    select	USERNAME,
    	CONSISTENT_GETS,
            BLOCK_GETS,
            PHYSICAL_READS,
            ((CONSISTENT_GETS+BLOCK_GETS-PHYSICAL_READS) / (CONSISTENT_GETS+BLOCK_GETS)) Ratio
    from 	v$session, v$sess_io
    where 	v$session.SID = v$sess_io.SID
    and 	(CONSISTENT_GETS+BLOCK_GETS) > 0
    and 	USERNAME is not null
    order	by ((CONSISTENT_GETS+BLOCK_GETS-PHYSICAL_READS) / (CONSISTENT_GETS+BLOCK_GETS))




-- V$OPEN_CURSOR
-- para pegar o sql que est� sendo executado pela sess�o.






select s.sid 
, s.serial# 
, s.username 
, s.machine 
, q.sql_text
, s.program
from v$sql q, v$session s 
where q.sql_id = s.sql_id




v$sql
v$session
v$process
