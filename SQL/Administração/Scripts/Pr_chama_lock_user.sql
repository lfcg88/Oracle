CREATE OR REPLACE Procedure Pr_chama_lock_user as
Begin
Declare
  -- Seleciona os owners bloqueados em outro banco
  Cursor c_user is
     Select nm_user
       From tb_controle_usuarios cu
      Where cu.dt_alteracao > sysdate - 3
        And cu.tp_alteracao = 'Bloqueio'
        And cu.nm_banco not in (Select global_name
                                  From global_name);
--
Begin
--
   For r1 in c_user Loop
      -- Bloqueia os usuário bloqueados em outro banco
      Pr_lock_user(r1.nm_user);

--
   End Loop;
--
Exception
   When others Then
      Raise_application_error(-20001,'Pr_chama_lock_user - '||Sqlerrm);
End;
End;
/
