CREATE OR REPLACE FUNCTION SGPB_PROC.Sgpb0044(
p_ccanal_vda_segur        in GTT_PARM_CALC_FAIXA_OBJTV_PROD.CCANAL_VDA_SEGUR%type,
p_cgrp_ramo_plano         in GTT_PARM_CALC_FAIXA_OBJTV_PROD.CGRP_RAMO_PLANO%type
) RETURN VARCHAR2 AS
--*-----------------------------------------------------------------------------------------------
--*      BRADESCO SEGUROS S.A.
--*              SISTEMA : SGPB - INTRANET
--*       FUNCIONALIDADE : FAIXA METAS
--*             FUNCTION : SGPB0044
--*                 DATA : 27/08/2007
--*                AUTOR : ALEXANDRE CYSNE ESTEVES
--*             OBJETIVO : FUNCAO QUE VALIDA REGRA CRIADA PARA FAIXA
--*          ALTERAÇÕES  :
--*
--*              LOGICA  :
--*                DATA  : -
--*               AUTOR  : -
--*                 OBS  : -
--*-----------------------------------------------------------------------------------------------
Retorno VARCHAR2(1);
v_vinic_faixa_prod_a  GTT_PARM_CALC_FAIXA_OBJTV_PROD.VINIC_FAIXA_PROD%type;
v_vfnal_faixa_prod_a  GTT_PARM_CALC_FAIXA_OBJTV_PROD.VINIC_FAIXA_PROD%type;
v_vinic_faixa_prod_d  GTT_PARM_CALC_FAIXA_OBJTV_PROD.VINIC_FAIXA_PROD%type;
v_vfnal_faixa_prod_d  GTT_PARM_CALC_FAIXA_OBJTV_PROD.VINIC_FAIXA_PROD%type;
v_seg NUMBER(30) := 0;

BEGIN

   --validando se faixa inicial e maior que faixa final
   BEGIN             
    FOR REG IN ( select T_PCOP.VINIC_FAIXA_PROD,
                        T_PCOP.VFNAL_FAIXA_PROD
                   from GTT_PARM_CALC_FAIXA_OBJTV_PROD T_PCOP
                  where T_PCOP.CCANAL_VDA_SEGUR = p_ccanal_vda_segur
                    and T_PCOP.CGRP_RAMO_PLANO = p_cgrp_ramo_plano
                  order by T_PCOP.VINIC_FAIXA_PROD)
    LOOP           
        v_vinic_faixa_prod_d := REG.VINIC_FAIXA_PROD;
        v_vfnal_faixa_prod_d := REG.VFNAL_FAIXA_PROD;                 
        if (v_vinic_faixa_prod_d > v_vfnal_faixa_prod_d) then
        		Retorno := 'N';                
            RETURN Retorno;
        end if;                                             
    END LOOP;              
   EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK;
     RAISE_APPLICATION_ERROR(-20021,'');
   END;
   --

             --validando intervalo das faixas
             BEGIN             
              FOR REG IN ( select T_PCOP.VINIC_FAIXA_PROD,
                                  T_PCOP.VFNAL_FAIXA_PROD
                             from GTT_PARM_CALC_FAIXA_OBJTV_PROD T_PCOP
                            where T_PCOP.CCANAL_VDA_SEGUR = p_ccanal_vda_segur
                              and T_PCOP.CGRP_RAMO_PLANO = p_cgrp_ramo_plano
                            order by T_PCOP.VINIC_FAIXA_PROD)
              LOOP
                --opcao para primeira vez no loop
                if v_seg = 0 then
                  v_vinic_faixa_prod_a := REG.VINIC_FAIXA_PROD;
                  v_vfnal_faixa_prod_a := REG.VFNAL_FAIXA_PROD;                 
                end if;
               
                --opcao para as seguintes do loop
                if v_seg != 0 then
                  v_vinic_faixa_prod_d := REG.VINIC_FAIXA_PROD;
                  v_vfnal_faixa_prod_d := REG.VFNAL_FAIXA_PROD;
                  
                  if ((v_vinic_faixa_prod_d - v_vfnal_faixa_prod_a) != 1) then
                  		Retorno := 'N';                
                      RETURN Retorno;
                  end if;

                  v_vinic_faixa_prod_a := REG.VINIC_FAIXA_PROD;
                  v_vfnal_faixa_prod_a := REG.VFNAL_FAIXA_PROD;                 

                end if;
                v_seg := v_seg + 1;
                                  
              END LOOP;              
             EXCEPTION
               WHEN OTHERS THEN
               ROLLBACK;
               RAISE_APPLICATION_ERROR(-20021,'');
             END;
    --
		Retorno := 'S';
		RETURN Retorno;
    --
EXCEPTION
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-99971,'ERRO NA FUNCAO PARA VALIDACAO DA FAIXA' || SUBSTR(SQLERRM,1,100));
END Sgpb0044;
/

