CREATE OR REPLACE Procedure Pr_lock_user (p_username varchar2) as
Begin
Declare
  wrk_objeto    number(1);
  wrk_sql       varchar2(100);
  wrk_nm_banco  varchar2(30);
  
Begin
   -- Verifica se o usu�rio tem algum objeto no banco
   -- O owner da procedure precida do direito abaixo
   -- Grant select on dba_objects to <owner>
   Begin
     Select 1
       into wrk_objeto
       from dual
      where exists (select 1 
                      from dba_objects
                     where owner = UPPER(p_username));
--
   Exception
      When no_data_found Then
         wrk_objeto :=0;
      When Others Then
         Raise_Application_Error(-20001,'Pr_lock_user - '||Sqlerrm);
   End;
--
   -- Caso o usu�rio tenha objetos ele n�o pode ser bloqueado.
   If wrk_objeto = 1 Then
      Raise_Application_Error(-20002,'Pr_lock_user - Este usu�rio n�o pode ser '||
                                     'bloqueado pois possui objetos.');
   -- Se o usu�rio n�o tem nenhum objeto.
   Else
      -- Bloqueia o usu�rio
      Begin
         wrk_sql := 'ALTER USER '||p_username||' ACCOUNT LOCK';
         Execute Immediate wrk_sql;
--
      Exception
         When Others Then
           If  sqlcode = -01031 Then
              Raise_Application_Error(-20003,'Pr_lock_user - Falta grant de "alter user" para o owner da procedure.');
           Else
              Raise_Application_Error(-20004,'Pr_lock_user - '||Sqlerrm);
           End If;
      End;
--
      -- Identifica o Banco
      Begin
         Select global_name 
           Into wrk_nm_banco
           From global_name;
           
      Exception
         When Others Then
              Raise_Application_Error(-20005,'Pr_lock_user - '||Sqlerrm);
      End;
        
      -- Apaga os registros velhos existentes na tabela
      Begin
         Delete From tb_controle_usuarios
           Where dt_alteracao < sysdate - 365;
--
      Exception
         When Others Then
           Raise_Application_Error(-20006,'Pr_lock_user - '||Sqlerrm);
      End;
      -- Gera log de todo bloqueio feito 
      Begin
         Insert Into tb_controle_usuarios
                   ( nm_user
                   , dt_alteracao
                   , tp_alteracao
                   , nm_alterador
                   , nm_banco)
              values
                   ( UPPER(p_username)
                   , sysdate
                   , 'Bloqueio'
                   , user
                   , wrk_nm_banco);
--
      Exception
         When Others Then
           Raise_Application_Error(-20007,'Pr_lock_user - '||Sqlerrm);
      End;
      Commit;
   End If;
End;
End;
/
