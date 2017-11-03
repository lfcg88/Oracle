Prompt #############################################################
Prompt #                                                           #
Prompt #             Comando alterar horário do Job                #
Prompt #                                                           #
Prompt #############################################################

set verify off
clear columns
Accept job_id prompt "Digite o numero do Job : "
Accept data prompt "Digite a data no format 'DD/MM/YYYY HH24:MI:SS' : "

col objeto format a40



select 'BEGIN'||chr(10)||
       '  SYS.DBMS_JOB.CHANGE'||chr(10)||
       '    ('||chr(10)||
       '      job        => '||job||chr(10)||
       '     ,what       => '''||what||''''||chr(10)||
       '     ,next_date  => to_date('''||&data||''',''dd/mm/yyyy hh24:mi:ss'')'||chr(10)||
       '     ,interval   => '''||interval||''''||chr(10)||
       '    );'||chr(10)||
       '  Commit;'||chr(10)||
       'END;'||chr(10)||
       '/'||chr(10)||chr(10)||
       'BEGIN'||chr(10)||
       '  SYS.DBMS_IJOB.NEXT_DATE'||chr(10)||
       '    ('||chr(10)||
       '      job        => '||job||chr(10)||
       '     ,next_date  => to_date('''||&data||''',''dd/mm/yyyy hh24:mi:ss''))'||chr(10)||
       '  Commit;'||chr(10)||
       'END;'||chr(10)||
       '/'||chr(10)||chr(10)||
       'BEGIN'||chr(10)||
       '  SYS.DBMS_IJOB.INTERVAL'||chr(10)||
       '    ('||chr(10)||
       '      job        => '||job||chr(10)||
       '     ,interval   => '''||interval||''')'||chr(10)||
       '  Commit;'||chr(10)||
       'END;'||chr(10)||
       '/'||chr(10)||chr(10) comando
  From dba_jobs
 where job = &job_id;
