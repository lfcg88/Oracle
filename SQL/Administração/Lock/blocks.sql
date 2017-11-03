column object_name format A20
column program format A20
column osuser format A15

/* linha com XIDUSN = 0 está esperando */

select xidusn,o.object_name,o.owner as object_owner,session_id,s.serial#,oracle_username as "ORACLE USER",s.terminal,s.program,s.osuser from v$locked_object lo,
dba_objects o,v$session s
where lo.object_id in 
(select object_id from v$locked_object
where session_id in
(select sid from v$session where lockwait is not null)
) and
lo.object_id = o.object_id and
lo.session_id = s.sid
