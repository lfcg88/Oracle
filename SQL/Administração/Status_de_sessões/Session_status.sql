column username format A15
column program format A20
column machine format A15

select s.username,s.program,s.machine,ss_cur.value as "Cursors",
       ss_cpu.value as "Cpu",ss_reads.value as "reads" 
  from v$session s,v$sesstat ss_cur,v$sesstat ss_cpu,v$sesstat ss_reads
  where s.sid = ss_cur.sid and
        s.sid = ss_cpu.sid and
        s.sid = ss_reads.sid and
        ss_cur.statistic# = 3 and
        ss_cpu.statistic# = 12 and
        ss_reads.statistic# = 9 
  order by ss_cur.value desc;