CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0063 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0063
  --      DATA            : 15/3/2006 09:38:13
  --      AUTOR           : Wassily Chuk Seiblitz Guanaes
  --      OBJETIVO        : 
  --      ALTERA��ES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_IDTRIO_TRAB            	varchar2(100);
  VAR_IARQ_TRAB              	varchar2(100);
  VAR_CAMBTE                 	varchar2(100);           
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB0063';
  VAR_SISTEMA                   VARCHAR2(04) := 'SGPB';
  VAR_COMPT                     number(6);  
BEGIN  
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(844,VAR_DCARGA, VAR_DPROX_CARGA);
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA, 'YYYYMM'));
   SGPB0029(VAR_COMPT,'SGPB0063');
END SGPB0063;
/
