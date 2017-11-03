CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0130
(
  intrCompetencia        Prod_Crrtr.CCOMPT_PROD %TYPE,
  chrNomeRotinaScheduler VARCHAR2 := 'SGPB0130'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0130
  --      DATA            : 13/12/2006
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : GERA O ARQUIVO PARA EXPORTAÇÃO DO SITE CORRETOR MENSAL
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  VAR_ARQUIVO      UTL_FILE.FILE_TYPE;
  intColArquivo    NUMBER(3) := 75;
  intColUtilizadas NUMBER(3) := 0;
  intQtdLinExp     NUMBER(8) := 0;
  --
  --
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00';
  --


----------------------------------------------------------------------------------------geraDetail
----------------------------------------------------------------------------------------
PROCEDURE armazenarArquivo (canal CANAL_VDA_SEGUR.CCANAL_VDA_SEGUR      %TYPE,
                            nome_canal CANAL_VDA_SEGUR.ICANAL_VDA_SEGUR %TYPE,
                            cpf_cnpj OBJTV_PROD_CRRTR.CCPF_CNPJ_BASE    %TYPE,
                            tipo_pessoa OBJTV_PROD_CRRTR.CTPO_PSSOA     %TYPE,
                            grupo_ramo OBJTV_PROD_CRRTR.CGRP_RAMO_PLANO %TYPE,
                            objetivo OBJTV_PROD_CRRTR.VOBJTV_PROD_CRRTR_ALT %TYPE,
                            margem MARGM_CONTB_CRRTR.PMARGM_CONTB       %TYPE)IS
BEGIN
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

      -- código do canal
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   lpad(canal,
                        1,
                        '0'));
      --
      --nome do canal
      intColUtilizadas := intColUtilizadas + 20;
      utl_file.put(var_arquivo,
                   rpad(nome_canal,
                        20,
                        ' '));
      --
      --CPF/CNPJ
      intColUtilizadas := intColUtilizadas + 14;
      utl_file.put(var_arquivo,
                   lpad(cpf_cnpj,
                        14,
                        ' '));
      --
      --tipo pessoa
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   lpad(tipo_pessoa,
                        1,
                        '0'));
      --
      --grupo ramo
      intColUtilizadas := intColUtilizadas + 3;
      utl_file.put(var_arquivo,
                   lpad(grupo_ramo,
                        3,
                        '0'));
      --
      --Objetivo
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,
                   lpad(trunc(objetivo),
                        15,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((objetivo - trunc(objetivo)) * 100),
                        2,
                        0)); --parte decimal

      --Margem de Contribuição
      intColUtilizadas := intColUtilizadas + 14;
      utl_file.put(var_arquivo,
                   lpad(trunc(margem),
                        10,
                        0)); --parte inteira
      utl_file.put(var_arquivo,
                   rpad(trunc((margem - trunc(margem)) * 100),
                        4,
                        0)); --parte decimal

      --
      --trailler
      utl_file.put(var_arquivo,
                   lpad(' ',
                        intColArquivo - intColUtilizadas));

