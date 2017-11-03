CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0329_20070125 (intrCodCanal  in CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR %TYPE,
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
                                     
                                     dtDataApuracao out date
                                     
                                     )
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0329
  --      DATA            : 11/01/2007
  --      AUTOR           : Bruno Marcondes - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Recupero os valores de PRODUCAO, OBJETIVO e PERCENTUAL por trimestre, para o SITE CORRETOR (On-Line).
  --      ALTERAÇÕES      : 
  --                DATA  : 
  --                AUTOR : 
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  --
  --
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  chrNomeRotinaScheduler VARCHAR2(8) := 'SGPB0329';
  intrDtINIVig           number;
  intrDtFIMVig           number;
  intrFALTA_PRODUZIR     number := 0;
  intrPRODUCAO           number := 0;
  intrOBJETIVO           number := 0;
  --  intrCRRTR_ANTES          CRRTR.CCPF_CNPJ_CRRTR%type := 0;
  intrCPF_CNPJ_base        CRRTR.CCPF_CNPJ_BASE%type := 0;
  DtDataApuracao_validacao date := to_date('01011900', 'ddmmyyyy');

  --
  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  begin
    Declare
    
      Cursor CURSOR1 is
        SELECT CVS.ICANAL_VDA_SEGUR NOME_CANAL,
               OPC.CGRP_RAMO_PLANO GRUPO_RAMO,
               SUBSTR(OPC.CANO_MES_COMPT_OBJTV, 5, 2) MES_COMPET,
               OPC.VOBJTV_PROD_CRRTR_ALT VOBJTV_PROD_CRRTR_ALT,
               C.CCRRTR,
               C.CUND_PROD
        
          FROM OBJTV_PROD_CRRTR OPC
        
          JOIN CANAL_VDA_SEGUR CVS ON OPC.CCANAL_VDA_SEGUR =
                                      CVS.CCANAL_VDA_SEGUR
        
          JOIN CRRTR C ON OPC.CTPO_PSSOA = C.CTPO_PSSOA
                      AND OPC.CCPF_CNPJ_BASE = C.CCPF_CNPJ_BASE
        
         WHERE OPC.CANO_MES_COMPT_OBJTV between intrDtINIVig and
               intrDtFIMVig
           AND OPC.CIND_REG_ATIVO = 'S'
              
           AND CVS.CCANAL_VDA_SEGUR = intrCodCanal
           AND C.CTPO_PSSOA = chrTpPessoa
           AND C.CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE
           and intrCodCanal != 1
        
        union
        
        SELECT CVS.ICANAL_VDA_SEGUR NOME_CANAL,
               PC.CGRP_RAMO_PLANO GRUPO_RAMO,
               nvl(SUBSTR(PC.CCOMPT_PROD, 5, 2), '99') MES_COMPET,
               --               (NVL(PC.VPROD_CRRTR, 0) *
               --               ((NVL(CCC.PCRSCT_PROD_ALT, PCVS.PCRSTC_PROD_ANO) / 100) + 1)) VL_OBJETIVO,
               case
                 when PC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto then
                  (NVL(PC.VPROD_CRRTR, 1) *
                  ((NVL(CCC.PCRSCT_PROD_ALT, PCVS.PCRSTC_PROD_ANO) / 100) + 1))
                 when PC.CGRP_RAMO_PLANO = PC_UTIL_01.Re then
                  PPMC.VMIN_PROD_CRRTR
                 when PC.CGRP_RAMO_PLANO = PC_UTIL_01.ReTodos then
                  PPMC.VMIN_PROD_CRRTR
               end as VL_objetivo,
               C.CCRRTR,
               C.CUND_PROD
        
          FROM CRRTR_ELEIT_CAMPA CEC
        
          JOIN CANAL_VDA_SEGUR CVS ON CEC.CCANAL_VDA_SEGUR =
                                      CVS.CCANAL_VDA_SEGUR
        
          JOIN PARM_INFO_CAMPA PIC ON PIC.CCANAL_VDA_SEGUR =
                                      CEC.CCANAL_VDA_SEGUR
                                  AND PIC.DINIC_VGCIA_PARM =
                                      CEC.DINIC_VGCIA_PARM
        
          LEFT JOIN CARAC_CRRTR_CANAL CCC ON CCC.CCANAL_VDA_SEGUR =
                                             CEC.CCANAL_VDA_SEGUR
                                         AND CCC.DINIC_VGCIA_PARM =
                                             CEC.DINIC_VGCIA_PARM
                                         AND CCC.CCPF_CNPJ_BASE =
                                             CEC.CCPF_CNPJ_BASE
                                         AND CCC.CTPO_PSSOA =
                                             CEC.CTPO_PSSOA
                                         AND CCC.Cind_Perc_Ativo = 'S'
        
          JOIN CRRTR C ON C.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
                      AND C.CTPO_PSSOA = CEC.CTPO_PSSOA
        
          LEFT JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                                 AND PC.CUND_PROD = C.CUND_PROD
                                 AND PC.CTPO_COMIS = 'CN'
                                 AND PC.CCOMPT_PROD between intrDtINIVig and
                                     intrDtFIMVig
                                 AND PC.CGRP_RAMO_PLANO IN
                                     (PC_UTIL_01.Auto, PC_UTIL_01.Re,
                                      PC_UTIL_01.ReTodos)
        
          JOIN PARM_CANAL_VDA_SEGUR PCVS ON PCVS.CCANAL_VDA_SEGUR =
                                            CEC.CCANAL_VDA_SEGUR
                                        AND to_date(intrDtINIVig || '01',
                                                    'YYYYMMDD') BETWEEN
                                            PCVS.DINIC_VGCIA_PARM AND
                                            NVL(PCVS.DFIM_VGCIA_PARM,
                                                TO_DATE('31/12/9999',
                                                        'dd/MM/YYYY'))
        
          JOIN PARM_PROD_MIN_CRRTR PPMC ON PPMC.CCANAL_VDA_SEGUR =
                                           PC_UTIL_01.Extra_Banco
                                       AND PPMC.CGRP_RAMO_PLANO =
                                           PC_UTIL_01.RE
                                       AND PPMC.CTPO_PSSOA = C.CTPO_PSSOA
                                       AND PPMC.CTPO_PER = 'M'
                                       AND Last_Day(To_Date(nvl(PC.CCOMPT_PROD,
                                                                intrDtINIVig),
                                                            'YYYYMM')) BETWEEN
                                           PPMC.DINIC_VGCIA_PARM AND
                                           NVL(PPMC.DFIM_VGCIA_PARM,
                                               TO_DATE('99991231',
                                                       'YYYYMMDD'))
        
         WHERE 1 = 1
           AND CEC.CCANAL_VDA_SEGUR = 1
           AND C.CCPF_CNPJ_BASE = intrCPF_CNPJ_BASE
           AND C.CTPO_PSSOA = chrTpPessoa
           AND intrCodCanal = 1;
    
      -- Termino Cursor CURSOR1
      -- Inicio Cursor CURSOR2
      Cursor CURSOR2(P_CORRET CRRTR.CCRRTR%type, P_UND_PROD CRRTR.CUND_PROD%type, P_MES_COMPT varchar2, P_GRP_RAMO AGPTO_RAMO_PLANO.CGRP_RAMO_PLANO%type) is
        SELECT APC.CCRRTR AS CORRETOR,
               APC.CUND_PROD AS UNID_PROD,
               ARP.CGRP_RAMO_PLANO AS GRUPO_RAMO,
               to_char(APC.DEMIS_APOLC, 'YYYYMM') MES,
               max(APC.DEMIS_APOLC) MES_APUR,
               SUM(CASE
                     WHEN APC.CTPO_DOCTO = 'D' THEN
                      APC.VPRMIO_EMTDO_APOLC
                     ELSE
                      0
                   END) TOT_VR_PROD_ENDOSSO,
               SUM(CASE
                     WHEN APC.CTPO_DOCTO = 'M' THEN
                      APC.VPRMIO_EMTDO_APOLC
                     ELSE
                      0
                   END) TOT_VR_PROD_EMISSAO,
               SUM(CASE
                     WHEN APC.CTPO_DOCTO = 'C' THEN
                      APC.VPRMIO_EMTDO_APOLC
                     ELSE
                      0
                   END) TOT_VR_PROD_CANC,
               
               SUM(CASE
                     WHEN APC.CTPO_DOCTO = 'D' THEN
                      1
                     ELSE
                      0
                   END) TOT_QTD_ENDOSSO,
               SUM(CASE
                     WHEN APC.CTPO_DOCTO = 'M' THEN
                      1
                     ELSE
                      0
                   END) TOT_QTD_EMISSAO,
               SUM(CASE
                     WHEN APC.CTPO_DOCTO = 'C' THEN
                      1
                     ELSE
                      0
                   END) TOT_QTD_CANC
        
          FROM APOLC_PROD_CRRTR APC
        
          JOIN AGPTO_RAMO_PLANO ARP ON ARP.CRAMO = APC.CRAMO_APOLC
        
         WHERE APC.DEMIS_APOLC between
               to_date(intrDtINIVig || '01', 'YYYYMMDD') and
               last_day(to_date(intrDtFIMVig || '01', 'YYYYMMDD'))
           and to_char(APC.DEMIS_APOLC, 'MM') = P_MES_COMPT
           AND APC.CCRRTR = P_CORRET
           AND APC.CUND_PROD = P_UND_PROD
           and ARP.CGRP_RAMO_PLANO = P_GRP_RAMO
         GROUP BY APC.CCRRTR,
                  APC.CUND_PROD,
                  ARP.CGRP_RAMO_PLANO,
                  to_char(APC.DEMIS_APOLC, 'YYYYMM');
    
      -- Termino Cursor CURSOR2
    
      C2 CURSOR2%rowtype;
      C  CURSOR1%rowtype;
    
    BEGIN
    
      If intrTRIMESTRE = 1 then
        -- JANEIRO / FEVEREIRO / MARCO
        intrDtINIVig := to_number(intrANO || '01');
        intrDtFIMVig := to_number(intrANO || '03');
      Elsif intrTRIMESTRE = 2 then
        -- ABRIL / MAIO / JUNHO
        intrDtINIVig := to_number(intrANO || '04');
        intrDtFIMVig := to_number(intrANO || '06');
      Elsif intrTRIMESTRE = 3 then
        -- JULHO / AGOSTO / SETEMBRO
        intrDtINIVig := to_number(intrANO || '07');
        intrDtFIMVig := to_number(intrANO || '09');
      Elsif intrTRIMESTRE = 4 then
        -- OUTUBRO / NOVEMBRO / DEZEMBRO
        intrDtINIVig := to_number(intrANO || '10');
        intrDtFIMVig := to_number(intrANO || '12');
      End If;
    
      -- É passado o CPF_CNPJ completo por isso, calculo o CPF_CNPJ_BASE.
      If chrTpPessoa = 'F' then
        intrCPF_CNPJ_BASE := substr(intrCPF_CNPJ,
                                    1,
                                    length(intrCPF_CNPJ) - 2);
      Else
        intrCPF_CNPJ_BASE := substr(intrCPF_CNPJ,
                                    1,
                                    length(intrCPF_CNPJ) - 6);
      End If;
    
      Open CURSOR1;
      Loop
        Fetch CURSOR1
          into C;
        Exit when CURSOR1%notfound;
        --
        -- Popula as variáveis de saída
      
        chrNomeCanal  := C.NOME_CANAL;
        intrGrupoRamo := C.GRUPO_RAMO;
      
        Open CURSOR2(C.CCRRTR, C.CUND_PROD, C.MES_COMPET, C.GRUPO_RAMO);
        Loop
          Fetch CURSOR2
            into C2;
          Exit when CURSOR2%notfound;
        
          intrPRODUCAO := (nvl(C2.TOT_VR_PROD_ENDOSSO, 0) +
                          nvl(C2.TOT_VR_PROD_EMISSAO, 0)) -
                          nvl(C2.TOT_VR_PROD_CANC, 0);
          intrOBJETIVO := nvl(C.VOBJTV_PROD_CRRTR_ALT, 0); -- Caso Canal 1 VL_OBJETIVO (ver Cursor1)
        
          intrFALTA_PRODUZIR := intrOBJETIVO - intrPRODUCAO;
        
          -- No caso de ser o primeiro mês de cada TRIMESTRE
          If C.MES_COMPET in ('01', '04', '07', '10') then
          
            -- Para AUTO (Grupo Ramo 120)
            If C.GRUPO_RAMO = PC_UTIL_01.Auto then
              intrPEL_MES1_AUTO := nvl(intrPEL_MES1_AUTO, 0) +
                                   nvl(intrPRODUCAO, 0);
            
              -- Para Canal 1 (Extra-banco) o objetivo é somado dentro do mesmo CPF/CNPJ.
              If intrCodCanal = 1 then
                --                If C.CCRRTR != intrCRRTR_ANTES then
                intrOBJ_MES1_AUTO := nvl(intrOBJ_MES1_AUTO, 0) +
                                     nvl(intrOBJETIVO, 0);
                --                End If;
              Else
                intrOBJ_MES1_AUTO := nvl(intrOBJETIVO, 0);
              End If;
            
              intrPERC_MES1_AUTO := (intrPEL_MES1_AUTO / intrOBJ_MES1_AUTO) * 100;
            End If;
          
            -- Para RE (Grupo Ramo 999)
            If ((C.GRUPO_RAMO = PC_UTIL_01.Re and intrCodCanal IN (1, 3)) or
               (C.GRUPO_RAMO = PC_UTIL_01.ReTodos and intrCodCanal = 2)) then
            
              intrPEL_MES1_RE := nvl(intrPEL_MES1_RE, 0) +
                                 nvl(intrPRODUCAO, 0);
            
              -- Para Canal 1 (Extra-banco) o objetivo é somado dentro do mesmo CPF/CNPJ.
              If intrCodCanal = 1 then
                --                If C.CCRRTR != intrCRRTR_ANTES then
                intrOBJ_MES1_RE := nvl(intrOBJ_MES1_RE, 0) +
                                   nvl(intrOBJETIVO, 0);
                --                End If;
              Else
                intrOBJ_MES1_RE := nvl(intrOBJETIVO, 0);
              End If;
            
              intrPERC_MES1_RE := (intrPEL_MES1_RE / intrOBJ_MES1_RE) * 100;
            End If;
          
            -- Para Bilhete (Grupo Ramo 810)
            If C.GRUPO_RAMO = PC_UTIL_01.Re then
              intrPEL_MES1_BILHETE := nvl(intrPEL_MES1_BILHETE, 0) +
                                      nvl(intrPRODUCAO, 0);
            
              intrOBJ_MES1_BILHETE := nvl(intrOBJ_MES1_BILHETE, 0) +
                                      nvl(intrOBJETIVO, 0);
            
              intrPERC_MES1_BILHETE := (intrPEL_MES1_BILHETE /
                                       intrOBJ_MES1_BILHETE) * 100;
            
            End If;
          
            -- No caso de ser o segundo mês de cada TRIMESTRE
          Elsif C.MES_COMPET in ('02', '05', '08', '11') then
          
            -- Para AUTO (Grupo Ramo 120)
            If C.GRUPO_RAMO = PC_UTIL_01.Auto then
              intrPEL_MES2_AUTO := nvl(intrPEL_MES2_AUTO, 0) +
                                   nvl(intrPRODUCAO, 0);
            
              -- Para Canal 1 (Extra-banco) o objetivo é somado dentro do mesmo CPF/CNPJ.
              If intrCodCanal = 1 then
                --                If C.CCRRTR != intrCRRTR_ANTES then
                intrOBJ_MES2_AUTO := nvl(intrOBJ_MES2_AUTO, 0) +
                                     nvl(intrOBJETIVO, 0);
                --                End If;
              Else
                intrOBJ_MES2_AUTO := nvl(intrOBJETIVO, 0);
              End If;
            
              intrPERC_MES2_AUTO := (intrPEL_MES2_AUTO / intrOBJ_MES2_AUTO) * 100;
            End If;
          
            -- Para RE (Grupo Ramo 999)
            If ((C.GRUPO_RAMO = PC_UTIL_01.Re and intrCodCanal IN (1, 3)) or
               (C.GRUPO_RAMO = PC_UTIL_01.ReTodos and intrCodCanal = 2)) then
            
              intrPEL_MES2_RE := nvl(intrPEL_MES2_RE, 0) +
                                 nvl(intrPRODUCAO, 0);
            
              -- Para Canal 1 (Extra-banco) o objetivo é somado dentro do mesmo CPF/CNPJ.
              If intrCodCanal = 1 then
                --                If C.CCRRTR != intrCRRTR_ANTES then
                intrOBJ_MES2_RE := nvl(intrOBJ_MES2_RE, 0) +
                                   nvl(intrOBJETIVO, 0);
                --                End If;
              Else
                intrOBJ_MES2_RE := nvl(intrOBJETIVO, 0);
              End If;
            
              intrPERC_MES2_RE := (intrPEL_MES2_RE / intrOBJ_MES2_RE) * 100;
            End If;
          
            -- Para Bilhete (Grupo Ramo 810)
            If C.GRUPO_RAMO = PC_UTIL_01.Re then
              intrPEL_MES2_BILHETE := nvl(intrPEL_MES2_BILHETE, 0) +
                                      nvl(intrPRODUCAO, 0);
            
              intrOBJ_MES2_BILHETE := nvl(intrOBJ_MES2_BILHETE, 0) +
                                      nvl(intrOBJETIVO, 0);
            
              intrPERC_MES2_BILHETE := (intrPEL_MES2_BILHETE /
                                       intrOBJ_MES2_BILHETE) * 100;
            
            End If;
          
            -- No caso de ser o terceiro mês de cada TRIMESTRE
          Elsif C.MES_COMPET in ('03', '06', '09', '12') then
          
            -- Para AUTO (Grupo Ramo 120)
            If C.GRUPO_RAMO = PC_UTIL_01.Auto then
              intrPEL_MES3_AUTO := nvl(intrPEL_MES3_AUTO, 0) +
                                   nvl(intrPRODUCAO, 0);
            
              -- Para Canal 1 (Extra-banco) o objetivo é somado dentro do mesmo CPF/CNPJ.
              If intrCodCanal = 1 then
                --                If C.CCRRTR != intrCRRTR_ANTES then
                intrOBJ_MES3_AUTO := nvl(intrOBJ_MES3_AUTO, 0) +
                                     nvl(intrOBJETIVO, 0);
                --                End If;
              Else
                intrOBJ_MES3_AUTO := nvl(intrOBJETIVO, 0);
              End If;
            
              intrPERC_MES3_AUTO := (intrPEL_MES3_AUTO / intrOBJ_MES3_AUTO) * 100;
            End If;
          
            -- Para RE (Grupo Ramo 999)
            If ((C.GRUPO_RAMO = PC_UTIL_01.Re and intrCodCanal IN (1, 3)) or
               (C.GRUPO_RAMO = PC_UTIL_01.ReTodos and intrCodCanal = 2)) then
            
              intrPEL_MES3_RE := nvl(intrPEL_MES3_RE, 0) +
                                 nvl(intrPRODUCAO, 0);
            
              -- Para Canal 1 (Extra-banco) o objetivo é somado dentro do mesmo CPF/CNPJ.
              If intrCodCanal = 1 then
                --                If C.CCRRTR != intrCRRTR_ANTES then
                intrOBJ_MES3_RE := nvl(intrOBJ_MES3_RE, 0) +
                                   nvl(intrOBJETIVO, 0);
                --                End If;
              Else
                intrOBJ_MES3_RE := nvl(intrOBJETIVO, 0);
              End If;
            
              intrPERC_MES3_RE := (intrPEL_MES3_RE / intrOBJ_MES3_RE) * 100;
            End If;
          
            -- Para Bilhete (Grupo Ramo 810)
            If C.GRUPO_RAMO = PC_UTIL_01.Re then
              intrPEL_MES3_BILHETE := nvl(intrPEL_MES3_BILHETE, 0) +
                                      nvl(intrPRODUCAO, 0);
            
              intrOBJ_MES3_BILHETE := nvl(intrOBJ_MES3_BILHETE, 0) +
                                      nvl(intrOBJETIVO, 0);
            
              intrPERC_MES3_BILHETE := (intrPEL_MES3_BILHETE /
                                       intrOBJ_MES3_BILHETE) * 100;
            
            End If;
          
          End If;
        
          If (DtDataApuracao_validacao <= C2.MES_APUR) then
          
            DtDataApuracao           := least(last_day(to_date(intrDtFIMVig || '01',
                                                               'YYYYMMDD')),
                                              C2.MES_APUR);
            DtDataApuracao_validacao := C2.MES_APUR;
          
          End If;
        
          --          intrCRRTR_ANTES := C.CCRRTR;
        
        END LOOP;
        Close Cursor2;
      
      END LOOP;
      Close Cursor1;
    
    End;
  
    intrPEL_MES1_AUTO := NVL(intrPEL_MES1_AUTO, 0);
    intrPEL_MES2_AUTO := NVL(intrPEL_MES2_AUTO, 0);
    intrPEL_MES3_AUTO := NVL(intrPEL_MES3_AUTO, 0);
  
    intrOBJ_MES1_AUTO := NVL(intrOBJ_MES1_AUTO, 0);
    intrOBJ_MES2_AUTO := NVL(intrOBJ_MES2_AUTO, 0);
    intrOBJ_MES3_AUTO := NVL(intrOBJ_MES3_AUTO, 0);
  
    intrPERC_MES1_AUTO := NVL(intrPERC_MES1_AUTO, 0);
    intrPERC_MES2_AUTO := NVL(intrPERC_MES2_AUTO, 0);
    intrPERC_MES3_AUTO := NVL(intrPERC_MES3_AUTO, 0);
  
    intrPEL_MES1_RE := NVL(intrPEL_MES1_RE, 0);
    intrPEL_MES2_RE := NVL(intrPEL_MES2_RE, 0);
    intrPEL_MES3_RE := NVL(intrPEL_MES3_RE, 0);
  
    intrOBJ_MES1_RE := NVL(intrOBJ_MES1_RE, 0);
    intrOBJ_MES2_RE := NVL(intrOBJ_MES2_RE, 0);
    intrOBJ_MES3_RE := NVL(intrOBJ_MES3_RE, 0);
  
    intrPERC_MES1_RE := NVL(intrPERC_MES1_RE, 0);
    intrPERC_MES2_RE := NVL(intrPERC_MES2_RE, 0);
    intrPERC_MES3_RE := NVL(intrPERC_MES3_RE, 0);
  
    intrPEL_MES1_BILHETE := NVL(intrPEL_MES1_BILHETE, 0);
    intrPEL_MES2_BILHETE := NVL(intrPEL_MES2_BILHETE, 0);
    intrPEL_MES3_BILHETE := NVL(intrPEL_MES3_BILHETE, 0);
  
    intrOBJ_MES1_BILHETE := NVL(intrOBJ_MES1_BILHETE, 0);
    intrOBJ_MES2_BILHETE := NVL(intrOBJ_MES2_BILHETE, 0);
    intrOBJ_MES3_BILHETE := NVL(intrOBJ_MES3_BILHETE, 0);
  
    intrPERC_MES1_BILHETE := NVL(intrPERC_MES1_BILHETE, 0);
    intrPERC_MES2_BILHETE := NVL(intrPERC_MES2_BILHETE, 0);
    intrPERC_MES3_BILHETE := NVL(intrPERC_MES3_BILHETE, 0);
  
    ---- Somatórios dos TRIMESTRES
    intrPEL_TRI_AUTO := nvl(intrPEL_MES1_AUTO, 0) +
                        nvl(intrPEL_MES2_AUTO, 0) +
                        nvl(intrPEL_MES3_AUTO, 0);
  
    intrPEL_TRI_RE := nvl(intrPEL_MES1_RE, 0) + nvl(intrPEL_MES2_RE, 0) +
                      nvl(intrPEL_MES3_RE, 0);
  
    intrPEL_TRI_BILHETE := nvl(intrPEL_MES1_BILHETE, 0) +
                           nvl(intrPEL_MES2_BILHETE, 0) +
                           nvl(intrPEL_MES3_BILHETE, 0);
  
    intrOBJ_TRI_AUTO := nvl(intrOBJ_MES1_AUTO, 0) +
                        nvl(intrOBJ_MES2_AUTO, 0) +
                        nvl(intrOBJ_MES3_AUTO, 0);
  
    intrOBJ_TRI_RE := nvl(intrOBJ_MES1_RE, 0) + nvl(intrOBJ_MES2_RE, 0) +
                      nvl(intrOBJ_MES3_RE, 0);
  
    intrOBJ_TRI_BILHETE := nvl(intrOBJ_MES1_BILHETE, 0) +
                           nvl(intrOBJ_MES2_BILHETE, 0) +
                           nvl(intrOBJ_MES3_BILHETE, 0);
  
    If nvl(intrOBJ_TRI_AUTO, 0) = 0 then
      intrPERC_TRI_AUTO := 0;
    Else
      intrPERC_TRI_AUTO := nvl(intrPEL_TRI_AUTO, 0) /
                           nvl(intrOBJ_TRI_AUTO, 0) * 100;
    End If;
  
    If nvl(intrOBJ_TRI_RE, 0) = 0 then
      intrPERC_TRI_RE := 0;
    Else
      intrPERC_TRI_RE := nvl(intrPEL_TRI_RE, 0) / nvl(intrOBJ_TRI_RE, 0) * 100;
    End If;
  
    If nvl(intrOBJ_TRI_BILHETE, 0) = 0 then
      intrPERC_TRI_BILHETE := 0;
    Else
      intrPERC_TRI_BILHETE := nvl(intrPEL_TRI_BILHETE, 0) /
                              nvl(intrOBJ_TRI_BILHETE, 0) * 100;
    End If;
  
  End;
BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  --
  --
  PR_ATUALIZA_STATUS_ROTINA_SGPB(chrNomeRotinaScheduler,
                                 708,
                                 PC_UTIL_01.Var_Rotna_Pc);
  --
  --
  geraDetail();
  --
  --
  PR_ATUALIZA_STATUS_ROTINA_SGPB(chrNomeRotinaScheduler,
                                 708,
                                 PC_UTIL_01.Var_Rotna_Po);
  --
  --
  chrLocalErro := '07';

  commit;

EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||
                           'CPF_CNPJ_BASE: ' || intrCPF_CNPJ_BASE ||
                           ' Compet: ' || to_char(intrDtINIVig) || '-' ||
                           to_char(intrDtFIMVig) || ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA_SGPB('SGPB0329',
                                var_log_erro,
                                pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);
    --
    PR_ATUALIZA_STATUS_ROTINA_SGPB(chrNomeRotinaScheduler,
                                   708,
                                   PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0329_20070125;
/

