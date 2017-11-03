create or replace procedure sgpb_proc.SGPB1180(ultDtApuracao out date) is
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB1180
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      DATA            : 19/09/2007
  --      AUTOR           : ALEXANDRE CYSNE ESTEVES
  --      OBJETIVO        : RECUPERANDO A ÚLTIMA DATA DO MOVIMENTO - 2º CAMPANHA.
  --      ALTERAÇÕES      :
  --                DATA  :
  --                AUTOR :
  --                OBS   :
  -------------------------------------------------------------------------------------------------
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';

 BEGIN

    DECLARE
        P_DATA DATE := trunc(SYSDATE);

        CURSOR C_DATA IS

        --recuperando a ultima data do movimento na tabela de apolice do corretor
        --SELECT demis_apolc FROM apolc_prod_crrtr where demis_apolc = P_DATA;

        --recuperando a data da carga do processo resumo - data na tabela do dwscheduler
        --parametro 853 - fluxo diario - carga do resumo do corretor
        select pc.dcarga from parm_carga pc where pc.csist = 'SGPB' and pc.cparm = 853;

    BEGIN
         ultDtApuracao := null;
         loop
            OPEN C_DATA;
  			FETCH C_DATA INTO ultDtApuracao;
  			if ultDtApuracao IS NOT NULL then
    		   EXIT;
  			end if;
            CLOSE C_DATA;
            P_DATA := P_DATA - 1;
 		end loop;
    END;

 EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' # ' || SQLERRM,
                          1,
                          PC_UTIL_01.VAR_TAM_MSG_ERRO);

    PR_GRAVA_MSG_LOG_CARGA('SGPB1180',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

end SGPB1180;
/

