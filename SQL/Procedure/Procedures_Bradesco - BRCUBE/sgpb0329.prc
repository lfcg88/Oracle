create or replace procedure sgpb_proc.SGPB0329(intrCodCanal  in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
                                     chrNomeCanal  out CANAL_VDA_SEGUR.ICANAL_VDA_SEGUR %TYPE,
                                     intrCPF_CNPJ  in CRRTR.CCPF_CNPJ_CRRTR %type,
                                     chrTpPessoa   in CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
                                     intrGrupoRamo out PROD_CRRTR.CGRP_RAMO_PLANO %TYPE,                                     
                                     
                                     intrPEL_MES1_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES2_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES3_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_TRI_AUTO  out PROD_CRRTR.VPROD_CRRTR%TYPE,    
                                                                      
                                     intrOBJ_MES1_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES2_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES3_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_TRI_AUTO  out PROD_CRRTR.VPROD_CRRTR%TYPE,                                     
                                     
                                     intrPERC_MES1_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES2_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES3_AUTO out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_TRI_AUTO  out PROD_CRRTR.VPROD_CRRTR%TYPE,                                     
                                     
                                     intrPEL_MES1_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES2_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES3_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_TRI_RE  out PROD_CRRTR.VPROD_CRRTR%TYPE,                                     
                                     
                                     intrOBJ_MES1_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES2_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES3_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_TRI_RE  out PROD_CRRTR.VPROD_CRRTR%TYPE,                                     
                                     
                                     intrPERC_MES1_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES2_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES3_RE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_TRI_RE  out PROD_CRRTR.VPROD_CRRTR%TYPE,                                     
                                     
                                     intrPEL_MES1_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES2_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_MES3_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPEL_TRI_BILHETE  out PROD_CRRTR.VPROD_CRRTR%TYPE,                                     
                                     
                                     intrOBJ_MES1_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES2_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_MES3_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrOBJ_TRI_BILHETE  out PROD_CRRTR.VPROD_CRRTR%TYPE,                                     
                                     
                                     intrPERC_MES1_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES2_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_MES3_BILHETE out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     intrPERC_TRI_BILHETE  out PROD_CRRTR.VPROD_CRRTR%TYPE,
                                     
                                     intrANO       in number,
                                     intrTRIMESTRE in number,
                                     
                                     dtDataApuracao out date)
                                     
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0151
  --      DATA            : 24/01/2007
  --      AUTOR           : Luiz Vitor - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Recupero os valores de PRODUCAO, OBJETIVO e PERCENTUAL por trimestre, para o SITE CORRETOR (On-Line).
  --      ALTERAÇÕES      : 
  --                DATA  : 
  --                AUTOR : 
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
BEGIN

    if (intrCodCanal = 1) then
    
      sgpb0151(
                 intrCodCanal,
                 chrNomeCanal,
                 intrCPF_CNPJ,
                 chrTpPessoa,
                 intrGrupoRamo,
                 
                 intrPEL_MES1_AUTO,
                 intrPEL_MES2_AUTO,
                 intrPEL_MES3_AUTO,
                 intrPEL_TRI_AUTO,
                                                  
                 intrOBJ_MES1_AUTO,
                 intrOBJ_MES2_AUTO,
                 intrOBJ_MES3_AUTO,
                 intrOBJ_TRI_AUTO,
                 
                 intrPERC_MES1_AUTO,
                 intrPERC_MES2_AUTO,
                 intrPERC_MES3_AUTO,
                 intrPERC_TRI_AUTO,
                 
                 intrPEL_MES1_RE,
                 intrPEL_MES2_RE,
                 intrPEL_MES3_RE,
                 intrPEL_TRI_RE,
                 
                 intrOBJ_MES1_RE,
                 intrOBJ_MES2_RE,
                 intrOBJ_MES3_RE,
                 intrOBJ_TRI_RE,
                 
                 intrPERC_MES1_RE,
                 intrPERC_MES2_RE,
                 intrPERC_MES3_RE,
                 intrPERC_TRI_RE,
                 
                 intrPEL_MES1_BILHETE,
                 intrPEL_MES2_BILHETE,
                 intrPEL_MES3_BILHETE,
                 intrPEL_TRI_BILHETE,
                 
                 intrOBJ_MES1_BILHETE,
                 intrOBJ_MES2_BILHETE,
                 intrOBJ_MES3_BILHETE,
                 intrOBJ_TRI_BILHETE,
                 
                 intrPERC_MES1_BILHETE,
                 intrPERC_MES2_BILHETE,
                 intrPERC_MES3_BILHETE,
                 intrPERC_TRI_BILHETE,
                 
                 intrANO,
                 intrTRIMESTRE,
                 
                 dtDataApuracao
      );
    
    else
    
      sgpb0150(
                 intrCodCanal,
                 chrNomeCanal,
                 intrCPF_CNPJ,
                 chrTpPessoa,
                 intrGrupoRamo,
                 
                 intrPEL_MES1_AUTO,
                 intrPEL_MES2_AUTO,
                 intrPEL_MES3_AUTO,
                 intrPEL_TRI_AUTO,
                                                  
                 intrOBJ_MES1_AUTO,
                 intrOBJ_MES2_AUTO,
                 intrOBJ_MES3_AUTO,
                 intrOBJ_TRI_AUTO,
                 
                 intrPERC_MES1_AUTO,
                 intrPERC_MES2_AUTO,
                 intrPERC_MES3_AUTO,
                 intrPERC_TRI_AUTO,
                 
                 intrPEL_MES1_RE,
                 intrPEL_MES2_RE,
                 intrPEL_MES3_RE,
                 intrPEL_TRI_RE,
                 
                 intrOBJ_MES1_RE,
                 intrOBJ_MES2_RE,
                 intrOBJ_MES3_RE,
                 intrOBJ_TRI_RE,
                 
                 intrPERC_MES1_RE,
                 intrPERC_MES2_RE,
                 intrPERC_MES3_RE,
                 intrPERC_TRI_RE,
                 
                 intrPEL_MES1_BILHETE,
                 intrPEL_MES2_BILHETE,
                 intrPEL_MES3_BILHETE,
                 intrPEL_TRI_BILHETE,
                 
                 intrOBJ_MES1_BILHETE,
                 intrOBJ_MES2_BILHETE,
                 intrOBJ_MES3_BILHETE,
                 intrOBJ_TRI_BILHETE,
                 
                 intrPERC_MES1_BILHETE,
                 intrPERC_MES2_BILHETE,
                 intrPERC_MES3_BILHETE,
                 intrPERC_TRI_BILHETE,
                 
                 intrANO,
                 intrTRIMESTRE,
                 
                 dtDataApuracao
      );
    
    
    end if;


END SGPB0329;
/

