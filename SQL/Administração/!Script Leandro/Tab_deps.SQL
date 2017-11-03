set serverout on size 400000
set lines 2000
set verify off
set feedback off

Accept owner Prompt       'Digite o Owner da Tabela: '
Accept object_name Prompt 'Digite o Nome da Tabela : '

Declare
  wrk_owner         varchar2(1000) := upper('&owner');
  wrk_object_name   varchar2(1000) := upper('&object_name');
  wrk_sql           varchar2(1000);

BEGIN 

  DBMS_OUTPUT.PUT_LINE('###############################################################');
  DBMS_OUTPUT.PUT_LINE('#                                                             #');
  DBMS_OUTPUT.PUT_LINE('#              Lista das dependencias da Tabela               #');
  DBMS_OUTPUT.PUT_LINE('#'||rpad(lpad(wrk_owner||'.'||wrk_object_name,40,' '),61,' ')||'#');
  DBMS_OUTPUT.PUT_LINE('#                                                             #');
  DBMS_OUTPUT.PUT_LINE('###############################################################');


  Show_tab_deps(wrk_owner,wrk_object_name);

  DBMS_OUTPUT.PUT_LINE('.');

END;
/


set lines 500
set verify on
set feedback on
