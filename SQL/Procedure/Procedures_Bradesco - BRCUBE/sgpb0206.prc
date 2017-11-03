CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0206(
  p_ccanal_vda_segur        in PARM_CALC_FAIXA_OBJTV_PROD.CCANAL_VDA_SEGUR%type,
  p_cgrp_ramo_plano         in PARM_CALC_FAIXA_OBJTV_PROD.CGRP_RAMO_PLANO%type,
  p_usuario                 in  VARCHAR2,
  P_Mensagem                out VARCHAR2 
) IS
--*-----------------------------------------------------------------------------------------------
--*      BRADESCO SEGUROS S.A.
--*              SISTEMA : SGPB - INTRANET
--*       FUNCIONALIDADE : FAIXA METAS - PASSO 1
--*            PROCEDURE : SGPB0204
--*                 DATA : 14/09/2007
--*                AUTOR : ALEXANDRE CYSNE ESTEVES
--*             OBJETIVO : VALIDA A FAIXA DA TABELA TEMPORARIA
--*                      : DELETA FAIXA DA TABELA PARM_CALC_FAIXA_OBJTV_PROD
--*                        INCLUI FAIXA DA TEMPORARIA GTT_PARM_CALC_FAIXA_OBJTV_PROD NA PARM_CALC_FAIXA_OBJTV_PROD
--*          ALTERAÇÕES  :
--*
--*              LOGICA  :
--*                DATA  : -
--*               AUTOR  : -
--*                 OBS  : - O campo CMTODO_CALC_OBJTV_PROD ode assumir 1 (Metodo percentual) ou 2 (metodo valor).
--*-----------------------------------------------------------------------------------------------

  r_reg_pcfop PARM_CALC_FAIXA_OBJTV_PROD%rowtype;
  TYPE T_CORRETOR IS REF CURSOR;
  C_CURSOR T_CORRETOR;

