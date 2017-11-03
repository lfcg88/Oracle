CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0268
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0268
  --      DATA            : 24/03/2008
  --      AUTOR           : VICTOR HUGO BILOURO - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : GERA O ARQUIVO DA PRODUC?O DOS CORRETORES ELEITOS - EXTRABANCO. (GRUPO ECONOMICO)
  --      ALTERAC?ES      : 
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_ARQUIVO      UTL_FILE.FILE_TYPE;
  intColArquivo    NUMBER(3) := 40;
  intColUtilizadas NUMBER(3) := 0;
  intQtdLinExp     NUMBER(8) := 0;
  VAR_CAMBTE       varchar2(100);
  VAR_LOG_ERRO     VARCHAR2(1000);
  chrLocalErro     vARCHAR2(2) := '00';
  VAR_DCARGA       date;
  VAR_DPROX_CARGA  date;
  VAR_IDTRIO_TRAB  varchar2(100);
  VAR_IARQ_TRAB    varchar2(100);
  VAR_ROTINA       VARCHAR2(08) := 'SGPB0268';
  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
    FOR c IN (SELECT cpae.Ccpf_Cnpj_Agpto_Econm_Crrtr,
                     cpae.CTPO_PSSOA_AGPTO_ECONM_CRRTR,
                     AEC.IAGPTO_ECONM_CRRTR,
                     cec.ccpf_cnpj_base,
                     cec.ctpo_pssoa,
                     cuc.iatual_crrtr,
                     cc.compt,
                     nvl(t.prod, 0) prod
                ---
                ---
                ---
                FROM crrtr_eleit_campa cec
                ---
                ---
                ---
                join parm_info_campa pic
                  on pic.ccanal_vda_segur = cec.ccanal_vda_segur
                 and pic.dinic_vgcia_parm = cec.dinic_vgcia_parm 
                ---
                ---
                ---
                join crrtr_unfca_cnpj cuc 
                  on cuc.ctpo_pssoa = cec.ctpo_pssoa
                 and cuc.ccpf_cnpj_base = cec.ccpf_cnpj_base
                ---
                ---
                ---
                        JOIN agpto_econm_crrtr aec
                          on last_day(to_date(200803, 'YYYYMM')) between aec.dinic_agpto_econm_crrtr and nvl(aec.dfim_vgcia_agpto_econm_crrtr, to_date(99991231, 'YYYYMMDD'))
                       
                        join crrtr_partc_agpto_econm cpae
                          on cpae.ctpo_pssoa_agpto_econm_crrtr = aec.ctpo_pssoa_agpto_econm_crrtr
                         and cpae.ccpf_cnpj_agpto_econm_crrtr = aec.ccpf_cnpj_agpto_econm_crrtr
                         and cpae.dinic_agpto_econm_crrtr = aec.dinic_agpto_econm_crrtr    
                         and last_day(to_date(200803, 'YYYYMM')) between cpae.dinic_vgcia_prtcp_agpto_econm and nvl(cpae.dfim_vgcia_prtcp_agpto_econm, to_date(99991231, 'YYYYMMDD'))
                         AND cpae.CCPF_CNPJ_BASE = cec.CCPF_CNPJ_BASE
                         AND cpae.CTPO_PSSOA = cec.CTPO_PSSOA                         
                ---
                ---
                ---
                join ( 
                         select TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA, 'YYYYMM')) - 2 compt from dual
                                union  
                         select TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA, 'YYYYMM')) - 1 compt from dual
                                union
                         select TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA, 'YYYYMM')) compt from dual
                     ) cc on 1 = 1                      
                ---
                ---
                ---
                left join (
                              select c.ccpf_cnpj_base,
                                     c.ctpo_pssoa,
                                     pc.ccompt_prod,
                                     sum(case
                                           when (pc.vprod_crrtr = 0) then
                                            0
                                           else
                                            pc.vprod_crrtr
                                         end) prod
                                ---
                                ---
                                from Crrtr c
                                ---
                                ---
                                join Prod_Crrtr pc ON pc.Ccrrtr = c.Ccrrtr
                                                  AND pc.Cund_Prod = c.Cund_Prod
                                                  AND pc.cgrp_ramo_plano = PC_UTIL_01.Auto
                                                  AND pc.ccompt_prod between TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA, 'YYYYMM')) - 2 and TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA, 'YYYYMM'))
                                                  and pc.ccrrtr between 100000 and 200000
                                                  AND pc.CTPO_COMIS = 'CN'
                                ---
                                ---
                               GROUP BY c.ccpf_cnpj_base,
                                        c.ctpo_pssoa,
                                        pc.ccompt_prod
                          ) t 
                ON t.ccpf_cnpj_base = cec.ccpf_cnpj_base
               AND t.ctpo_pssoa = cec.ctpo_pssoa
               AND t.ccompt_prod = cc.compt
                ---
                ---
                ---
               WHERE cec.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
                 AND last_day( VAR_DPROX_CARGA ) between pic.dinic_vgcia_parm and nvl(pic.dfim_vgcia_parm, to_date(99991231, 'YYYYMMDD'))
                ---
                ---
                ---
               ORDER BY cec.ccpf_cnpj_base,
                        cec.ctpo_pssoa,
                        cc.compt) LOOP
      --
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --
      --zera contador
      intColUtilizadas := 0;
      ---------------------------------------------------------------------------
      --CNPJ/CPF GRUPO ECONOMICO
      intColUtilizadas := intColUtilizadas + 9;
      utl_file.put(var_arquivo, lpad(c.Ccpf_Cnpj_Agpto_Econm_Crrtr, 9, '0'));
      --
      --tipo pessoa GRUPO ECONOMICO
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo, lpad(c.CTPO_PSSOA_AGPTO_ECONM_CRRTR, 1, '0'));
      --
      --nome do corretor GRUPO ECONOMICO
      intColUtilizadas := intColUtilizadas + 80;
      utl_file.put(var_arquivo, lpad(c.IAGPTO_ECONM_CRRTR, 80, ' '));
      ---------------------------------------------------------------------------

      --
      --CNPJ/CPF
      intColUtilizadas := intColUtilizadas + 9;
      utl_file.put(var_arquivo, lpad(c.ccpf_cnpj_base, 9, '0'));
      --
      --tipo pessoa
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo, lpad(c.ctpo_pssoa, 1, '0'));
      --
      --nome do corretor
      intColUtilizadas := intColUtilizadas + 80;
      utl_file.put(var_arquivo, lpad(c.iatual_crrtr, 80, ' '));
      --
      --Competencia
      intColUtilizadas := intColUtilizadas + 6;
      utl_file.put(var_arquivo, lpad(c.compt, 6, '0'));
      --
      --Sinal do valor
      intColUtilizadas := intColUtilizadas + 1;
      if (c.prod < 0) then
        utl_file.put(var_arquivo, '-'); --NEGATIVO
      else
        utl_file.put(var_arquivo, '+'); --POSITIVO
      end if;
    
      --
      --Valor Producao
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo, lpad(abs(trunc(c.prod)), 15, 0)); --parte inteira
      utl_file.put(var_arquivo, rpad(abs(trunc((c.prod - trunc(c.prod)) * 100)), 2, 0)); --parte decimal
      --
      --trailler
      utl_file.put(var_arquivo, lpad(' ', intColArquivo - intColUtilizadas));
      --
      --nova linha
      utl_file.new_line(var_arquivo);
      --
    --
    END LOOP;
  END;


BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------


    -- INICIO
    VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;
    -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
    PR_LE_PARAMETRO_CARGA(722, VAR_DCARGA, VAR_DPROX_CARGA);
    -- RECUPERA OS DADOS DE diretorio e arquivo
    PR_DIRETORIO_ARQUIVO(VAR_CAMBTE, 'SGPB', 'SGPB0268', 'W', 1, VAR_IDTRIO_TRAB, VAR_IARQ_TRAB);


    if VAR_IARQ_TRAB is null then
      VAR_IARQ_TRAB := 'SGPB0268';
    end if;


    -- Colocando a Competencia no Arquivo (trata se o arquivo esta vindo ou nao com o .dat, senao tive vai colocar)
    IF (UPPER(substr(VAR_IARQ_TRAB, -4, 4)) <> '.DAT') THEN
      VAR_IARQ_TRAB := VAR_IARQ_TRAB || '_' || to_char(VAR_DPROX_CARGA, 'YYYYMMDD') || '.dat';
    ELSE
      VAR_IARQ_TRAB := substr(VAR_IARQ_TRAB, 1, (LENGTH(VAR_IARQ_TRAB) - 4)) || '_' || to_char(VAR_DPROX_CARGA, 'YYYYMMDD') || '.dat';
    END IF;
    
    
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA, 'SERA GERADO O ARQUIVO ' || VAR_IARQ_TRAB || ' NO DIRETORIO ' || VAR_IDTRIO_TRAB, 'P', NULL, NULL);
    COMMIT;
    
    
    PR_LIMPA_LOG_CARGA('SGPB0268');
    var_log_erro := substr('INICIO DA GERACAO DO ARQUIVO PRODUCAO DOS CORRETORES ELEITOS! DIR: ' || VAR_IDTRIO_TRAB || ' VAR_IARQ_TRAB: ' ||
                           VAR_IARQ_TRAB, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    
    
    PR_GRAVA_MSG_LOG_CARGA('SGPB0268', var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    PR_ATUALIZA_STATUS_ROTINA('SGPB0268', 722, PC_UTIL_01.Var_Rotna_pc);
    commit;
    --
    chrLocalErro := '01';
    VAR_ARQUIVO  := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB, 'W');
    --
    chrLocalErro := '02';
    geraDetail();
    --
    chrLocalErro := '03';
    utl_file.fflush(VAR_ARQUIVO);
    --
    chrLocalErro := '04';
    utl_file.fclose(VAR_ARQUIVO);
    --
    PR_ATUALIZA_STATUS_ROTINA('SGPB0268', 722, PC_UTIL_01.Var_Rotna_po);
    --
    chrLocalErro := '05';
    --
    var_log_erro := substr('ROTINA EXECUTADA COM SUCESSO! IDTRIO_TRAB: ' || VAR_IDTRIO_TRAB || ' IARQ_TRAB: ' || VAR_IARQ_TRAB, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0268', var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    --
    COMMIT;
    --
  EXCEPTION
    --
    WHEN Utl_File.Invalid_Path THEN
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: ' || VAR_IDTRIO_TRAB || ' VAR_IARQ_TRAB: ' || VAR_IARQ_TRAB ||
                             '. INVALID PATH', 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0268', var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0268', 722, PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210, var_log_erro);
      -- the open_mode string was invalid
    WHEN Utl_File.Invalid_Mode THEN
      rollback; --
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: ' || VAR_IDTRIO_TRAB || ' VAR_IARQ_TRAB: ' || VAR_IARQ_TRAB ||
                             ' INVALID MODE', 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0268', var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0268', 722, PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210, var_log_erro);
      -- file could not be opened as requested
    WHEN Utl_File.Invalid_Operation THEN
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: ' || VAR_IDTRIO_TRAB || ' VAR_IARQ_TRAB: ' || VAR_IARQ_TRAB ||
                             'Invalid_Operation. ERRO: ' || SQLERRM, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
    
      PR_GRAVA_MSG_LOG_CARGA('SGPB0268', var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0268', 722, PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20212, var_log_erro);
      -- specified max_linesize is too large or too small
    WHEN Utl_File.Invalid_Maxlinesize THEN
      rollback;
      var_log_erro := substr('Invalid_Maxlinesize ' || SQLERRM, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0268', var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0268', 722, PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20213, 'Invalid_Maxlinesize ' || SQLERRM);

  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Canal: ' || to_char(PC_UTIL_01.Extra_Banco) || ' # ' || SQLERRM, 1, PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0268', var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    --
    PR_ATUALIZA_STATUS_ROTINA('SGPB0268', 722, PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20213, var_log_erro);
    --
END SGPB0268;
/

