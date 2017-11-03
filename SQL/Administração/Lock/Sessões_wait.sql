/* Sessões em wait */
select sid,serial#,lockwait,osuser,terminal,program
 from v$session where lockwait is not null;