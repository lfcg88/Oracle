--------------------------------------------------------------------------------
-- Filename:	repcaterr.sql
-- Purpose:	Lists entries in dba_repcatlog w/ error status.
-- Author:	Chas. Dye (cdye@dialog.com)
-- Date:	28-Jun-1996
--------------------------------------------------------------------------------


column ID		heading	"Id"		format 9999
column SOURCE		heading "Source"	format a20
column SNAME		heading "Schema"	format a8
column REQUEST		heading "Request"	format a22
column ONAME		heading "Object"	format a20
column ERRNUM		heading "Error"		format 99999
column MESSAGE		heading "Message"	format a74


SELECT	id, status, sname, request, oname, errnum
FROM	dba_repcatlog
WHERE	status = 'ERROR'
ORDER BY id
/

SELECT	id, message
FROM	dba_repcatlog
WHERE	status = 'ERROR'
ORDER BY id
/

set head off
SELECT 'Run these commands to purge...'
FROM dual
/
set head on

SELECT 
        'EXECUTE dbms_repcat.purge_master_log('||
        id ||', '
	||chr(39)||rtrim(source)||chr(39)||', '
	||chr(39)||gname||chr(39)||');'     command
FROM    dba_repcatlog  
WHERE   status = 'ERROR'
/


