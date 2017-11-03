/* Lista uma sessao com respectivo acesso SQL */

column pula       heading " " fold_b 1 fold_a 1
column sql_text   heading "Codigo SQL sendo executado..."

select substr(t1.username,1,12) "Usuario",
       t1.sid,
       t1.serial#,
       t3.spid,
       t1.status,
       t1.terminal,
       t2.sorts      "Sorts",
       t2.executions "Execucoes",
       (t2.sharable_mem + t2.persistent_mem + t2.runtime_mem) "Memoria",
       ' ' pula,
       t2.sql_text
from  v$session t1,
      v$sqlarea t2,
      v$process t3
where t1.sql_address = t2.address and
      t1.sql_hash_value = t2.hash_value and
      t3.addr = t1.paddr and
      t3.spid=&Processo     
/