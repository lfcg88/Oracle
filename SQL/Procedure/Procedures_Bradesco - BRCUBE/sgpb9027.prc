CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9027 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB9027
  --      DATA            : 15/3/2006 09:38:13
  --      AUTOR           : Wassily Chuk Seiblitz Guanaes
  --      OBJETIVO        : 
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_IDTRIO_TRAB            	varchar2(100);
  VAR_IARQ_TRAB              	varchar2(100);
  VAR_CAMBTE                 	varchar2(100);           
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB9027';
  VAR_SISTEMA                   VARCHAR2(04) := 'SGPB';
  VAR_COMPT                     number(6);  
BEGIN  
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(840,VAR_DCARGA, VAR_DPROX_CARGA);
   -- GRAVA LOG INICIAL DE CARGA
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||' COMP: '||VAR_COMPT,'P',NULL,NULL);
   COMMIT;
   SGPB0027(VAR_COMPT,Pc_Util_01.Banco,'SGPB9027');
END SGPB9027;
/

