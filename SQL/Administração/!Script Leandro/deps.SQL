set serverout on size 400000
set lines 2000
set verify off
set feedback off

Accept owner Prompt 'Digite o Owner do Objeto: '
Accept object_name Prompt 'Digite o Nome do Objeto : '
Accept Object_type Prompt 'Digite o Tipo do Objeto : '

Declare
  wrk_owner         varchar2(1000) := upper('&owner');
  wrk_object_name   varchar2(1000) := upper('&object_name');
  wrk_Object_type   varchar2(1000) := upper('&Object_type');
  wrk_sql           varchar2(1000);

BEGIN 

  wrk_sql := wrk_owner||'.'||wrk_object_name||'.'||wrk_Object_type;

  DBMS_OUTPUT.PUT_LINE('###############################################################');
  DBMS_OUTPUT.PUT_LINE('#                                                             #');
  DBMS_OUTPUT.PUT_LINE('#        Lista das dependencias do objeto abaixo              #');
  DBMS_OUTPUT.PUT_LINE('#'||rpad(lpad(wrk_owner||'.'||wrk_object_name,40,' '),61,' ')||'#');
  DBMS_OUTPUT.PUT_LINE('#                                                             #');
  DBMS_OUTPUT.PUT_LINE('###############################################################');

  show_dependencies(wrk_sql);
  DBMS_OUTPUT.PUT_LINE('.');

END;
/


set lines 500
set verify on
set feedback on
