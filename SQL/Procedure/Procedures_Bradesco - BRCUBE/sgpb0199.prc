CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0199
(
  VAR_IDTRIO_TRAB           varchar2,
  VAR_IARQ_TRAB             varchar2,
  VAR_COMPT                 OBJTV_PROD_CRRTR.CANO_MES_COMPT_OBJTV%type,
  Chrnomerotinascheduler VARCHAR2 := 'SGPB9199'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0199
  --      DATA            : 20/5/2007
  --      AUTOR           : VINÍCIUS FARIA
  --      OBJETIVO        : GERA O ARQUIVO PARA PAGAMENTO BANCO, eleitos apurados e nao apurados
  --                        Alterado para pegar a data como parametro, dessa forma poderá ser usado sempre.
  --                        A data passada é a ultima data do trimestre. Exemplo: 200703, 200706, 200709, 200712, 200803, 200806, ...                     
  --                        Ass. Wassily.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_ARQUIVO      UTL_FILE.FILE_TYPE;
  intColUtilizadas NUMBER(3) := 0;
  intQtdLinExp     NUMBER(8) := 0;
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  VAR_PRIMEIRO_MES OBJTV_PROD_CRRTR.CANO_MES_COMPT_OBJTV%type;
  VAR_SEGUNDO_MES OBJTV_PROD_CRRTR.CANO_MES_COMPT_OBJTV%type;
  PROCEDURE geraDetail IS
  BEGIN       
       FOR PB IN(       
                   SELECT AB.ccpf_cnpj_base,
                   AB.ctpo_pssoa,
                   AB.iatual_crrtr,
                   AB.PROD_AUTO,
                   AB.objetivo_trimestre_auto,
                   RE.PROD_RE,
                   RE.objetivo_trimestre_RE,
                   AB.PROD_BILHETE,
                   AB.pmargm_contb,
                   AB.pbonus_apurc,
                   AB.BONUS_TOTAL
              FROM (select cuc.ccpf_cnpj_base,
                   cuc.ctpo_pssoa,
                           cUc.iatual_crrtr,
                           SUM(CASE
                             WHEN pc.cgrp_ramo_plano = 120 THEN
                              pc.vprod_crrtr
                             ELSE
                              0
                           END) PROD_AUTO,
                           CASE 
                                WHEN (nvl(opc1.vobjtv_prod_crrtr_alt, 0) +
                                     nvl(opc2.vobjtv_prod_crrtr_alt, 0) +
                                     nvl(opc3.vobjtv_prod_crrtr_alt, 0) < PCVS.VMIN_PROD_APURC )THEN
                                  PCVS.VMIN_PROD_APURC
                                ELSE
                                  nvl(opc1.vobjtv_prod_crrtr_alt, 0) +
                                   nvl(opc2.vobjtv_prod_crrtr_alt, 0) +
                                   nvl(opc3.vobjtv_prod_crrtr_alt, 0)
                                END objetivo_trimestre_auto,
                           SUM(CASE
                                 WHEN pc.cgrp_ramo_plano = 810 THEN
                                  pc.vprod_crrtr
                                 ELSE
                                  0
                               END) PROD_BILHETE,
                           mcc.pmargm_contb, --Margem é so de março
                           apc.pbonus_apurc,
                           SUM(pc.vprod_crrtr * (NVL(apc.pbonus_apurc, 0) / 100)) BONUS_TOTAL
                    from crrtr c
                    join prod_crrtr pc on pc.ccrrtr = c.ccrrtr
                    and pc.cund_prod = c.cund_prod
                    and pc.ctpo_comis = 'CN'
                    and pc.ccompt_prod between VAR_PRIMEIRO_MES and VAR_COMPT
                    and pc.cgrp_ramo_plano IN (120,810)
                    join mpmto_ag_crrtr mac
                      on mac.cund_prod = pc.cund_prod
                     and mac.ccrrtr_dsmem = pc.ccrrtr
                     -- AND TO_DATE(20070331, 'YYYYMMDD') >= MAC.DENTRD_CRRTR_AG
                     AND last_day(to_date(VAR_COMPT||01, 'YYYYMMDD')) >= MAC.DENTRD_CRRTR_AG
                     --AND TO_DATE(20070101, 'YYYYMMDD') < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD')) 
                     AND to_date(VAR_PRIMEIRO_MES||01, 'YYYYMMDD') < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
                     and mac.ccrrtr_orign between 800000 and 870000
                    join parm_canal_vda_segur pcvs
                      on pcvs.ccanal_vda_segur in (2)
                     and pcvs.dfim_vgcia_parm is null
                      join crrtr_unfca_cnpj cuc on cuc.ccpf_cnpj_base = c.ccpf_cnpj_base
                                               and cuc.ctpo_pssoa = c.ctpo_pssoa
                    join crrtr_eleit_campa cec
                      on cec.ccpf_cnpj_base = c.ccpf_cnpj_base
                     and cec.ctpo_pssoa = c.ctpo_pssoa
                     and cec.ccanal_vda_segur = pcvs.ccanal_vda_segur
                     and cec.dinic_vgcia_parm = pcvs.dinic_vgcia_parm
                      left join apurc_prod_crrtr apc on apc.ccrrtr = pc.ccrrtr
                                               and apc.cund_prod = pc.cund_prod
                                               AND apc.cgrp_ramo_plano =
                                                   pc.cgrp_ramo_plano
                                               AND apc.ccompt_prod = pc.ccompt_prod
                                               AND apc.ctpo_comis = pc.ctpo_comis
                                               and apc.ccanal_vda_segur = pcvs.ccanal_vda_segur
                      left join margm_contb_crrtr mcc on mcc.ccpf_cnpj_base =
                                                         cuc.ccpf_cnpj_base
                                                     and mcc.ctpo_pssoa = cuc.ctpo_pssoa
                                                     and mcc.ccanal_vda_segur =
                                                         pcvs.ccanal_vda_segur
                                                     and mcc.ccompt_margm = VAR_COMPT
                      left join objtv_prod_crrtr opc1 on opc1.ccpf_cnpj_base =
                                                         cuc.ccpf_cnpj_base
                                                     and opc1.ctpo_pssoa =
                                                         cuc.ctpo_pssoa
                                                     and opc1.ccanal_vda_segur =
                                                         apc.ccanal_vda_segur
                                                     and opc1.cano_mes_compt_objtv =
                                                         VAR_PRIMEIRO_MES -- 200701
                                                     and opc1.cgrp_ramo_plano = 120
                                                     and opc1.cind_reg_ativo = 'S'
                      left join objtv_prod_crrtr opc2 on opc2.ccpf_cnpj_base =
                                                         cuc.ccpf_cnpj_base
                                                     and opc2.ctpo_pssoa =
                                                         cuc.ctpo_pssoa
                                                     and opc2.ccanal_vda_segur =
                                                         apc.ccanal_vda_segur
                                                     and opc2.cgrp_ramo_plano = 120
                                                     and opc2.cano_mes_compt_objtv =
                                                         VAR_SEGUNDO_MES --200702
                                                     and opc2.cind_reg_ativo = 'S'
                      left join objtv_prod_crrtr opc3 on opc3.ccpf_cnpj_base =
                                                         cuc.ccpf_cnpj_base
                                                     and opc3.ctpo_pssoa =
                                                         cuc.ctpo_pssoa
                                                     and opc3.ccanal_vda_segur =
                                                         apc.ccanal_vda_segur
                                                     and opc3.cgrp_ramo_plano = 120
                                                     and opc3.cano_mes_compt_objtv =
                                                         VAR_COMPT --200703
                                                     and opc3.cind_reg_ativo = 'S'
                     group by cUc.ccpf_cnpj_base,
                              cuc.ctpo_pssoa,
                              cUc.iatual_crrtr,
                              mcc.pmargm_contb,
                              apc.pbonus_apurc,
                              PCVS.VMIN_PROD_APURC,
                              opc1.vobjtv_prod_crrtr_alt,
                              opc2.vobjtv_prod_crrtr_alt,
                              opc3.vobjtv_prod_crrtr_alt) AB
            
              LEFT JOIN (
              select cUc.ccpf_cnpj_base,
                   cuc.ctpo_pssoa,
                   cUc.iatual_crrtr,
                   SUM(pc.vprod_crrtr) PROD_RE,
                   nvl(opcRE1.vobjtv_prod_crrtr_alt, 0) +
                   nvl(opcRE2.vobjtv_prod_crrtr_alt, 0) +
                   nvl(opcRE3.vobjtv_prod_crrtr_alt, 0) objetivo_trimestre_RE
              from crrtr c
              join prod_crrtr pc on pc.ccrrtr = c.ccrrtr
                                and pc.cund_prod = c.cund_prod
                                and pc.ctpo_comis = 'CN'
                                and pc.ccompt_prod between VAR_PRIMEIRO_MES AND VAR_COMPT --200701 and 200703
                                and pc.cgrp_ramo_plano = 999
            join mpmto_ag_crrtr mac
              on mac.cund_prod = pc.cund_prod
             and mac.ccrrtr_dsmem = pc.ccrrtr
             -- AND TO_DATE(20070331, 'YYYYMMDD') >= MAC.DENTRD_CRRTR_AG
             AND last_day(to_date(VAR_COMPT||01, 'YYYYMMDD')) >= MAC.DENTRD_CRRTR_AG
             --AND TO_DATE(20070101, 'YYYYMMDD') < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD')) 
             AND to_date(VAR_PRIMEIRO_MES||01, 'YYYYMMDD') < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))
             and mac.ccrrtr_orign between 800000 and 870000
            join parm_canal_vda_segur pcvs
              on pcvs.ccanal_vda_segur in (2)
             and pcvs.dfim_vgcia_parm is null
              join crrtr_unfca_cnpj cuc on cuc.ccpf_cnpj_base = c.ccpf_cnpj_base
                                       and cuc.ctpo_pssoa = c.ctpo_pssoa
            join crrtr_eleit_campa cec
              on cec.ccpf_cnpj_base = c.ccpf_cnpj_base
             and cec.ctpo_pssoa = c.ctpo_pssoa
             and cec.ccanal_vda_segur = pcvs.ccanal_vda_segur
             and cec.dinic_vgcia_parm = pcvs.dinic_vgcia_parm
            
              left join objtv_prod_crrtr opcRE1 on opcRE1.ccpf_cnpj_base =
                                                   cuc.ccpf_cnpj_base
                                               and opcRE1.ctpo_pssoa = cuc.ctpo_pssoa
                                               and opcRE1.ccanal_vda_segur =
                                                   pcvs.ccanal_vda_segur
                                               and opcRE1.cano_mes_compt_objtv = VAR_PRIMEIRO_MES --200701
                                               and opcRE1.cgrp_ramo_plano = 810
                                               and opcRE1.cind_reg_ativo = 'S'
              left join objtv_prod_crrtr opcRE2 on opcRE2.ccpf_cnpj_base =
                                                   cuc.ccpf_cnpj_base
                                               and opcRE2.ctpo_pssoa = cuc.ctpo_pssoa
                                               and opcRE2.ccanal_vda_segur =
                                                   pcvs.ccanal_vda_segur
                                               and opcRE2.cgrp_ramo_plano = 810
                                               and opcRE2.cano_mes_compt_objtv = VAR_SEGUNDO_MES --200702
                                               and opcRE2.cind_reg_ativo = 'S'
              left join objtv_prod_crrtr opcRE3 on opcRE3.ccpf_cnpj_base =
                                                   cuc.ccpf_cnpj_base
                                               and opcRE3.ctpo_pssoa = cuc.ctpo_pssoa
                                               and opcRE3.ccanal_vda_segur =
                                                   pcvs.ccanal_vda_segur
                                               and opcRE3.cgrp_ramo_plano = 810
                                               and opcRE3.cano_mes_compt_objtv = VAR_COMPT --200703
                                               and opcRE3.cind_reg_ativo = 'S'
             group by cUc.ccpf_cnpj_base,
                      cuc.ctpo_pssoa,
                      cUc.iatual_crrtr,
                      opcRE1.vobjtv_prod_crrtr_alt,
                      opcRE2.vobjtv_prod_crrtr_alt,
                      opcRE3.vobjtv_prod_crrtr_alt) RE
             ON  RE.ccpf_cnpj_base = AB.ccpf_cnpj_base
             AND RE.ctpo_pssoa = AB.ctpo_pssoa
       )LOOP
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --zera contador
      intColUtilizadas := 0;
      --CPF_CNPJ_BASE
      intColUtilizadas := intColUtilizadas + 9;
      utl_file.put(var_arquivo,PB.CCPF_CNPJ_BASE);
      --TIPO DE PESSOA
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,PB.CTPO_PSSOA);
      --NOME DO CORRETOR
      intColUtilizadas := intColUtilizadas + 80;
      utl_file.put(var_arquivo,RPAD(PB.IATUAL_CRRTR,80,' '));
      --PRODUÇÃO AUTO
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.PROD_AUTO),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((PB.PROD_AUTO - trunc(PB.PROD_AUTO)) * 100),
                        2,
                        0)); --parte decimal
      --OBJETIVO AUTO
      intColUtilizadas := intColUtilizadas + 15;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.OBJETIVO_TRIMESTRE_AUTO),
                        13,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((PB.OBJETIVO_TRIMESTRE_AUTO - trunc(PB.OBJETIVO_TRIMESTRE_AUTO)) * 100),
                        2,
                        0)); --parte decimal
      --PRODUÇÃO RE
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.PROD_RE),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((PB.PROD_RE - trunc(PB.PROD_RE)) * 100),
                        2,
                        0)); --parte decimal
      --OBJETIVO RE
      intColUtilizadas := intColUtilizadas + 15;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.OBJETIVO_TRIMESTRE_RE),
                        13,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((PB.OBJETIVO_TRIMESTRE_RE - trunc(PB.OBJETIVO_TRIMESTRE_RE)) * 100),
                        2,
                        0)); --parte decimal
      --PRODUÇÃO RE
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.PROD_BILHETE),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((PB.PROD_BILHETE - trunc(PB.PROD_BILHETE)) * 100),
                        2,
                        0)); --parte decimal
      --MARGEM DE CONTRIBUIÇÃO
      intColUtilizadas := intColUtilizadas + 14;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.PMARGM_CONTB),
                        12,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
             rpad(trunc((PB.PMARGM_CONTB - trunc(PB.PMARGM_CONTB)) * 100),
                  2,
                  0)); --parte decimal
      --PORCENTAGEM DE BÔNUS
      intColUtilizadas := intColUtilizadas + 14;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.PBONUS_APURC),
                        12,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
             rpad(trunc((PB.PBONUS_APURC - trunc(PB.PBONUS_APURC)) * 100),
                  2,
                  0)); --parte decimal
      --TOTAL DE BÔNUS
      intColUtilizadas := intColUtilizadas + 14;
      utl_file.put(var_arquivo,
                   lpad(trunc(PB.BONUS_TOTAL),
                        12,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
             rpad(trunc((PB.BONUS_TOTAL - trunc(PB.BONUS_TOTAL)) * 100),
                  2,
                  0)); --parte decimal 
      --nova linha
      utl_file.new_line(var_arquivo);
    END LOOP;
  END;
BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  BEGIN
    PR_ATUALIZA_STATUS_ROTINA_SGPB(Chrnomerotinascheduler,723,PC_UTIL_01.Var_Rotna_PC);
    COMMIT;
    -- Checando o trimestre passado. Ass. Wassily (23/05/2007)
    if substr(TO_CHAR(VAR_COMPT,'000009'),6,2) not in ('03','06','09','12') then
       ROLLBACK;
       PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,'ERRO. PARAMETRO COMPETENCIA INVALIDO: '||VAR_COMPT,'P',NULL,NULL);
       PR_ATUALIZA_STATUS_ROTINA_SGPB(Chrnomerotinascheduler,723,PC_UTIL_01.Var_Rotna_Pe);
       COMMIT;
       Raise_Application_Error(-20213,'ERRO. PARAMETRO COMPETENCIA INVALIDO: '||VAR_COMPT);
    END IF;
    VAR_PRIMEIRO_MES := TO_NUMBER(TO_CHAR(add_months(TO_DATE(VAR_COMPT,'YYYYMM'),-1),'YYYYMM')); --VAR_COMPT - 2;
    VAR_SEGUNDO_MES  := TO_NUMBER(TO_CHAR(add_months(TO_DATE(VAR_COMPT,'YYYYMM'),-2),'YYYYMM')); --VAR_COMPT - 1;    
    PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,'GERANDO ARQUIVO DE PRODUCAO DOS ELEITOS PARA A O PERIODO '||
    						VAR_PRIMEIRO_MES||', '||VAR_SEGUNDO_MES||', '||VAR_COMPT||'.' ,'P',NULL,NULL);
    COMMIT;
    chrLocalErro := '01';
    VAR_ARQUIVO  := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB,'W');
    chrLocalErro := '02';
    geraDetail();
    chrLocalErro := '03';
    utl_file.fflush(VAR_ARQUIVO);
    chrLocalErro := '04';
    utl_file.fclose(VAR_ARQUIVO);
    PR_ATUALIZA_STATUS_ROTINA_SGPB(Chrnomerotinascheduler,723,PC_UTIL_01.Var_Rotna_PO);
    PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,'QUANTIDADE DE LINHAS GERADAS: '||intQtdLinExp,'P',NULL,NULL);
    chrLocalErro := '05';
    COMMIT;
  EXCEPTION
    -- the open_mode string was invalid PATH
    WHEN Utl_File.Invalid_Path THEN
         PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,'PROBLEMA NA ABERTURA ARQUIVO, INVALID PATH. EM '||
      						TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
         Raise_Application_Error(-20210,'PROBLEMA NA ABERTURA ARQUIVO, INVALID PATH.');
    -- the open_mode string was invalid MODE
    WHEN Utl_File.Invalid_Mode THEN
         PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,'PROBLEMA NA ABERTURA ARQUIVO, INVALID MODE. EM '||
      						TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
         Raise_Application_Error(-20211,'PROBLEMA NA ABERTURA ARQUIVO, INVALID MODE');
      -- file could not be opened as requested
    WHEN Utl_File.Invalid_Operation THEN
         PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,'PROBLEMA NA ABERTURA ARQUIVO, Invalid_Operation. EM '||
      						TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
         Raise_Application_Error(-20212,'Invalid_Operation.' || SQLERRM);
      -- specified max_linesize is too large or too small
    WHEN Utl_File.Invalid_Maxlinesize THEN
         PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,'PROBLEMA NA ABERTURA ARQUIVO, Invalid_Maxlinesize. EM '||
      						TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
         Raise_Application_Error(-20213,'Invalid_Maxlinesize ' || SQLERRM);
  END;
EXCEPTION
  WHEN OTHERS THEN
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||' # ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA_SGPB(Chrnomerotinascheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA_SGPB(Chrnomerotinascheduler,723,PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    Raise_Application_Error(-20213,'Cod.Erro: ' || chrLocalErro ||' # ' || SQLERRM);
END SGPB0199;
/

