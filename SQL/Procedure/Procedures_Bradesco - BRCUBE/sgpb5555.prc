CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB5555
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB55555
  --      DATA            : XXXXXXXX
  --      AUTOR           : 
  --      OBJETIVO        : GERA O ARQUIVO DA PRODUÇÃO DOS CORRETORES ELEITOS - EXTRABANCO.
  --      ALTERAÇÕES      : O HARD CODE FOI ALTERADO PARA GERAR A PRODUCAO DO TERCEIRO TRIMESTRE. ASS. WASSILY (27/06/2007) 
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
  VAR_LOG_ERRO 	   VARCHAR2(1000);
  chrLocalErro 	   vARCHAR2(2) := '00';
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_IDTRIO_TRAB            	varchar2(100);
  VAR_IARQ_TRAB              	varchar2(100);
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB0168';
  VAR_COMPT                     number(6);
  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
    FOR c IN (select cec.ccanal_vda_segur, 
             cec.dinic_vgcia_parm, 
             cec.dcrrtr_selec_campa, 
             cec.ctpo_pssoa,
             cec.ccpf_cnpj_base 
        from crrtr_eleit_campa cec 
       where cec.ccanal_vda_segur = 1  
         and cec.ctpo_pssoa = 'J'
         and cec.dinic_vgcia_parm = to_date('01102007','ddmmyy')
         and rownum < 10
             ) LOOP
      --
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --
      --zera contador
      intColUtilizadas := 0;
      --
      --CNPJ/CPF
      intColUtilizadas := intColUtilizadas + 9;
      utl_file.put(var_arquivo,
                   lpad(c.ccpf_cnpj_base,
                        9,
                        '0'));
      --
      --tipo pessoa
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,
                   lpad(c.ctpo_pssoa,
                        1,
                        '0'));
      --
      --nome do corretor
      intColUtilizadas := intColUtilizadas + 80;
      utl_file.put(var_arquivo,
                   lpad(c.ccanal_vda_segur,
                        80,
                        ' '));

      --
      --Competência
      intColUtilizadas := intColUtilizadas + 6;
      utl_file.put(var_arquivo,
                   lpad(c.dinic_vgcia_parm,
                        6,
                        '0'));
      --
      --Sinal do valor
      intColUtilizadas := intColUtilizadas + 1;                  
         utl_file.put(var_arquivo,'-');--NEGATIVO
      
      --
      --Valor Producao
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,c.dcrrtr_selec_campa);
      
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


BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  BEGIN
   -- INICIO
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;    
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(722,VAR_DCARGA, VAR_DPROX_CARGA); 
   -- RECUPERA OS DADOS DE diretorio e arquivo
   PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,'SGPB','SGPB0168','W',1,VAR_IDTRIO_TRAB,VAR_IARQ_TRAB);
   if VAR_IARQ_TRAB is null then
   		VAR_IARQ_TRAB := 'SGPB0168';
   end if;
   -- Colocando a Competencia no Arquivo (trata se o arquivo está vindo ou nao com o .dat, senao tive vai colocar)
   IF ( UPPER(substr(VAR_IARQ_TRAB,-4,4)) <> '.DAT' ) THEN
   		VAR_IARQ_TRAB := VAR_IARQ_TRAB||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   ELSE
   		VAR_IARQ_TRAB := substr(VAR_IARQ_TRAB,1,(LENGTH(VAR_IARQ_TRAB)-4))||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   END IF;
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'SERA GERADO O ARQUIVO '||VAR_IARQ_TRAB||' NO DIRETORIO '||VAR_IDTRIO_TRAB,'P',NULL,NULL);
   COMMIT;
    PR_LIMPA_LOG_CARGA('SGPB0168');
    var_log_erro := substr('INICIO DA GERACAO DO ARQUIVO PRODUCAO DOS CORRETORES ELEITOS! DIR: '||VAR_IDTRIO_TRAB||
                           ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0168',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA('SGPB0168',722,PC_UTIL_01.Var_Rotna_pc); 
    commit;
    --
    chrLocalErro := '01';
    VAR_ARQUIVO  := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB,VAR_IARQ_TRAB,'W');
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
    PR_ATUALIZA_STATUS_ROTINA('SGPB0168',722,PC_UTIL_01.Var_Rotna_po);
    --
    chrLocalErro := '05';
    --
    var_log_erro := substr('ROTINA EXECUTADA COM SUCESSO! IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||' IARQ_TRAB: '||VAR_IARQ_TRAB,1,
                    PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0168',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    --
    COMMIT;
    --
  EXCEPTION
    --
    WHEN Utl_File.Invalid_Path THEN      
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                             ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB||'. INVALID PATH',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0168',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0168',722,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
      -- the open_mode string was invalid
    WHEN Utl_File.Invalid_Mode THEN     
      rollback;    --
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                              ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB||' INVALID MODE',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0168',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0168',722,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
      -- file could not be opened as requested
    WHEN Utl_File.Invalid_Operation THEN     
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                              ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB||'Invalid_Operation. ERRO: '||SQLERRM,1,
                             PC_UTIL_01.VAR_TAM_MSG_ERRO);
      
      PR_GRAVA_MSG_LOG_CARGA('SGPB0168',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0168',722,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20212,var_log_erro);
      -- specified max_linesize is too large or too small
    WHEN Utl_File.Invalid_Maxlinesize THEN     
      rollback;
      var_log_erro := substr('Invalid_Maxlinesize ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      --
      PR_GRAVA_MSG_LOG_CARGA('SGPB0168',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      --
      PR_ATUALIZA_STATUS_ROTINA('SGPB0168',722,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20213,'Invalid_Maxlinesize ' || SQLERRM);
  END;
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Canal: ' || to_char(PC_UTIL_01.Extra_Banco) ||
                           ' # ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0168',var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    --
    PR_ATUALIZA_STATUS_ROTINA('SGPB0168',722,PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20213,var_log_erro);
    --
END SGPB5555;
/

