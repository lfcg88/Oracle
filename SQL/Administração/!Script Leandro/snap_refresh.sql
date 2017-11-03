Prompt --###################################################
Prompt --#                                                 #
Prompt --#              Atualização de Snapshots           #
Prompt --#    Lista os snapshots que estão defasados a     #
Prompt --#              mais de 1 dia e monta o            #
Prompt --#             comando para refresh fast           #
Prompt --#                                                 #
Prompt --###################################################

alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
set feedback off pages 999 trims on 
col comando format a70


select  'BEGIN'||chr(10)||
        '  DBMS_SNAPSHOT.REFRESH('||chr(10)||
        '    LIST                 => '''||owner||'.'||name||''''||chr(10)||
        '   ,METHOD               => ''?'''||chr(10)||
--        '   ,METHOD               => ''C'''||chr(10)||
        '   ,PUSH_DEFERRED_RPC    => TRUE'||chr(10)||
        '   ,REFRESH_AFTER_ERRORS => FALSE'||chr(10)||
        '   ,PURGE_OPTION         => 1'||chr(10)||
        '   ,PARALLELISM          => 0'||chr(10)||
        '   ,ATOMIC_REFRESH       => TRUE);'||chr(10)||
        'END;'||chr(10)||
        '/'||chr(10)||chr(10)||
        'select owner '||chr(10)||
        '      , name '||chr(10)||
        '      , last_refresh '||chr(10)||
        '   from dba_snapshots '||chr(10)||
        '  where owner = '''|| owner ||''''||chr(10)||
        '    and name  = '''||name||''';'||chr(10)||chr(10) comando, '--  '||a.last_refresh
  From dba_snapshots a
-- where (owner, name) in ( SELECT owner, NAME
--                            FROM DBA_SNAPSHOTS a
--                           where last_refresh < sysdate - 1 and last_refresh > sysdate -10)
/

set feedback on
