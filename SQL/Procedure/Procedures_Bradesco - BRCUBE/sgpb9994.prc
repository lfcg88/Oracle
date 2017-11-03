CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9994
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROCEDURE       : SGPB9994
--      DATA            : 17/04/2008
--      AUTOR           : Alexandre Cysne Esteves
--      OBJETIVO        : 
--      ALTERAÇÕES      : 
--                DATA  :
--                AUTOR : 
--                OBS   : 
-------------------------------------------------------------------------------------------------
IS
  --dwsheluler
  VAR_ROTINA					VARCHAR2(10) := 'SGPB9994';
  VAR_PARAMETRO		    NUMBER := 722;
BEGIN
   -- DWSHEDULER
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
   PR_LIMPA_LOG_CARGA(VAR_ROTINA); 
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   -- INICIANDO A EXECUCAO
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PC);
   COMMIT;
   --
   BEGIN      
     DELETE FROM HIST_CTBIL;
     COMMIT;
   end;
   -- DWSHEDULER
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'FIM DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PO);
   COMMIT;
   --

END SGPB9994;
/

