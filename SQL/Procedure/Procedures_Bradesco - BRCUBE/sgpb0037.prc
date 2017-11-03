CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0037
(
  intrCompetencia        Prod_Crrtr.CCOMPT_PROD %TYPE,
  VAR_IDTRIO_TRAB        varchar2,
  VAR_IARQ_TRAB          varchar2,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0050'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0037
  --      DATA            : 10/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : GERA O ARQUIVO PARA O SISTEMA SCRR
  --      ALTERAÇÕES      :
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
  --
  --
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  --
  ----------------------------------------------------------------------------------------geraHeader
  ----------------------------------------------------------------------------------------
  PROCEDURE geraHeader IS
  BEGIN
    --zera contador
    intColUtilizadas := 0;
    --tipo registro 0 header
    intColUtilizadas := intColUtilizadas + 1;
    utl_file.put(var_arquivo,0);
    --datahora inicio da exportacao
    intColUtilizadas := intColUtilizadas + 14;
    utl_file.put(var_arquivo,to_char(current_timestamp,'YYYYMMDDHH24MISS'));
    --competencia da exportacao
    intColUtilizadas := intColUtilizadas + 8;
    --utl_file.put(var_arquivo,intrCompetencia || '01'); -- Nao pode ser essa data aqui, tem que ser a data de geracao.
    utl_file.put(var_arquivo,to_char(current_timestamp,'YYYYMMDD')); -- data correta, data de geracao.
    --nome do programa que exportou
    intColUtilizadas := intColUtilizadas + 8;
    utl_file.put(var_arquivo,'SGPB0050');
    --trailler
    utl_file.put(var_arquivo,lpad(' ',intColArquivo - intColUtilizadas));
    --nova linha
    utl_file.new_line(var_arquivo);
  END;

  ----------------------------------------------------------------------------------------geraFooter
  ----------------------------------------------------------------------------------------
  PROCEDURE geraFooter IS
  BEGIN
    --zera contador
    intColUtilizadas := 0;
    --tipo registro 0 footer
    intColUtilizadas := intColUtilizadas + 1;
    utl_file.put(var_arquivo,9);
    --datahora fim da exportacao
    intColUtilizadas := intColUtilizadas + 14;
    utl_file.put(var_arquivo,to_char(current_timestamp,'YYYYMMDDHH24MISS'));
    --Quantidade de registros exportados
    intColUtilizadas := intColUtilizadas + 8;
    utl_file.put(var_arquivo,
                 lpad(intQtdLinExp + 2,
                      8,
                      '0'));
    --trailler
    utl_file.put(var_arquivo,
                 lpad(' ',
                      intColArquivo - intColUtilizadas));
    --
    -- NÃO GERA NOVA LINHA
  END;

  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
    FOR c IN (SELECT PAP.CCANAL_VDA_SEGUR  AS canal,
                     pbc.ctpo_pgto         AS tipoBonus,
                     hdp.cund_prod         AS sucursal,
                     hdp.ccrrtr            AS cpd,
                     up.ccia_segdr         AS cia,
                     120                   AS ramo,
                     hdp.vdistr_pgto_crrtr AS valor
                FROM hist_distr_pgto hdp
                JOIN UND_PROD up ON up.cund_prod = hdp.cund_prod
                JOIN pgto_bonus_crrtr pbc ON pbc.cpgto_bonus = hdp.cpgto_bonus
                JOIN PAPEL_APURC_PGTO PAP
                  ON PAP.CPGTO_BONUS = hdp.cpgto_bonus
                 AND PAP.CINDCD_PAPEL = 0
               WHERE pbc.CIND_ARQ_EXPOR = 0
               AND PBC.CCOMPT_PGTO = intrCompetencia
               GROUP BY PAP.CCANAL_VDA_SEGUR,
                        pbc.ctpo_pgto,
                        hdp.cund_prod,
                        hdp.ccrrtr,
                        up.ccia_segdr,
                        120,
                        hdp.vdistr_pgto_crrtr
               ORDER BY PAP.CCANAL_VDA_SEGUR,
                        pbc.ctpo_pgto,
                        hdp.cund_prod,
                        hdp.ccrrtr --
              ) LOOP
      --
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --
      --zera contador
      intColUtilizadas := 0;
      --
      --tipo registro 1 detail
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   1);
      --
      --sucursal
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(c.sucursal,
                        3,
                        '0'));
      --
      --codigo CPD
      intColUtilizadas := intColUtilizadas + 6;
      utl_file.put(var_arquivo,
                   lpad(c.cpd,
                        6,
                        '0'));
      --
      --CIA
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(c.cia,
                        3,
                        '0'));
      --
      --Codigo Ramo
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   c.ramo);
      --
      --tipo Bonus
      intColUtilizadas := intColUtilizadas + 2;
      utl_file.put(var_arquivo,
                   lpad(c.tipoBonus,
                        2,
                        '0'));
      --
      --Canal de venda
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   c.canal);
      --
      --Valor Producao
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(c.valor),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((c.valor - trunc(c.valor)) * 100),
                        2,
                        0)); --parte decimal
      --
      --trailler
      utl_file.put(var_arquivo,
                   lpad(' ',
                        intColArquivo - intColUtilizadas));
      --
      --nova linha
      utl_file.new_line(var_arquivo);
      --
    --
    END LOOP;
  END;

  ----------------------------------------------------------------------------------------AtualizaPagamento
  ----------------------------------------------------------------------------------------
  PROCEDURE AtualizaPagamento IS
  BEGIN
    --
    --
    UPDATE pgto_bonus_crrtr pbc
       SET cind_arq_expor = 1
     WHERE pbc.CIND_ARQ_EXPOR = 0
       AND PBC.CCOMPT_PGTO = intrCompetencia;
    --
  END;

BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  BEGIN
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              849,
                              PC_UTIL_01.Var_Rotna_PC); -- alterado estava colocando PO , estava errado (wassily)
    commit;
    --
    --
    chrLocalErro := '01';
    VAR_ARQUIVO  := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB,'W');
    --
    chrLocalErro := '02';
    geraHeader();
    --
    --
    chrLocalErro := '03';
    geraDetail();
    --
    --
    chrLocalErro := '04';
    AtualizaPagamento();
    --
    --
    chrLocalErro := '05';
    geraFooter();
    --
    --
    chrLocalErro := '06';
    utl_file.fflush(VAR_ARQUIVO);
    --
    chrLocalErro := '07';
    utl_file.fclose(VAR_ARQUIVO);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              849,
                              PC_UTIL_01.Var_Rotna_Po); -- alterado pois estava errado, estava colocando pc. 17/05/2007
    --
    --
    chrLocalErro := '08';
    COMMIT;
    --
    --
  EXCEPTION
    --
    WHEN Utl_File.Invalid_Path THEN
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, '||' INVALID PATH',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0050',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0050',849,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
      -- the open_mode string was invalid
    WHEN Utl_File.Invalid_Mode THEN
      rollback;    --
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||' INVALID MODE',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0050',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0050',849,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
      -- file could not be opened as requested
    WHEN Utl_File.Invalid_Operation THEN
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||'Invalid_Operation. ERRO: '||SQLERRM,1,
                             PC_UTIL_01.VAR_TAM_MSG_ERRO);

      PR_GRAVA_MSG_LOG_CARGA('SGPB0050',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0050',849,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20212,var_log_erro);
      -- specified max_linesize is too large or too small
    WHEN Utl_File.Invalid_Maxlinesize THEN
      rollback;
      var_log_erro := substr('Invalid_Maxlinesize ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0050',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0050',
                              849,
                              PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20213,'Invalid_Maxlinesize ' || SQLERRM);
  END;

EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' || to_char(intrCompetencia) ||
                           ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    --    dbms_output.put_line(var_log_erro);
    PR_GRAVA_MSG_LOG_CARGA('SGPB0050',
                           var_log_erro,
                           pc_util_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              849,
                              PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20213,var_log_erro); --faltava o raise (wassily)
    --
END SGPB0037;
/

