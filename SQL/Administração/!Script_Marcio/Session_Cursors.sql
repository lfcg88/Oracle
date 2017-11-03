column username format A15
column program format A15
column machine format A15

select s.username,s.program,s.machine,ss.value as "Opened Cursors" 
  from v$session s,v$sesstat ss
  where s.sid = ss.sid and
        ss.statistic# = 3 and
        rownum < 10
  order by ss.value desc;
  
------------------------------------------------------------------------
select value as "opened cursors current" from v$sysstat where statistic# = 3;
