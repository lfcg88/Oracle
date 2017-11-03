CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0202(
  p_ccanal_vda_segur in apurc_prod_crrtr.ccanal_vda_segur%type,
  p_cgrp_ramo_plano  in apurc_prod_crrtr.cgrp_ramo_plano%type,
  P_Cursor_Faixa     in out SYS_REFCURSOR,
  p_usuario          in varchar2,
  p_operacao         in varchar2,
  p_msg_retorno	     out varchar2,
  p_status_retorno   out varchar2) IS
  -------------------------------------------------------------------------------------------------------------------
  --      Bradesco Seguros s.a.
  --      procedure       : SGPB0202
  --      data            : 23/08/2007
  --      autor           : WASSILY CHUK SEIBLITZ GUANAES
  --      objetivo        : Realiza Consulta, Insert, Delete e Update na PARM_CALC_FAIXA_OBJTV_PROD
  --                        p_operacao = 'C' => FAZ CONSULTA E RETORNA O CURSOR e retorna P_Cursor_Faixa.
  --                        p_operacao = 'U' => Recebe o P_Cursor_Faixa, deleta toda as Faixas para o CANAL e o GRUPO 
  --                                            e insere o CURSOR passado até o limite, ou seja, até P_qtd_Insert.
  --                        p_status_retorno = 'E' => ERRO (Vide mensagem de erro em p_msg_retorno).
  --						p_status_retorno = null => OK 
  --                        
  --                        obs: O campo CMTODO_CALC_OBJTV_PROD ode assumir 1 (Metodo percentual) ou 2 (metodo valor).
  ---------------------------------------------------------------------------------------------------------------------
  VAR_FLAG	INTEGER := 0;
  reg_faixa PARM_CALC_FAIXA_OBJTV_PROD%ROWTYPE; 
