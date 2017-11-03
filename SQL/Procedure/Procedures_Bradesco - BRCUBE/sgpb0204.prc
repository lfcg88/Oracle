CREATE OR REPLACE PROCEDURE SGPB_PROC.sgpb0204(
  p_usuario          in VARCHAR2,
  p_ccanal_vda_segur in PARM_CALC_FAIXA_OBJTV_PROD.CCANAL_VDA_SEGUR%type,
  p_cgrp_ramo_plano  in PARM_CALC_FAIXA_OBJTV_PROD.CGRP_RAMO_PLANO%type,
  P_Mensagem         out VARCHAR2,
  P_Cursor_Faixa     out SYS_REFCURSOR
) IS
--*-----------------------------------------------------------------------------------------------
--*      BRADESCO SEGUROS S.A.
--*              SISTEMA : SGPB - INTRANET
--*       FUNCIONALIDADE : FAIXA METAS - PASSO 1
--*            PROCEDURE : SGPB0204
--*                 DATA : 27/08/2007
--*                AUTOR : ALEXANDRE CYSNE ESTEVES
--*             OBJETIVO : CARREGAR DADOS DA TABELA PARM_CALC_FAIXA_OBJTV_PROD PARA A
--*                        TEMPORARIA GTT_PARM_CALC_FAIXA_OBJTV_PROD
--*          ALTERAÇÕES  :
--*
--*              LOGICA  :
--*                DATA  : -
--*               AUTOR  : -
--*                 OBS  : -
--*-----------------------------------------------------------------------------------------------

  -- registro
  r_reg_pcfop PARM_CALC_FAIXA_OBJTV_PROD%rowtype;
  --criando o cursor T_CORRETOR
  TYPE T_CORRETOR IS REF CURSOR;
  --variavel C_CURSOR cursor
  C_CURSOR T_CORRETOR;
  VAR_LOG_ERRO VARCHAR2(1000);
  VAR_FLAG	INTEGER := 0;

BEGIN

    --usuario
    IF ( p_usuario is null) THEN
         P_Mensagem := 'Erro. Usuario Nao Informado.';
         return;
    END IF;
    --canal
    BEGIN
      SELECT DISTINCT 1 INTO VAR_FLAG FROM PARM_INFO_CAMPA
              WHERE CCANAL_VDA_SEGUR = p_ccanal_vda_segur;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             P_Mensagem := 'CANAL INEXISTENTE.';
             RETURN;
    	WHEN OTHERS THEN
    	     P_Mensagem := 'ERRO NO ACESSO A TABELA DE CANAIS: '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,P_Mensagem);
    END;
    --grupo ramo
    BEGIN
      SELECT 1 INTO VAR_FLAG FROM GRP_RAMO_PLANO
              WHERE CGRP_RAMO_PLANO = p_cgrp_ramo_plano;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             P_Mensagem := 'GRUPO INEXISTENTE.';
             RETURN;
    	WHEN OTHERS THEN
    	     P_Mensagem := 'ERRO NO ACESSO A TABELA DE GRUPOS: '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,P_Mensagem);   
    END;
    --limpando a tabela temporaria
    BEGIN
     DELETE FROM GTT_PARM_CALC_FAIXA_OBJTV_PROD;
    EXCEPTION
     WHEN OTHERS THEN
     VAR_LOG_ERRO := 'DELETE-1 ' || SUBSTR(SQLERRM,1,490);
     ROLLBACK;
     RAISE_APPLICATION_ERROR(-20021,VAR_LOG_ERRO);
    END;
    --
    COMMIT;
    --
             
                OPEN C_CURSOR FOR
              select PCOP.CCANAL_VDA_SEGUR,
                     PCOP.CGRP_RAMO_PLANO,
                     PCOP.VINIC_FAIXA_PROD,
                     PCOP.VFNAL_FAIXA_PROD,
                     PCOP.CMTODO_CALC_OBJTV_PROD,
                     PCOP.PCALC_OBJTV_PROD,
                     PCOP.VCALC_OBJTV_PROD
                from PARM_CALC_FAIXA_OBJTV_PROD PCOP
               where PCOP.CCANAL_VDA_SEGUR = p_ccanal_vda_segur
                 and PCOP.CGRP_RAMO_PLANO = p_cgrp_ramo_plano;
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
                   BEGIN

                        begin
                          --inserindo registros na tabela temporaria
                          insert into GTT_PARM_CALC_FAIXA_OBJTV_PROD
                                     ( ccanal_vda_segur,
                                       cgrp_ramo_plano,
                                       vinic_faixa_prod,
                                       vfnal_faixa_prod,
                                       cmtodo_calc_objtv_prod,
                                       pcalc_objtv_prod,
                                       vcalc_objtv_prod )
                               values( r_reg_pcfop.ccanal_vda_segur,
                                       r_reg_pcfop.cgrp_ramo_plano,
                                       r_reg_pcfop.vinic_faixa_prod,
                                       r_reg_pcfop.vfnal_faixa_prod,
                                       r_reg_pcfop.cmtodo_calc_objtv_prod,
                                       r_reg_pcfop.pcalc_objtv_prod,
                                       r_reg_pcfop.vcalc_objtv_prod);
                        EXCEPTION
                           WHEN OTHERS THEN
                           VAR_LOG_ERRO := 'INSERT-1 ' || SUBSTR(SQLERRM,1,490);
                           ROLLBACK;
                           RAISE_APPLICATION_ERROR(-20021,VAR_LOG_ERRO);
                        end;
                   --
                   END;
	            --
              END LOOP;
	            --
              COMMIT;
              CLOSE C_CURSOR;
                         
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
               where T_PCOP.CCANAL_VDA_SEGUR = p_ccanal_vda_segur
                 and T_PCOP.CGRP_RAMO_PLANO = p_cgrp_ramo_plano;               
                 
--
P_Mensagem := 0;
--
EXCEPTION
    WHEN OTHERS THEN
    	P_Mensagem := 'ERRO EXCEPTION NA PROCEDURE DE MANUTENÇÃO DE FAIXAS ERRO: '||SQLERRM;
    	ROLLBACK;
    	RAISE_APPLICATION_ERROR(-20021,P_Mensagem);

END sgpb0204;
/

