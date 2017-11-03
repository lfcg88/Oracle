CREATE OR REPLACE Procedure Pr_drop_user as
Begin
Declare
  wrk_objeto    number(1) :=1;
  wrk_sql       varchar2(100);
  wrk_nm_banco  varchar2(30);
  -- Seleciona os owners bloqueados a mais de 30 dias
  Cursor c_owners is
     Select username
       From sys.dba_users u
      Where u.account_status = 'LOCKED'
        And lock_date < sysdate ;-- 30;
--
Begin
dbms_output.enable;
--
   -- Identifica o Banco
   Begin
      Select global_name 
        Into wrk_nm_banco
        From global_name;
--
   Exception
      When Others Then
           Raise_Application_Error(-20001,'Pr_lock_user - '||Sqlerrm);
   End;
--
   For r1 in c_owners Loop
--
     -- Verifica se o usuário tem algum objeto no banco
     -- O owner da procedure precida do direito abaixo
     -- Grant select on sys.dba_objects to <owner>
      Begin
        Select 1
          into wrk_objeto
          from dual
         where exists (select 1 
                         from dba_objects
                        where owner = r1.username);
--
      Exception
         When no_data_found Then
            wrk_objeto :=0;
         When Others Then
            Raise_Application_Error(-20002,'Pr_drop_user - '||Sqlerrm);
      End;
--
      -- Caso o usuário tenha objetos ele não pode ser apagado.
      If wrk_objeto = 1 Then
         -- Gera log dos users que nao foram apagados.
         Begin
            Insert Into tb_controle_usuarios
                      ( nm_user
                      , dt_alteracao
                      , tp_alteracao
                      , nm_alterador
                      , nm_banco)
                 values
                      ( r1.username
                      , sysdate
                      , 'Nao foi apagado'
                      , user
                      , wrk_nm_banco);
            dbms_output.put_line('O owner '||r1.username||' nao foi apagado do banco pois possui objetos nele.');
--
         Exception
            When Others Then
              Raise_Application_Error(-20003,'Pr_drop_user - '||Sqlerrm);
         End;
--
      -- Se o usuário não tem nenhum objeto.
      Else
         -- Apaga o usuário
         Begin
            wrk_sql := 'DROP USER '||r1.username;
            Execute Immediate wrk_sql;
--
         Exception
            When Others Then
               If  sqlcode = -01031 Then
                  Raise_Application_Error(-20004,'Pr_drop_user - Falta grant de "drop user" para o owner da procedure.');
               Else
                  Raise_Application_Error(-20005,'Pr_drop_user - '||Sqlerrm);
               End If;
         End;
--
         dbms_output.put_line('O owner '||r1.username||' foi apagado do banco.');
--
         -- Gera log de todo owner apagado 
         Begin
            Insert Into tb_controle_usuarios
                      ( nm_user
                      , dt_alteracao
                      , tp_alteracao
                      , nm_alterador
                      , nm_banco)
                 values
                      ( r1.username
                      , sysdate
                      , 'Apagado'
                      , user
                      , wrk_nm_banco);
--
         Exception
            When Others Then
              Raise_Application_Error(-20006,'Pr_drop_user - '||Sqlerrm);
         End;
      End If;
   End Loop;
--
   -- Gera log de toda vez que a rotina e rodada.
   Begin
         Insert Into tb_controle_usuarios
                   ( nm_user
                   , dt_alteracao
                   , tp_alteracao
                   , nm_alterador
                   , nm_banco)
              values
                   ( user
                   , sysdate
                   , 'Rodada da rotina'
                   , user
                   , wrk_nm_banco);
--
   Exception
      When Others Then
        Raise_Application_Error(-20007,'Pr_drop_user - '||Sqlerrm);
   End;
--   
   Commit;
--
End;
End;
/
