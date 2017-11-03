Prompt #############################################################
Prompt #                                                           #
Prompt #          Compilar objetos inválidos no banco              #
Prompt #                                                           #
Prompt #############################################################


set serverout on
set feedback off
Declare

  Wrk_conta_invalidos  Number(10):=0;
  Wrk_guarda_invalidos Number(10):=1;
  Wrk_sql              Varchar2(300);

  Cursor c_inval is
    Select 'ALTER '||Decode(Object_type,'PACKAGE BODY','PACKAGE',Object_type)
           ||' '||owner||'.'||object_name||' COMPILE'||
           Decode(Object_type,'PACKAGE BODY',' BODY','PACKAGE',' PACKAGE','')||';' Comando
      From all_objects
     Where status = 'INVALID'
       And object_type <> 'UNDEFINED'
       And owner Not In ('SYSTEM','SYS')
     Order by owner, object_type;
Begin
  dbms_output.enable(999999999);
  <<volta>>
  Begin

    Select count(1)
      Into Wrk_conta_invalidos
      From all_objects a
     Where a.status = 'INVALID'
       And object_type <> 'UNDEFINED'
       And owner Not In ('SYSTEM','SYS');
  Exception
    When Others Then
      Raise_application_error(-20001,'Manager.Pr_Gera_Grants_Indices: '||sqlerrm);
  End;

  If  Wrk_conta_invalidos <> 0 And
      Wrk_guarda_invalidos <> Wrk_conta_invalidos Then

    Wrk_guarda_invalidos := Wrk_conta_invalidos;
    dbms_output.put_line('col LINE/COL format a20');
    For r_inval in c_inval Loop

      Wrk_sql := r_inval.comando;
      dbms_output.put_line(Wrk_sql||';');

      Begin
        Execute Immediate Wrk_sql;

      Exception
        When Others Then
          Null;
      End;
    End Loop;
    
    goto volta;
    null;

  End If;

  If  Wrk_conta_invalidos <> 0 Then

    dbms_output.put_line('***           Ainda existem   '||Wrk_conta_invalidos||'                ***');
    dbms_output.put_line('***       objetos inválidos no banco.           ***');

  Else

    dbms_output.put_line('***  Não existem objetos inválidos no banco.    ***');

  End If;
End;
/

set feedback on
