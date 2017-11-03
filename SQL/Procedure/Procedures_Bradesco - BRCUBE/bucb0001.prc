CREATE OR REPLACE PROCEDURE SGPB_PROC.BUCB0001(
                            pLogin             IN  VARCHAR2,
                            pSenha             IN  VARCHAR2,
                            pMensagem          OUT VARCHAR2 
                             ) IS
  -------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : BUCB0001
  --      data            : 02/10/07 
  --      autor           : RALPH AGUIAR
  --      objetivo        : Verifica LOGIN de acesso CRIVO                      
  -------------------------------------------------------------------------------------------------
 
BEGIN
   --pMensagem  :=  'OK';
   pMensagem  :=  'Erro ACESSO CRIVO - Usuário ou Senha inválidos';   
END BUCB0001;
/

