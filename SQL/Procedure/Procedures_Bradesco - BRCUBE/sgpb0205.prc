CREATE OR REPLACE PROCEDURE SGPB_PROC.sgpb0205(
  p_opcao                   in VARCHAR2,
  p_ccanal_vda_segur        in PARM_CALC_FAIXA_OBJTV_PROD.CCANAL_VDA_SEGUR%type,
  p_cgrp_ramo_plano         in PARM_CALC_FAIXA_OBJTV_PROD.CGRP_RAMO_PLANO%type,
  p_vinic_faixa_prod        in PARM_CALC_FAIXA_OBJTV_PROD.VINIC_FAIXA_PROD%type,
  p_vfnal_faixa_prod        in PARM_CALC_FAIXA_OBJTV_PROD.VFNAL_FAIXA_PROD%type,
  p_cmtodo_calc_objtv_prod  in PARM_CALC_FAIXA_OBJTV_PROD.CMTODO_CALC_OBJTV_PROD%type,
  p_pcalc_objtv_prod        in PARM_CALC_FAIXA_OBJTV_PROD.PCALC_OBJTV_PROD%type,
  p_vcalc_objtv_prod        in PARM_CALC_FAIXA_OBJTV_PROD.VCALC_OBJTV_PROD%type,
  P_Mensagem                out VARCHAR2, 
  P_Cursor_Faixa            out SYS_REFCURSOR
)IS
--*-----------------------------------------------------------------------------------------------
--*      BRADESCO SEGUROS S.A.
--*              SISTEMA : SGPB - INTRANET
--*       FUNCIONALIDADE : FAIXA METAS - PASSO 2
--*            PROCEDURE : SGPB0205
--*                 DATA : 27/08/2007
--*                AUTOR : ALEXANDRE CYSNE ESTEVES
--*             OBJETIVO : PROCEDURE SGPB0204 ANTERIOR POPULOU A TABELA TEMPORARIA 
--*                        PROCEDURE ATUAL FAZ MANUTENCAO NA TABELA TEMPORARIA I-D-V
--*                        E SEMPRE RETORNA UM CURSOR COM TUDO QUE ESTA NA TEMPORARIA
--*          ALTERAÇÕES  :
--*
--*              LOGICA  :
--*                DATA  : -
--*               AUTOR  : -
--*                 OBS  : -
--*-----------------------------------------------------------------------------------------------

  VAR_LOG_ERRO VARCHAR2(1000);
  --chrStatus    VARCHAR2(1) := 'N';

BEGIN

  IF ( p_opcao not in ('I','D','V') ) THEN
       P_Mensagem := 'Procedimento invalido!';
       return;
  END IF;

        --inserindo registro na tabela temporaria
        IF p_opcao = 'I' THEN
        --
        BEGIN

          insert into GTT_PARM_CALC_FAIXA_OBJTV_PROD
                     ( ccanal_vda_segur,
                       cgrp_ramo_plano,
                       vinic_faixa_prod,
                       vfnal_faixa_prod,
                       cmtodo_calc_objtv_prod,
                       pcalc_objtv_prod,
                       vcalc_objtv_prod )
               values( p_ccanal_vda_segur,
                       p_cgrp_ramo_plano,
                       p_vinic_faixa_prod,
                       p_vfnal_faixa_prod,
                       p_cmtodo_calc_objtv_prod,
                       p_pcalc_objtv_prod,
                       p_vcalc_objtv_prod);
        EXCEPTION
           WHEN OTHERS THEN
           VAR_LOG_ERRO := 'INSERT-1 ' || SUBSTR(SQLERRM,1,490);
           ROLLBACK;
           RAISE_APPLICATION_ERROR(-20021,VAR_LOG_ERRO);
        END;
        END IF;
        --
                
        --deletando registro na tabela temporaria
        IF p_opcao = 'D' THEN
        --
        BEGIN

          delete from GTT_PARM_CALC_FAIXA_OBJTV_PROD
                where ccanal_vda_segur = p_ccanal_vda_segur
                  and cgrp_ramo_plano  = p_cgrp_ramo_plano
                  and vinic_faixa_prod = p_vinic_faixa_prod
                  and vfnal_faixa_prod = p_vfnal_faixa_prod
                  and cmtodo_calc_objtv_prod = p_cmtodo_calc_objtv_prod
                  and pcalc_objtv_prod = p_pcalc_objtv_prod
                  and vcalc_objtv_prod = p_vcalc_objtv_prod;

        EXCEPTION
           WHEN OTHERS THEN
           VAR_LOG_ERRO := 'DELETE-1 ' || SUBSTR(SQLERRM,1,490);
           ROLLBACK;
           RAISE_APPLICATION_ERROR(-20021,VAR_LOG_ERRO);
        END;
        END IF;

              --listando tabela temporaria
              OPEN P_Cursor_Faixa FOR
              select T_PCOP.CCANAL_VDA_SEGUR,
                     T_PCOP.CGRP_RAMO_PLANO,
                     T_PCOP.VINIC_FAIXA_PROD,
                     T_PCOP.VFNAL_FAIXA_PROD,
                     T_PCOP.CMTODO_CALC_OBJTV_PROD,
                     T_PCOP.PCALC_OBJTV_PROD,
                     T_PCOP.VCALC_OBJTV_PROD
                from GTT_PARM_CALC_FAIXA_OBJTV_PROD T_PCOP
               order by T_PCOP.VINIC_FAIXA_PROD;
               
        -- function para validar regra de faixa por canal de grupo de ramo
        IF p_opcao = 'V' THEN
            IF Sgpb0044(p_ccanal_vda_segur,p_cgrp_ramo_plano)='N' THEN
              P_Mensagem := 'Faixa invalida!';
              RETURN;
            END IF;
        END IF;
        
--
COMMIT;
--        
        
P_Mensagem := 0;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-99971,'ERRO NA MANUTENCAO DA TEMPORARIA ' || SUBSTR(SQLERRM,1,100));

END sgpb0205;
/

