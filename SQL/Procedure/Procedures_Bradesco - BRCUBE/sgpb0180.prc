create or replace procedure sgpb_proc.SGPB0180(ultDtApuracao out date) is
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0180
  --      DATA            : 08/05/2007
  --      AUTOR           : Vinícius - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : RECUPERANDO A ÚLTIMA DATA DE APURAÇÃO.
  --      ALTERAÇÕES      :
  --                DATA  : 22/08/2007
  --                AUTOR : Alexandre Cysne Esteves
  --                OBS   : alterada para recuperar a data do movimento na tabela
  --                        do dwscheduler - parametro 853 resumo
  --
  --                DATA  : 19/09/2007
  --                AUTOR : ALEXANDRE CYSNE ESTEVES
  --                OBS   : PROCEDIMENTO ALTERADO PARA QUE SEJA RETORNADO A ULTIMA DATA DO MOVIMENTO
  --                      : DA 1º CAMPANHA (30/09/2007)
  -------------------------------------------------------------------------------------------------

  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';

 BEGIN

    DECLARE
        P_DATA DATE := trunc(SYSDATE);
        
        CURSOR C_DATA IS 
        --22-08-2007
        --recuperando a ultima data do movimento na tabela de apolice do corretor
        --SELECT demis_apolc FROM apolc_prod_crrtr where demis_apolc = P_DATA;  
        
        --recuperando a data da carga do processo resumo - data na tabela do dwscheduler
        --parametro 853 - fluxo diario - carga do resumo do corretor
        --select pc.dcarga from parm_carga pc where pc.csist = 'SGPB' and pc.cparm = 853;
        --22-08-2007
        
        --19-09-2007
        select to_date('20070930','yyyymmdd') from dual;
                                                  
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

    PR_GRAVA_MSG_LOG_CARGA('SGPB0180',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

end SGPB0180;
/