END;

  ----------------------------------------------------------------------------------------geraHeader
  ----------------------------------------------------------------------------------------
  PROCEDURE geraHeader IS
  BEGIN
    --zera contador
    intColUtilizadas := 0;
    --tipo registro 0 header
    intColUtilizadas := intColUtilizadas + 1;
    utl_file.put(var_arquivo,
                 0);
    --datahora inicio da exportacao
    intColUtilizadas := intColUtilizadas + 14;
    utl_file.put(var_arquivo,
                 to_char(current_timestamp,
                         'YYYYMMDDHH24MISS'));
    --competencia da exportacao
    intColUtilizadas := intColUtilizadas + 8;
    utl_file.put(var_arquivo,
                 intrCompetencia || '01');
    --nome do programa que exportou
    intColUtilizadas := intColUtilizadas + 8;
    utl_file.put(var_arquivo,
                 'SGPB0130');
    --trailler
    utl_file.put(var_arquivo,
                 lpad(' ',
                      intColArquivo - intColUtilizadas));
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
    utl_file.put(var_arquivo,
                 9);
    --datahora fim da exportacao
    intColUtilizadas := intColUtilizadas + 14;
    utl_file.put(var_arquivo,
                 to_char(current_timestamp,
                         'YYYYMMDDHH24MISS'));
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

    FOR c IN (SELECT CVS.CCANAL_VDA_SEGUR AS canal,
                     CVS.ICANAL_VDA_SEGUR AS nome_canal,
                     OPC.CCPF_CNPJ_BASE   AS cpf_cnpj,
                     OPC.CTPO_PSSOA       AS tipo_pessoa,
                     OPC.CGRP_RAMO_PLANO  AS grupo_ramo,
                     OPC.VOBJTV_PROD_CRRTR_ALT  AS objetivo,
                     MCC.PMARGM_CONTB     AS margem

                FROM PARM_INFO_CAMPA PIC

                JOIN CRRTR_ELEIT_CAMPA CEC
                  ON PIC.CCANAL_VDA_SEGUR = CEC.CCANAL_VDA_SEGUR
                 AND PIC.DINIC_VGCIA_PARM = CEC.DINIC_VGCIA_PARM
                 AND CEC.CCANAL_VDA_SEGUR IN (pc_util_01.Banco, pc_util_01.Finasa) -- BANCO E FINASA


                JOIN CANAL_VDA_SEGUR CVS
                  ON CVS.CCANAL_VDA_SEGUR = PIC.CCANAL_VDA_SEGUR

                JOIN OBJTV_PROD_CRRTR OPC
                  ON OPC.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE
                 AND OPC.CTPO_PSSOA = CEC.CTPO_PSSOA
                 AND OPC.CCANAL_VDA_SEGUR = CEC.CCANAL_VDA_SEGUR
                 AND OPC.CIND_REG_ATIVO = 'S'
                 AND OPC.CANO_MES_COMPT_OBJTV = intrCompetencia

                JOIN MARGM_CONTB_CRRTR MCC
                  ON MCC.CCOMPT_MARGM = intrCompetencia
                 AND MCC.CCANAL_VDA_SEGUR =  CEC.CCANAL_VDA_SEGUR
                 AND MCC.CTPO_PSSOA = CEC.CTPO_PSSOA
                 AND MCC.CCPF_CNPJ_BASE = CEC.CCPF_CNPJ_BASE

               WHERE Last_Day(To_Date(Intrcompetencia,'YYYYMM')) 
               BETWEEN PIC.DINIC_VGCIA_PARM AND NVL(PIC.DFIM_VGCIA_PARM,TO_DATE('31/12/9999','dd/MM/yyyy'))
               ORDER BY canal, cpf_cnpj, tipo_pessoa, grupo_ramo

              ) LOOP

      --
      -- armazena em arquivo
      armazenarArquivo(c.canal, c.nome_canal, c.cpf_cnpj, c.tipo_pessoa, c.grupo_ramo, c.objetivo, c.margem);
      --
      --nova linha
      utl_file.new_line(var_arquivo);
      --
    --
    END LOOP;


      FOR c IN (SELECT CVS.CCANAL_VDA_SEGUR as canal,
                       CVS.ICANAL_VDA_SEGUR as nome_canal,
                       VPC.CCPF_CNPJ_BASE as cpf_cnpj,
                       VPC.CTPO_PSSOA as tipo_pessoa,
                       VPC.CGRP_RAMO_PLANO as grupo_ramo,
                       case
                            when VPC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto then
                                 (NVL(VPC.VPROD_CRRTR, 0) * (NVL(ccc.PCRSCT_PROD_ALT , PCVS.PCRSTC_PROD_ANO)/100+1) )
                            when VPC.CGRP_RAMO_PLANO = PC_UTIL_01.Re then
                                 PPMC.VMIN_PROD_CRRTR
                       end as objetivo,
                       MCC.PMARGM_CONTB as margem

                   FROM (
                        SELECT C.CCPF_CNPJ_BASE,
                               C.CTPO_PSSOA,
                               pc.CGRP_RAMO_PLANO,
                               PC.CCOMPT_PROD,
                               SUM(PC.VPROD_CRRTR) VPROD_CRRTR

                          FROM PROD_CRRTR PC
                          
                          JOIN CRRTR C
                            ON C.ccrrtr = pc.ccrrtr
                           AND C.cund_prod = pc.cund_prod
                           
                          JOIN PARM_CANAL_VDA_SEGUR PCVS
                            ON PCVS.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
                           AND Last_Day(To_Date( intrCompetencia, 'YYYYMM')) BETWEEN
                                     PCVS.DINIC_VGCIA_PARM AND
                                     Nvl(PCVS.DFIM_VGCIA_PARM,
                                     To_Date('99991231', 'YYYYMMDD'))

                          where PC.CTPO_COMIS = 'CN'
                            AND PC.CGRP_RAMO_PLANO = PC_UTIL_01.Auto
                            AND PC.CCRRTR BETWEEN PCVS.CINIC_FAIXA_CRRTR AND PCVS.CFNAL_FAIXA_CRRTR                            
                            AND PC.CCOMPT_PROD = PC_UTIL_01.Sgpb0017(intrCompetencia,12)
                            
                        GROUP
                           BY C.CCPF_CNPJ_BASE,
                              C.CTPO_PSSOA,
                              PC.CGRP_RAMO_PLANO,
                              PC.CCOMPT_PROD

                   ) VPC

              JOIN CANAL_VDA_SEGUR CVS
                ON CVS.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco

              JOIN parm_info_campa pic
                ON pic.Ccanal_Vda_Segur = CVS.CCANAL_VDA_SEGUR
               AND Last_Day(To_Date(Intrcompetencia,'YYYYMM'))
                         BETWEEN pic.dinic_vgcia_parm
                             AND Nvl(pic.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD'))

              JOIN MARGM_CONTB_CRRTR MCC
                ON MCC.CCOMPT_MARGM = intrCompetencia
               AND MCC.CCANAL_VDA_SEGUR = CVS.CCANAL_VDA_SEGUR
               AND MCC.CTPO_PSSOA = VPC.CTPO_PSSOA
               AND MCC.CCPF_CNPJ_BASE = VPC.CCPF_CNPJ_BASE

              LEFT JOIN CARAC_CRRTR_CANAL ccc
                ON ccc.CCANAL_VDA_SEGUR = CVS.CCANAL_VDA_SEGUR
               AND ccc.DINIC_VGCIA_PARM = pic.Dinic_Vgcia_Parm
               AND ccc.CCPF_CNPJ_BASE = VPC.CCPF_CNPJ_BASE
               AND ccc.CTPO_PSSOA = VPC.CTPO_PSSOA
               AND ccc.CIND_PERC_ATIVO = 'S'

              JOIN PARM_CANAL_VDA_SEGUR PCVS
                ON PCVS.CCANAL_VDA_SEGUR = CVS.CCANAL_VDA_SEGUR
               AND Last_Day(To_Date( MCC.CCOMPT_MARGM , 'YYYYMM')) BETWEEN
                         PCVS.DINIC_VGCIA_PARM AND
                         Nvl(PCVS.DFIM_VGCIA_PARM,
                         To_Date('99991231', 'YYYYMMDD'))

              JOIN PARM_PROD_MIN_CRRTR PPMC
                ON PPMC.CCANAL_VDA_SEGUR = PC_UTIL_01.Extra_Banco
               AND PPMC.CGRP_RAMO_PLANO = PC_UTIL_01.RE
               AND PPMC.CTPO_PSSOA = VPC.CTPO_PSSOA
               AND PPMC.CTPO_PER = 'M'
               AND Last_Day(To_Date( MCC.CCOMPT_MARGM , 'YYYYMM'))
                                     BETWEEN PPMC.DINIC_VGCIA_PARM
                                         AND NVL(PPMC.DFIM_VGCIA_PARM, TO_DATE('99991231', 'YYYYMMDD'))


              ) LOOP


      --
      -- armazena em arquivo
      armazenarArquivo(c.canal, c.nome_canal, c.cpf_cnpj, c.tipo_pessoa, c.grupo_ramo, c.objetivo, c.margem);
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
  BEGIN
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              708,
                              PC_UTIL_01.Var_Rotna_Po);
    --
    --
    chrLocalErro := '01';
    VAR_ARQUIVO  := UTL_FILE.FOPEN(pc_util_01.diretorio_padrao,
                                   'SGPB0130_' || TO_CHAR(SYSDATE,
                                                          'YYYYMMDD') || '.dat',
                                   'W');
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
    geraFooter();
    --
    --
    chrLocalErro := '05';
    utl_file.fflush(VAR_ARQUIVO);
    --
    chrLocalErro := '06';
    utl_file.fclose(VAR_ARQUIVO);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              708,
                              PC_UTIL_01.Var_Rotna_Pc);
    --
    --
    chrLocalErro := '07';
    COMMIT;
    --
    --
  EXCEPTION
    --
    WHEN Utl_File.Invalid_Path THEN
      Raise_Application_Error(-20210,
                              'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID PATH');
      -- the open_mode string was invalid
    WHEN Utl_File.Invalid_Mode THEN
      Raise_Application_Error(-20211,
                              'PROBLEMA NA ABERTURA ARQUIVO, ' || 'INVALID MODE');
      -- file could not be opened as requested
    WHEN Utl_File.Invalid_Operation THEN
      Raise_Application_Error(-20212,
                              'Invalid_Operation ' || SQLERRM);
      -- specified max_linesize is too large or too small
    WHEN Utl_File.Invalid_Maxlinesize THEN
      Raise_Application_Error(-20213,
                              'Invalid_Maxlinesize ' || SQLERRM);
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
    PR_GRAVA_MSG_LOG_CARGA('SGPB0130',
                           var_log_erro,
                           pc_util_01.VAR_LOG_PROCESSO,
                           NULL,
                           NULL);
    --
    --
    PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
                              708,
                              PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0130;
/

