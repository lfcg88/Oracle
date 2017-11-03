
/* Lista estatisticas para cada sessao */

column identif                  heading "Sid, Serial, Usuario"
column name      format a35     heading "Estatistica"          trunc
column value                    heading "Valor"

break on identif skip 1

select to_char(t1.sid,'9999') || ', ' || to_char(t1.serial#,'99999') || ', ' ||
       substr(t1.username,1,13) identif,
       t3.name,
       t2.value 
from   v$sesstat  t2,
       v$statname t3,
       v$session  t1
where  t1.sid = t2.sid and
       t2.statistic# = t3.statistic# and
       t1.type != 'BACKGROUND' and
       t1.username like '&&usuario' and
       t3.name like '&&estatistica' 
order by 1, t3.name
/
