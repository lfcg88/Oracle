select *
  from (select 'Username : ' || s.username || '(SID: ' || s.sid ||
                ', Serial#: ' || s.serial# || ', SPID: ' || p.spid || ')' ||
                chr(10) || 'Machine : ' || s.machine || chr(10) ||
                'OSUser : ' || s.osuser || chr(10) || 'Status : ' || s.status ||
                chr(10) || 'Program : ' || s.program || chr(10) ||
                'Module : ' || s.module || chr(10) || 'Logon Time : ' ||
                to_char(s.logon_time, 'dd/mm/yyyy hh24:mi:ss') || chr(10) ||
                'Tablespace : ' || u.tablespace || chr(10) ||
               --'Utilizado : '||sum(u.blocks)*(select value from v$parameter where name = 'db_block_size')/1048576 ||'MB'||chr(10)||
                'Last Call : ' || s.last_call_et || chr(10) ||
                'Hash Value : ' || t.hash_value || chr(10) || 'Command : ' ||
                substr(t.sql_text, 1, 960)
        --' '||substr(t.sql_text,81,160)||chr(10)||
        --' '||substr(t.sql_text,161,240)||chr(10)||
        --' '||substr(t.sql_text,241,320)||chr(10)||
        --' '||substr(t.sql_text,321,400)
          from v$process p, v$session s, v$sql t, v$sort_usage u
         where p.addr = s.paddr
           and s.saddr = u.session_addr
           and s.sql_address = t.address(+)
         group by s.username,
                  s.sid,
                  s.serial#,
                  p.spid,
                  s.machine,
                  s.osuser,
                  s.status,
                  s.program,
                  s.module,
                  to_char(s.logon_time, 'dd/mm/yyyy hh24:mi:ss'),
                  u.tablespace,
                  s.last_call_et,
                  substr(t.sql_text, 1, 960),
                  t.hash_value,
                  substr(t.sql_text, 1, 960)
         order by sum(u.blocks) desc)
 where rownum <= 10;