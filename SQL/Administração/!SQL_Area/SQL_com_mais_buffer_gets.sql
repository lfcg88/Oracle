select sql_text,executions,buffer_gets,disk_reads/executions as "reads/exec",buffer_gets/executions as "Buff/Exec" from v$sqlarea where executions >0 order by buffer_gets/executions desc