BEGIN
  
    -- function para validar regra de faixa por canal de grupo de ramo
    IF Sgpb0044(p_ccanal_vda_segur,p_cgrp_ramo_plano)='N' THEN
      P_Mensagem := 'Faixa invalida!';
      RETURN;
    END IF;
    
    -- Vai deletar todas as faixas anteriores do CANAL e do GRUPO passado
    BEGIN
        DELETE FROM PARM_CALC_FAIXA_OBJTV_PROD
              WHERE CCANAL_VDA_SEGUR = p_ccanal_vda_segur 
                AND CGRP_RAMO_PLANO  = p_cgrp_ramo_plano;
    EXCEPTION
       WHEN OTHERS THEN
          P_Mensagem := 'ERRO NO DELETE DA TABELA DE FAIXAS: '||SQLERRM;
          ROLLBACK;
         RAISE_APPLICATION_ERROR(-20021,P_Mensagem);
    END;                  
    -- vai inserir GTT_PARM_CALC_FAIXA_OBJTV_PROD na tabela PARM_CALC_FAIXA_OBJTV_PROD
    BEGIN
        
    OPEN C_CURSOR FOR
    SELECT CCANAL_VDA_SEGUR,
           CGRP_RAMO_PLANO,
           VINIC_FAIXA_PROD,
           VFNAL_FAIXA_PROD,
           CMTODO_CALC_OBJTV_PROD,
           PCALC_OBJTV_PROD,
           VCALC_OBJTV_PROD
      FROM GTT_PARM_CALC_FAIXA_OBJTV_PROD
     ORDER BY VINIC_FAIXA_PROD;
     --
     LOOP
     --listando todos as faixas selecionada do canal e grupo ramo
     FETCH C_CURSOR INTO r_reg_pcfop.ccanal_vda_segur,
                         r_reg_pcfop.cgrp_ramo_plano,
                         r_reg_pcfop.vinic_faixa_prod,
                         r_reg_pcfop.vfnal_faixa_prod,
                         r_reg_pcfop.cmtodo_calc_objtv_prod,
                         r_reg_pcfop.pcalc_objtv_prod,
                         r_reg_pcfop.vcalc_objtv_prod;
      --
      EXIT WHEN C_CURSOR%NOTFOUND;
      --                                 
           --
           BEGIN

                BEGIN
                  --inserindo registros na tabela temporaria
                   INSERT INTO PARM_CALC_FAIXA_OBJTV_PROD
                              (CCANAL_VDA_SEGUR,
                               CGRP_RAMO_PLANO,
                               VINIC_FAIXA_PROD,
                               VFNAL_FAIXA_PROD,
                               CMTODO_CALC_OBJTV_PROD,
                               PCALC_OBJTV_PROD,
                               VCALC_OBJTV_PROD,
                               DINCL_REG, 
                               DULT_ALT)
                       values( r_reg_pcfop.ccanal_vda_segur,
                               r_reg_pcfop.cgrp_ramo_plano,
                               r_reg_pcfop.vinic_faixa_prod,
                               r_reg_pcfop.vfnal_faixa_prod,
                               r_reg_pcfop.cmtodo_calc_objtv_prod,
                               r_reg_pcfop.pcalc_objtv_prod,
                               r_reg_pcfop.vcalc_objtv_prod,
                               SYSDATE,
                               SYSDATE);
                               
                              -- Logando insert na FAIXA
                              BEGIN               
                              INSERT INTO LOG_ERRO_IMPOR (CLOG_ERRO_IMPOR, IPROCS_IMPOR, DERRO_IMPOR, RMSGEM_ERRO_IMPOR)
                                  SELECT MAX(CLOG_ERRO_IMPOR)+1,'SGPB0206',sysdate,
                                  'INCLUSAO DE NOVA FAIXA: CCANAL_VDA_SEGUR: '||p_ccanal_vda_segur||' CGRP_RAMO_PLANO: '||
                                  p_cgrp_ramo_plano||' VINIC_FAIXA_PROD: '||r_reg_pcfop.VINIC_FAIXA_PROD||
                                  ' VFNAL_FAIXA_PROD: '||r_reg_pcfop.VFNAL_FAIXA_PROD||' CMTODO_CALC_OBJTV_PROD: '||
                                  r_reg_pcfop.CMTODO_CALC_OBJTV_PROD||' PCALC_OBJTV_PROD: '||r_reg_pcfop.PCALC_OBJTV_PROD||
                                  ' VCALC_OBJTV_PROD: '||r_reg_pcfop.VCALC_OBJTV_PROD||' Usuario: '||p_usuario
                                  from LOG_ERRO_IMPOR;
                              EXCEPTION
                              WHEN OTHERS THEN
                                    P_Mensagem := 'ERRO. NAO FOI POSSIVEL GRAVAR O LOG. COD.ERRO: '||SQLERRM;
                                    ROLLBACK;
                                    RAISE_APPLICATION_ERROR(-20021,P_Mensagem);
                              END;                        
                --               
                EXCEPTION
                   WHEN OTHERS THEN
                   P_Mensagem := 'INSERT-1 ' || SUBSTR(SQLERRM,1,490);
                   ROLLBACK;
                   RAISE_APPLICATION_ERROR(-20021,P_Mensagem);
                END;
           --
           END;
     --
      END LOOP;
     --              
     EXCEPTION
      WHEN OTHERS THEN
        P_Mensagem := 'ERRO. NAO FOI POSSIVEL INSERT SELECT: '||SQLERRM;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20021,P_Mensagem);
     END;

   --
   COMMIT;
   --
   P_Mensagem := 0;
   
EXCEPTION
    WHEN OTHERS THEN
    	P_Mensagem := 'ERRO EXCEPTION NA PROCEDURE DE MANUTENÇÃO DE FAIXAS ERRO: '||SQLERRM;
    	ROLLBACK;
    	RAISE_APPLICATION_ERROR(-20021,P_Mensagem);
END SGPB0206;
/