BEGIN
  -- Checando Parametros passados
  -- -----------------------------
  IF ( p_operacao not in ('C','U') ) 
  THEN
       p_msg_retorno := 'Operacao Invalida. precisa Ser "C" ou "U".';
       p_status_retorno := 'E';
       return;
  end if;
  IF ( p_usuario is null) 
  THEN
       p_msg_retorno := 'Erro. Usuario Nao Informado.';
       p_status_retorno := 'E';
       return;
  end if;
   BEGIN
      SELECT 1 INTO VAR_FLAG FROM PARM_INFO_CAMPA
              WHERE CCANAL_VDA_SEGUR = p_ccanal_vda_segur;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             p_msg_retorno := 'CANAL INEXISTENTE.';
             RETURN;
    	WHEN OTHERS THEN
    	     p_msg_retorno := 'ERRO NO ACESSO A TABELA DE CANAIS: '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,p_msg_retorno);   
   END;
   BEGIN
      SELECT 1 INTO VAR_FLAG FROM GRP_RAMO_PLANO
              WHERE CGRP_RAMO_PLANO = p_cgrp_ramo_plano;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	     ROLLBACK;
             p_msg_retorno := 'GRUPO INEXISTENTE.';
             RETURN;
    	WHEN OTHERS THEN
    	     p_msg_retorno := 'ERRO NO ACESSO A TABELA DE GRUPOS: '||SQLERRM;
    	     ROLLBACK;
    		 RAISE_APPLICATION_ERROR(-20021,p_msg_retorno);   
   END;
   if p_operacao = 'C' then -- Consulta
      OPEN P_Cursor_Faixa FOR
        SELECT 'ccanal_vda_segur',
           CCANAL_VDA_SEGUR,
           'cgrp_ramo_plano',
           CGRP_RAMO_PLANO,
           'VINIC_FAIXA_PROD',
           VINIC_FAIXA_PROD,
           'VFNAL_FAIXA_PROD',
           VFNAL_FAIXA_PROD,
           'CMTODO_CALC_OBJTV_PROD',
           CMTODO_CALC_OBJTV_PROD,
           'PCALC_OBJTV_PROD',
           PCALC_OBJTV_PROD,           
           'VCALC_OBJTV_PROD',
           VCALC_OBJTV_PROD,
           'DINCL_REG',
           DINCL_REG,
           'DULT_ALT',
           DULT_ALT
        FROM PARM_CALC_FAIXA_OBJTV_PROD
        where CCANAL_VDA_SEGUR = p_ccanal_vda_segur and
              CGRP_RAMO_PLANO = p_cgrp_ramo_plano;
   else
      -- Vai deletar todas as faixas anteriores do CANAL e do GRUPO passado
      BEGIN
          DELETE FROM PARM_CALC_FAIXA_OBJTV_PROD 
                 WHERE CCANAL_VDA_SEGUR = p_ccanal_vda_segur AND
                       CGRP_RAMO_PLANO  = p_cgrp_ramo_plano;
      EXCEPTION
    	    WHEN OTHERS THEN
    	         p_msg_retorno := 'ERRO NO DELETE DA TABELA DE FAIXAS: '||SQLERRM;
    	         ROLLBACK;
    		     RAISE_APPLICATION_ERROR(-20021,p_msg_retorno);   
      END;
      -- vai inserir o Cursor passado.
      BEGIN
           LOOP
    		 FETCH P_Cursor_Faixa INTO reg_faixa;
    		 EXIT WHEN P_Cursor_Faixa%NOTFOUND;
             insert into PARM_CALC_FAIXA_OBJTV_PROD 
                    (CCANAL_VDA_SEGUR, CGRP_RAMO_PLANO,VINIC_FAIXA_PROD,VFNAL_FAIXA_PROD,CMTODO_CALC_OBJTV_PROD,
                    PCALC_OBJTV_PROD, VCALC_OBJTV_PROD,DINCL_REG, DULT_ALT) values
            	    (p_ccanal_vda_segur, p_cgrp_ramo_plano , reg_faixa.VINIC_FAIXA_PROD, 
           		    reg_faixa.VFNAL_FAIXA_PROD,	reg_faixa.CMTODO_CALC_OBJTV_PROD, reg_faixa.PCALC_OBJTV_PROD,
           			reg_faixa.VCALC_OBJTV_PROD,SYSDATE,SYSDATE);
             begin
               -- Logando insert na FAIXA
               INSERT INTO LOG_ERRO_IMPOR (CLOG_ERRO_IMPOR, IPROCS_IMPOR, DERRO_IMPOR, RMSGEM_ERRO_IMPOR)
                           SELECT MAX(CLOG_ERRO_IMPOR)+1, 'SGPB0201', sysdate,
                             'INCLUSAO DE NOVA FAIXA: CCANAL_VDA_SEGUR: '||p_ccanal_vda_segur||' CGRP_RAMO_PLANO: '||
                             p_cgrp_ramo_plano||' VINIC_FAIXA_PROD: '||reg_faixa.VINIC_FAIXA_PROD||
           		             ' VFNAL_FAIXA_PROD: '||reg_faixa.VFNAL_FAIXA_PROD||' CMTODO_CALC_OBJTV_PROD: '||
           		             reg_faixa.CMTODO_CALC_OBJTV_PROD||' PCALC_OBJTV_PROD: '||reg_faixa.PCALC_OBJTV_PROD||
           			         ' VCALC_OBJTV_PROD: '||reg_faixa.VCALC_OBJTV_PROD||' Usuario: '||p_usuario
                            from LOG_ERRO_IMPOR;
             EXCEPTION
  	           WHEN OTHERS THEN
                    p_msg_retorno := 'ERRO. NAO FOI POSSIVEL GRAVAR O LOG. COD.ERRO: '||SQLERRM;
                    ROLLBACK;
    	            RAISE_APPLICATION_ERROR(-20021,p_msg_retorno);   
             END;
           END LOOP;           
      EXCEPTION
    	    WHEN OTHERS THEN
    	         p_msg_retorno := 'ERRO NO INSERT DA TABELA DE FAIXAS: '||SQLERRM;
    	         ROLLBACK;
    		     RAISE_APPLICATION_ERROR(-20021,p_msg_retorno);   
      END;         
   end if;   
   COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    	p_msg_retorno := 'ERRO EXCEPTION NA PROCEDURE DE MANUTENÇÃO DE FAIXAS ERRO: '||SQLERRM;
    	ROLLBACK;
    	RAISE_APPLICATION_ERROR(-20021,p_msg_retorno);
END SGPB0202;
/

