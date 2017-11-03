CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0188
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0188
  --      DATA            : 26/06/2007
  --      AUTOR           : WASSILY CHUK SEIBLITZ GUANAES - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : GERA O ARQUIVO DA PRODUÇÃO AUTO DOS CORRETORES ELEITOS E NÃO ELEITOS - EXTRABANCO 
  --      ALTERAÇÕES      : OBS: AINDA NÃO FOI PARA A PRODUÇÃO. SE FOR TEM QUE IR COM A SGPB0530 (FIM DE FLUXO DELA)
  -------------------------------------------------------------------------------------------------
 IS
  VAR_ARQUIVO      	UTL_FILE.FILE_TYPE;
  intColArquivo    	NUMBER(3) := 40;
  intColUtilizadas 	NUMBER(3) := 0;
  intQtdLinExp     	NUMBER(8) := 0;
  VAR_CAMBTE       	varchar2(100);
  VAR_IDTRIO_TRAB  	varchar2(100);
  VAR_IARQ_TRAB    	varchar2(100); 
  VAR_LOG_ERRO 		VARCHAR2(1000);
  chrLocalErro 		VARCHAR2(2) := '00';
  COMP_1			NUMBER;
  COMP_2 			NUMBER;
  COMP_3			NUMBER;
  FAIXA_INICIO		NUMBER;
  FAIXA_FIM			NUMBER;
  VAR_DCARGA		DATE;
  VAR_DPROX_CARGA   DATE;
  CONTA_LINHAS		NUMBER := 0;
  VAR_ROTNA			CHAR(8) := 'SGPB0188';
  VAR_PARM			CHAR(3) := 854;
  ----------------------------------------------------------------------------------------geraDetail
  PROCEDURE geraDetail IS
  BEGIN
    FOR X IN ( -- PRIMEIRO PEGA TODOS OS CORRETORES ELEITOS, MESMO SEM PRODUCAO
               SELECT 'Eleitos' SITUACAO, cec.ccpf_cnpj_base, cec.ctpo_pssoa, cuc.iatual_crrtr, 
                      cc.compt, sum(nvl(t.prod, 0)) VALOR_PRODUCAO
                FROM crrtr_eleit_campa cec
                join crrtr_unfca_cnpj cuc
                on cuc.ctpo_pssoa = cec.ctpo_pssoa
                and cuc.ccpf_cnpj_base = cec.ccpf_cnpj_base
                join (select COMP_1 compt from dual union
                      select COMP_2 compt from dual union
                      select COMP_3 compt from dual) cc
                on 1=1
                left join (select c.ccpf_cnpj_base,c.ctpo_pssoa,pc.ccompt_prod,
                					sum(case
                							when (pc.vprod_crrtr = 0) then
									                0
							                else
									                pc.vprod_crrtr
							            end) prod
                					from Crrtr c
					                join Prod_Crrtr pc ON pc.Ccrrtr = c.Ccrrtr
					    	            AND pc.Cund_Prod = c.Cund_Prod
				   		     	        AND pc.cgrp_ramo_plano = Pc_Util_01.Auto
					            	    AND pc.ccompt_prod between COMP_3 and COMP_1
						                and pc.ccrrtr between FAIXA_INICIO and FAIXA_FIM
						                AND pc.CTPO_COMIS = 'CN'
						                GROUP BY c.ccpf_cnpj_base, c.ctpo_pssoa, pc.ccompt_prod) t
                ON t.ccpf_cnpj_base = cec.ccpf_cnpj_base
                AND t.ctpo_pssoa = cec.ctpo_pssoa
                AND t.ccompt_prod = cc.compt
                WHERE cec.CCANAL_VDA_SEGUR = Pc_Util_01.Extra_Banco
                group by 'Eleitos', cec.ccpf_cnpj_base, cec.ctpo_pssoa, cuc.iatual_crrtr, cc.compt
                -- DEPOIS PEGA TODOS OS CORRETORES NAO ELEITOS, MESMO SEM PRODUCAO
                UNION
                SELECT 'Nao Eleitos' SITUACAO, cuc.ccpf_cnpj_base, cuc.ctpo_pssoa, cuc.iatual_crrtr,
        				cc.Ccompt_Prod compt, sum(nvl(Pc.Vprod_Crrtr,0)) VALOR_PRODUCAO
						FROM Parm_Canal_Vda_Segur Pcvs
  						JOIN Crrtr c ON c.Ccrrtr BETWEEN Pcvs.Cinic_Faixa_Crrtr AND Pcvs.Cfnal_Faixa_Crrtr
  						JOIN Crrtr_Unfca_Cnpj Cuc ON Cuc.Ctpo_Pssoa = c.Ctpo_Pssoa
    	                      	AND Cuc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
    	   				join (select COMP_1 Ccompt_Prod from dual union
            				  select COMP_2 Ccompt_Prod from dual union
                              select COMP_3 Ccompt_Prod from dual) cc
                		on 1=1
  						left JOIN Prod_Crrtr Pc ON Pc.Ccrrtr = c.Ccrrtr
                    			AND Pc.Cund_Prod = c.Cund_Prod
                    			AND PC.CGRP_RAMO_PLANO IN Pc_Util_01.Auto
  						JOIN CANAL_VDA_SEGUR CVS ON CVS.CCANAL_VDA_SEGUR = PCVS.CCANAL_VDA_SEGUR
    					left join parm_info_campa pic on pic.ccanal_vda_segur = pcvs.ccanal_vda_segur
                               and to_date(200701, 'YYYYMM') between pic.dinic_vgcia_parm and
                               nvl(pic.dfim_vgcia_parm,to_date(99991231, 'YYYYMMDD'))
  						left join crrtr_eleit_campa cec on cec.ccpf_cnpj_base = cuc.ccpf_cnpj_base
                                 and cec.ctpo_pssoa = cuc.ctpo_pssoa
                                 AND CeC.CCANAL_VDA_SEGUR = Pcvs.ccanal_vda_segur
                                 and cec.dinic_vgcia_parm = pic.dinic_vgcia_parm
 						WHERE Pcvs.Ccanal_Vda_Segur = Pc_Util_01.Extra_Banco
   								AND Pc.Ccompt_Prod BETWEEN COMP_3 AND COMP_1
   								and cec.ccpf_cnpj_base is null
 						GROUP BY 'Nao Eleitos', cuc.ccpf_cnpj_base, cuc.ctpo_pssoa, cuc.iatual_crrtr, cc.Ccompt_Prod
 			) 
    LOOP
      -- CONTADOR DE LINHAS EXPORTADAS
      intQtdLinExp := intQtdLinExp + 1;
      --zera contador
      intColUtilizadas := 0;
      -- SITUACAO (ELEITO OU NAO ELEITO)
      intColUtilizadas := intColUtilizadas + 11;
      utl_file.put(var_arquivo,lpad(X.SITUACAO,11,' '));
      --CNPJ/CPF
      intColUtilizadas := intColUtilizadas + 9;
      utl_file.put(var_arquivo,lpad(X.ccpf_cnpj_base,9,'0'));
      --tipo pessoa
      intColUtilizadas := intColUtilizadas + 1;
      utl_file.put(var_arquivo,lpad(X.ctpo_pssoa,1,'0'));
      --nome do corretor
      intColUtilizadas := intColUtilizadas + 80;
      utl_file.put(var_arquivo,lpad(X.iatual_crrtr,80,' '));
      --Competência
      intColUtilizadas := intColUtilizadas + 6;
      utl_file.put(var_arquivo,lpad(X.compt,6,'0'));
      --Sinal do valor
      intColUtilizadas := intColUtilizadas + 1;                  
      if (X.valor_producao < 0) then
         utl_file.put(var_arquivo,'-');--NEGATIVO
      else
         utl_file.put(var_arquivo,'+');--POSITIVO
      end if;
      --Valor Producao      
      CONTA_LINHAS := CONTA_LINHAS + 1;
      intColUtilizadas := intColUtilizadas + 17;
      utl_file.put(var_arquivo,lpad(abs(trunc(X.valor_producao)),15,0)); --parte inteira
      utl_file.put(var_arquivo,rpad(abs(trunc((X.valor_producao - trunc(X.valor_producao)) * 100)),2,0)); --parte decimal
      --trailler
      utl_file.put(var_arquivo,lpad(' ',intColArquivo - intColUtilizadas));
      --nova linha
      utl_file.new_line(var_arquivo); 
    END LOOP;
  END;
BEGIN
  -------------------------------------------------------------------------------------------------
  --  CORPO DA PROCEDURE
  -------------------------------------------------------------------------------------------------
  BEGIN
    -- INICIO
    VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;  
    -- RECUPERA OS DADOS DE diretorio e arquivo
    PR_DIRETORIO_ARQUIVO( VAR_CAMBTE,'SGPB',VAR_ROTNA,'W',1,VAR_IDTRIO_TRAB,VAR_IARQ_TRAB );
    -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
    PR_LE_PARAMETRO_CARGA(VAR_PARM,VAR_DCARGA, VAR_DPROX_CARGA);
    -- GRAVA LOG INICIAL DE CARGA
    PR_LIMPA_LOG_CARGA(VAR_ROTNA);
    var_log_erro := substr('INICIO DA GERACAO DO ARQUIVO PRODUCAO DOS CORRETORES EXTRABANCO!',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA(VAR_ROTNA,VAR_PARM,PC_UTIL_01.Var_Rotna_pc); 
    commit;
    chrLocalErro := '01';
    if VAR_IARQ_TRAB is null then
      VAR_IARQ_TRAB := VAR_ROTNA;
    end if;
    -- Colocando a Competencia no Arquivo (trata se o arquivo está vindo ou nao com o .dat, senao tive vai colocar)
    IF ( UPPER(substr(VAR_IARQ_TRAB,-4,4)) <> '.DAT' ) THEN
    		VAR_IARQ_TRAB := VAR_IARQ_TRAB||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
    ELSE
   		VAR_IARQ_TRAB := substr(VAR_IARQ_TRAB,1,(LENGTH(VAR_IARQ_TRAB)-4))||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
    END IF;
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,'SERA GERADO O ARQUIVO '||VAR_IARQ_TRAB||' NO DIRETORIO '||VAR_IDTRIO_TRAB,'P',NULL,NULL);
    COMMIT;
    VAR_ARQUIVO  := UTL_FILE.FOPEN(VAR_IDTRIO_TRAB,VAR_IARQ_TRAB,'W');
    -- DESCOBRINDO PERIODO
    chrLocalErro := '02';
    COMP_1 := TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA,'YYYYMM'));
    COMP_2 := TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(VAR_DPROX_CARGA,'YYYYMM'),-1),'YYYYMM'));
    COMP_3 := TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(VAR_DPROX_CARGA,'YYYYMM'),-2),'YYYYMM'));
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,'SERA GERADO O PERIODO DA COMPETENCIA: '||COMP_1||' ATE A COMPETENCIA: '||COMP_3,'P',NULL,NULL);
    COMMIT;
    -- DESCOBRINDO A FAIXA
    pc_util_01.Sgpb0003(FAIXA_INICIO,FAIXA_FIM,PC_UTIL_01.Extra_Banco,VAR_DPROX_CARGA);
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,'SERA GERADO PARA A FAIXA DE : '||FAIXA_INICIO||' ATE '||FAIXA_FIM,'P',NULL,NULL);
    -- GERANDO ARQUIVO
    CONTA_LINHAS := 0;
    geraDetail();
    chrLocalErro := '03';
    utl_file.fflush(VAR_ARQUIVO);
    chrLocalErro := '04';
    utl_file.fclose(VAR_ARQUIVO);
    PR_ATUALIZA_STATUS_ROTINA(VAR_ROTNA,VAR_PARM,PC_UTIL_01.Var_Rotna_po);
    chrLocalErro := '05';
    var_log_erro := substr('ROTINA EXECUTADA COM SUCESSO! QTD DE LINHAS GERADAS: '||CONTA_LINHAS||
                           ' IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||' IARQ_TRAB: '||VAR_IARQ_TRAB,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    COMMIT;
  EXCEPTION
    WHEN Utl_File.Invalid_Path THEN      
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                             ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB||'. INVALID PATH',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTNA,VAR_PARM,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
      -- the open_mode string was invalid
    WHEN Utl_File.Invalid_Mode THEN     
      rollback;    --
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                              ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB||' INVALID MODE',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTNA,VAR_PARM,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
      -- file could not be opened as requested
    WHEN Utl_File.Invalid_Operation THEN
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||VAR_IDTRIO_TRAB||
                              ' VAR_IARQ_TRAB: '||VAR_IARQ_TRAB||'Invalid_Operation. ERRO: '||SQLERRM,1,
                             PC_UTIL_01.VAR_TAM_MSG_ERRO); 
      ROLLBACK;     
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTNA,VAR_PARM,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20212,var_log_erro);
      -- specified max_linesize is too large or too small
    WHEN Utl_File.Invalid_Maxlinesize THEN
      var_log_erro := substr('Invalid_Maxlinesize ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTNA,VAR_PARM,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20213,'Invalid_Maxlinesize ' || SQLERRM);
  END;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Canal: ' || to_char(PC_UTIL_01.Extra_Banco) ||
                           ' # ' || SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTNA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA(VAR_ROTNA,VAR_PARM,PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20213,var_log_erro);
END SGPB0188;
/

