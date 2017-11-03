CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0230 IS
  -----------------------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0230
  --      DATA            : 08/04/2008
  --      AUTOR           : Wassily Chuk Seiblitz Guanaes
  --      OBJETIVO        : CONTABILIZAÇÃO/PROVISÃO E ESTORNO CONTABIL
  --                        ESSA ROTINA TEM QUE RODAR SEMPRE NO ULTIMO DIA UTIL DO MES E SEMPRE DEPOIS DO PAGAMENTO
  --                       Descrição:
  --
  --                       Vê se tem Pagamento para o período de Competencia,
  --                          Se tiver pagamento,
  --                             Faz o lancamento Contábil do Pagamento
  --                                 Vê se tem Provisão de período anterior até o período do pagamento para Estornar
  --                                    Se tiver provisão,
  --                                       Vai estornar a provisão realizando outro lançamento (lançamento de estorno)
  --                       Sempre faz provisão para o período (mês) que está sendo executado.
  --
  -- Atenção: Para o Estorno é utilizado o campo CIND_ARQ_EXPOR para identificar as Provisões realizadas. Para mais detalhes
  --          vá ao módulo de estorno (nesse programa).
  --          CIND_ARQ_EXPOR = 0 -> Lancamento nao enviado para contabilidade (não vai estornar)
  --          CIND_ARQ_EXPOR = 1 -> Lancamento enviado para contabilidade (se for provisão vai gerar um registro de estorno)
  --          CIND_ARQ_EXPOR = 2 -> Lancamento de provisao enviado para contabilidade e já estornado anteriormente
  -- -------------------------------------------------------------------------------------------------------------
  VAR_DCARGA                 	date;
  VAR_DPROX_CARGA            	date;
  VAR_ROTINA                    VARCHAR2(08) := 'SGPB0230';
  VAR_PARAMETRO                 NUMBER       := 850;
  VAR_COMPT                     number(6);
  VAR_LOG_ERRO					VARCHAR2(200);
  VAR_PONTO						VARCHAR2(3);
  VAR_PAGTO_REALIZADO			NUMBER := 0;
  VAR_PAGTO_CONTABILIZADO		NUMBER := 0;
  VAR_CONTA_REG					NUMBER := 0;
  VAR_CONTA_INSERT				NUMBER := 0;
  VAR_TOTAL_INSERT				NUMBER := 0;
  VAR_FAIXA_INICIO				NUMBER;
  VAR_FAIXA_FIM					NUMBER;
  VAR_TEVE_PAGTO				BOOLEAN := FALSE;
  VAR_TEVE_ESTORNO				BOOLEAN := FALSE;
  VAR_TEVE_PROVISAO				BOOLEAN := FALSE;
  -- PARAMETROS DE PROVISIONAMENTO
  VAR_RAMO_AUTO                 NUMBER   := 120;
  VAR_TIPO_COMISSAO             CHAR(02) := 'CN';
  VAR_MARGEM                    NUMBER   := 27;
  VAR_PROD_MINIMA_EXTRABANCO    NUMBER   := 100000;
  VAR_PROD_MINIMA_BANCO         NUMBER   := 90000;
  VAR_PROD_MINIMA_FINASA        NUMBER   := 90000;
  VAR_ULT_MES_PAGTO_APURC       NUMBER   := 0;
  -- Contas de Pagamento
  VAR_CTA_PAGTO_CREDORA         VARCHAR2(20) := '1113100000000';
  VAR_CTA_PAGTO_DEBITO_BANCO    VARCHAR2(20) := '2128800010000';
  VAR_CTA_PAGTO_DEBITO_EXTRA    VARCHAR2(20) := '2128800020000';
  VAR_CTA_PAGTO_DEBITO_FINASA   VARCHAR2(20) := '2128800030000';
  -- Contas de Provisionamento
  VAR_CTA_PROV_DEVEDORA_BANCO   VARCHAR2(20) := '3143800010000';
  VAR_CTA_PROV_DEVEDORA_EXTRA   VARCHAR2(20) := '3143800020000';
  VAR_CTA_PROV_DEVEDORA_FINASA  VARCHAR2(20) := '3143800030000';
  VAR_CTA_PROV_CREDORA_BANCO    VARCHAR2(20) := '2128800010000';
  VAR_CTA_PROV_CREDORA_EXTRA    VARCHAR2(20) := '2128800020000';
  VAR_CTA_PROV_CREDORA_FINASA   VARCHAR2(20) := '2128800030000';
  -- Contas de Estorno
  VAR_CTA_ESTOR_DEVEDORA_BANCO  VARCHAR2(20) := '2128800010000';
  VAR_CTA_ESTOR_DEVEDORA_EXTRA  VARCHAR2(20) := '2128800020000';
  VAR_CTA_ESTOR_DEVEDORA_FINASA VARCHAR2(20) := '2128800030000';
  VAR_CTA_ESTOR_CREDORA_BANCO   VARCHAR2(20) := '3143800010000';
  VAR_CTA_ESTOR_CREDORA_EXTRA   VARCHAR2(20) := '3143800020000';
  VAR_CTA_ESTOR_CREDORA_FINASA  VARCHAR2(20) := '3143800030000';
BEGIN
   VAR_PONTO := '10';
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   PR_LE_PARAMETRO_CARGA(VAR_PARAMETRO,VAR_DCARGA,VAR_DPROX_CARGA);
   VAR_COMPT := to_number(to_char(VAR_DPROX_CARGA,'YYYYMM'));
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIANDO A CONTABILIZACAO DA COMPETENCIA: '||VAR_COMPT,'P',NULL,NULL);
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PC);
   COMMIT;
   VAR_PONTO := '15';
   --
   -- Checando se já houve a executação da contabilização.
   -- Se houve vai parar por que houve algum problema.
   --
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'VERIFICANDO SE O PERIODO JA ESTÁ FECHADO.','P',NULL,NULL);
   COMMIT;
   VAR_CONTA_REG := 0;
   SELECT NVL(COUNT(*),0) INTO VAR_CONTA_REG
          FROM HIST_CTBIL
          WHERE CIND_ARQ_EXPOR <> 0 AND
                CCOMPT_MOVTO_CTBIL = VAR_COMPT;
   VAR_PONTO := '16';
   IF VAR_CONTA_REG <> 0 THEN
      VAR_LOG_ERRO := 'ERRO. PERIODO JÁ FECHADO PARA PROCESSAMENTO.';
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,VAR_LOG_ERRO,'P',NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
      COMMIT;
      Raise_Application_Error(-20210,VAR_LOG_ERRO);
   END IF;
   VAR_PONTO := '20';
   --
   -- Deletando qualquer movimento que pertence a data de competencia mas não foi fechado, ou seja, não foi exportado.
   --
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. PERIODO NAO FECHADO, DELETANDO POSSIVEL PROCESSAMENTO ANTERIOR.','P',NULL,NULL);
   COMMIT;
   BEGIN
       DELETE FROM HIST_CTBIL
   		      WHERE CCOMPT_MOVTO_CTBIL = VAR_COMPT and
   		            CIND_ARQ_EXPOR = 0;
       VAR_PONTO := '21';
       IF SQL%ROWCOUNT > 0 THEN
          PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. DELETADOS '||SQL%ROWCOUNT||' REGISTROS.','P',NULL,NULL);
       ELSE
          PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HOUVERAM REGISTROS PARA DELECAO','P',NULL,NULL);
       END IF;
   EXCEPTION
   	   WHEN NO_DATA_FOUND THEN
            PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HOUVERAM REGISTROS PARA DELECAO','P',NULL,NULL);
   END;
   COMMIT;
   VAR_PONTO := '22';
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'VERIFICANDO SE TEM PAGTO PENDENTE PARA O PERIODO.','P',NULL,NULL);
   COMMIT;
   VAR_PONTO := '25';
   --
   -- Verificando se Existe Pagamento realizado para o periodo mas sem ter sido gerado o arquivo Financeiro.
   -- NOTA: Se encontrar realizacao de pagamento com FLAG EXPORTACAO igual a ZERO vai parar por que ainda não foi gerado
   --       o Arquivo Financeiro de pagamentos.
   --
   VAR_PAGTO_REALIZADO := 0;
   BEGIN
      FOR I IN (select 1 REG
       	            from PGTO_BONUS_CRRTR pbc, HIST_DISTR_PGTO HDP, PAPEL_APURC_PGTO PAP
		            WHERE pbc.CPGTO_BONUS = hdp.CPGTO_BONUS and
		                  pbc.CPGTO_BONUS = pap.CPGTO_BONUS and
		                  pbc.CIND_ARQ_EXPOR = 0 AND  -- pagamentos Pendentes, se encontrar vai parar.
		                                              --
		                  pbc.CCOMPT_PGTO = VAR_COMPT -- Vale para qualquer mês, ou seja, qualquer pagto pendente
		                                              -- Tem que alterar depois e colocar um indicador que já foi contabilizado.
		                                              --
		                  group by pbc.CCPF_CNPJ_BASE, pbc.CTPO_PSSOA, HDP.CUND_PROD, hdp.CCRRTR, VAR_RAMO_AUTO,
    			                   HDP.VDISTR_PGTO_CRRTR )
      LOOP
   		 VAR_PAGTO_REALIZADO := VAR_PAGTO_REALIZADO + 1;
      END LOOP;
   END;
   IF VAR_PAGTO_REALIZADO <> 0 -- Atenção: Erro, o Programa não pode continuar por que tem pagamento pendente.
   THEN
      VAR_PONTO := '30';
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ENCONTRADOS '||VAR_PAGTO_REALIZADO||' PAGTOS NAO EXPORTADOS PARA O FINANCEIRO.','P',NULL,NULL);
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. O PROGRAMA DE CONTABILIZACAO NÃO IRA CONTINUAR.','P',NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
      Raise_Application_Error(-20210,'. ENCONTRADOS '||VAR_PAGTO_REALIZADO||' PAGTOS NAO EXPORTADOS PARA O FINANCEIRO.');
      COMMIT;
   ELSE
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO FORAM ENCONTRADOS PAGAMENTOS PENDENTES.','P',NULL,NULL);
   END IF;
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'VERIFICANDO SE TEM PAGTO REALIZADO.','P',NULL,NULL);
   COMMIT;
   -- Procurando pgto para a competencia processada.
   --
   VAR_PAGTO_REALIZADO := 0;
   BEGIN
      FOR I IN (select 1 REG
       	            from PGTO_BONUS_CRRTR pbc, HIST_DISTR_PGTO HDP, PAPEL_APURC_PGTO PAP
		            WHERE pbc.CPGTO_BONUS = hdp.CPGTO_BONUS and
		                  pbc.CPGTO_BONUS = pap.CPGTO_BONUS and
		                  pbc.CIND_ARQ_EXPOR <> 0 AND -- Se encontrou eh por que foi gerado arquivo de pagamentos
		                                              --
		                  pbc.CCOMPT_PGTO = VAR_COMPT -- Vale para qualquer mês, ou seja, qualquer pagto pendente
		                                              -- Tem que alterar depois e colocar um indicador que já foi contabilizado.
		                                              --
		                  group by pbc.CCPF_CNPJ_BASE, pbc.CTPO_PSSOA, HDP.CUND_PROD, hdp.CCRRTR, VAR_RAMO_AUTO,
    			                   HDP.VDISTR_PGTO_CRRTR )
      LOOP
   		 VAR_PAGTO_REALIZADO := VAR_PAGTO_REALIZADO + 1;
      END LOOP;
   END;
   VAR_PONTO := '30';
   IF VAR_PAGTO_REALIZADO <> 0 -- Encontrou pagamento realizado para o pagamento
   THEN
      VAR_PONTO := '40';
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ENCONTRADOS '||VAR_PAGTO_REALIZADO||' PAGAMENTOS DE BONUS.','P',NULL,NULL);
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. REALIZANDO CONTABILIZACAO DO PAGAMENTO.','P',NULL,NULL);
      COMMIT;
      --
      -- pegando proximo registro a ser inserido em hist_ctbil.
      --
      VAR_PONTO := '45';
      VAR_CONTA_REG := 0;
      BEGIN
          SELECT NVL(MAX(CPGTO_BONUS),0) INTO VAR_CONTA_REG FROM HIST_CTBIL;
      EXCEPTION
          WHEN NO_DATA_FOUND
               THEN VAR_CONTA_REG := 1;
      END;
      VAR_PONTO := '47';
      VAR_CONTA_INSERT := 0;
      VAR_PAGTO_CONTABILIZADO := 0;
      --
      -- Inserindo Pagamento na tabela de historico contabil
      --
      for i in (select pbc.CCPF_CNPJ_BASE CCPF_CNPJ_BASE, pbc.CTPO_PSSOA CTPO_PSSOA, HDP.CUND_PROD CUND_PROD,
                       hdp.CCRRTR, VAR_RAMO_AUTO CRAMO, pbc.CCOMPT_PGTO,
       				   case    when Pap.CCANAL_VDA_SEGUR = 1 then
           		 		            VAR_CTA_PAGTO_DEBITO_EXTRA
           					   when Pap.CCANAL_VDA_SEGUR = 2 then
           		 					VAR_CTA_PAGTO_DEBITO_BANCO
           					   when Pap.CCANAL_VDA_SEGUR = 3 then
           		 					VAR_CTA_PAGTO_DEBITO_FINASA
    				   end CTA_DEVEDORA, VAR_CTA_PAGTO_CREDORA CTA_CREDORA, HDP.VDISTR_PGTO_CRRTR VL_PAGTO,
    				   max(PAP.CCOMPT_PROD) CCOMPT_PROD
       				   from PGTO_BONUS_CRRTR pbc, HIST_DISTR_PGTO HDP, PAPEL_APURC_PGTO PAP
					   WHERE pbc.CPGTO_BONUS = hdp.CPGTO_BONUS and
					         pbc.CPGTO_BONUS = pap.CPGTO_BONUS and
					         pbc.CIND_ARQ_EXPOR <> 0 AND
					         pbc.CCOMPT_PGTO = VAR_COMPT
						     group by pbc.CCPF_CNPJ_BASE, pbc.CTPO_PSSOA,
						              HDP.CUND_PROD, hdp.CCRRTR, VAR_RAMO_AUTO, CCOMPT_PGTO,
       				                  case    when Pap.CCANAL_VDA_SEGUR = 1 then
           		 		                           VAR_CTA_PAGTO_DEBITO_EXTRA
           					                  when Pap.CCANAL_VDA_SEGUR = 2 then
           		 					               VAR_CTA_PAGTO_DEBITO_BANCO
           					                  when Pap.CCANAL_VDA_SEGUR = 3 then
           		 					               VAR_CTA_PAGTO_DEBITO_FINASA
    				                  end, VAR_CTA_PAGTO_CREDORA, HDP.VDISTR_PGTO_CRRTR)
      LOOP
          VAR_CONTA_REG := VAR_CONTA_REG + 1;
          VAR_CONTA_INSERT := VAR_CONTA_INSERT + 1;
          VAR_PAGTO_CONTABILIZADO := VAR_PAGTO_CONTABILIZADO + 1;
          VAR_PONTO := '48';
          --
          -- inserindo pagamento
          --
          INSERT INTO HIST_CTBIL ( CCOMPT_MOVTO_CTBIL, CCOMPT_PROD, CCOMPT_PGTO, CPGTO_BONUS,
                                   CTPO_PSSOA, CCPF_CNPJ_BASE, CCRRTR, CUND_PROD, CRAMO,
                                   CCTA_CTBIL_CREDR, CCTA_CTBIL_DVDOR, VPGTO_TOT, CIND_ARQ_EXPOR, RHIST_CTBIL,
                                   DEXPOR_CTBIL, DINCL_REG, DULT_ALT)
          			VALUES		 ( VAR_COMPT, I.CCOMPT_PROD, I.CCOMPT_PGTO, VAR_CONTA_REG,
          			               I.CTPO_PSSOA, I.CCPF_CNPJ_BASE, I.CCRRTR, I.CUND_PROD, I.CRAMO,
          			               I.CTA_CREDORA, I.CTA_DEVEDORA, I.VL_PAGTO, 0, 'PAGAMENTO', NULL, SYSDATE, NULL);
      end loop;
      VAR_PONTO := '50';
      IF VAR_CONTA_INSERT <> 0 THEN
         VAR_TEVE_PAGTO := TRUE;
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. INSERIDOS '||VAR_CONTA_INSERT||' LANCAMENTOS DE PAGAMENTOS','P',NULL,NULL);
      ELSE
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HOUVERAM REGISTROS INSERIDOS DE PAGAMENTO','P',NULL,NULL);
      END IF;
   ELSE
      VAR_PONTO := '70';
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HA PAGTOS PARA O PERIODO.','P',NULL,NULL);
      COMMIT;
   END IF;
   VAR_PONTO := '75';
   --
   -- Primeiro vai descobrir os CNPJ/CPF com possibilidade de receberem BONUS, depois vai pegar o codigo do corretor deles e vai
   -- fazer a provisão. Faz isso para os três canais.
   --
   -- Canal Extra Banco
   --
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'REALIZANDO APROVISIONAMENTO - CANAL EXTRA BANCO.','P',NULL,NULL);
   COMMIT;
   VAR_TOTAL_INSERT := VAR_TOTAL_INSERT + VAR_CONTA_INSERT;
   VAR_CONTA_INSERT := 0;
   VAR_PONTO := '80';
   begin
       pc_util_01.Sgpb0003(VAR_FAIXA_INICIO, VAR_FAIXA_FIM, pc_util_01.EXTRA_BANCO, VAR_DPROX_CARGA);
       VAR_PONTO := '85';
       for PROV_EXTRA IN ( select DISTINCT CEC.CTPO_PSSOA, CEC.CCPF_CNPJ_BASE
	                         from CRRTR C, CRRTR_ELEIT_CAMPA CEC, parm_info_campa pic,
	                              MARGM_CONTB_CRRTR MCC, PROD_CRRTR PC
                             WHERE pic.Ccanal_Vda_Segur    = pc_util_01.EXTRA_BANCO AND
                               pic.DFIM_VGCIA_PARM           is null AND
                               CEC.CTPO_PSSOA              = C.CTPO_PSSOA AND
	                           CEC.CCPF_CNPJ_BASE          = C.CCPF_CNPJ_BASE AND
	                           CEC.CCANAL_VDA_SEGUR        = pic.Ccanal_Vda_Segur AND
	                           TRUNC(CEC.DINIC_VGCIA_PARM) = PIC.dinic_vgcia_parm AND
	                           CEC.DCRRTR_SELEC_CAMPA     >= PIC.dinic_vgcia_parm AND
                               C.CCRRTR                    = PC.CCRRTR AND
                               C.CUND_PROD                 = PC.CUND_PROD AND
                               C.CCRRTR                    BETWEEN 100000 AND 199999 and
                               PC.CCOMPT_PROD              = TO_CHAR(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1),'YYYYMM') AND
                               PC.CTPO_COMIS               = VAR_TIPO_COMISSAO AND
                               PC.CGRP_RAMO_PLANO          IN (VAR_RAMO_AUTO) AND
                               MCC.CCANAL_VDA_SEGUR        = CEC.CCANAL_VDA_SEGUR AND
                               MCC.CCPF_CNPJ_BASE          = CEC.CCPF_CNPJ_BASE AND
                               MCC.CTPO_PSSOA              = CEC.CTPO_PSSOA AND
                               MCC.PMARGM_CONTB           >= VAR_MARGEM AND
                               MCC.CCOMPT_MARGM            = PC.CCOMPT_PROD
	                           GROUP BY CEC.CTPO_PSSOA, CEC.CCPF_CNPJ_BASE
          		                        HAVING (VAR_PROD_MINIMA_EXTRABANCO / 3) <= SUM(PC.VPROD_CRRTR))
       LOOP
            VAR_PONTO := '90';
            BEGIN
                INSERT INTO HIST_CTBIL ( CCOMPT_MOVTO_CTBIL, CCOMPT_PROD, CCOMPT_PGTO, CPGTO_BONUS, CTPO_PSSOA,
                                     CCPF_CNPJ_BASE, CCRRTR, CUND_PROD, CRAMO, CCTA_CTBIL_CREDR, CCTA_CTBIL_DVDOR,
                                     VPGTO_TOT, CIND_ARQ_EXPOR, RHIST_CTBIL, DEXPOR_CTBIL, DINCL_REG, DULT_ALT)
          			SELECT VAR_COMPT, VAR_COMPT, VAR_COMPT, VAR_CONTA_REG, PROV_EXTRA.CTPO_PSSOA,
          			       PROV_EXTRA.CCPF_CNPJ_BASE, A.CCRRTR CCRRTR, A.CUND_PROD, VAR_RAMO_AUTO, VAR_CTA_PROV_CREDORA_EXTRA,
          			       VAR_CTA_PROV_DEVEDORA_EXTRA,
          			       SUM(B.VPROD_CRRTR * (case when (mcc.PMARGM_CONTB < 27 ) Then
                                                        0.01
      		                                         WHEN (mcc.PMARGM_CONTB >= 27 AND mcc.PMARGM_CONTB < 29) THEN
                                                        0.02
        	                                         WHEN (mcc.PMARGM_CONTB >= 29 AND mcc.PMARGM_CONTB < 31) THEN
                                                        0.03
         	                                         WHEN (mcc.PMARGM_CONTB >= 31 AND mcc.PMARGM_CONTB < 33) THEN
                                                        0.04
           	                                         WHEN (mcc.PMARGM_CONTB >= 33 AND mcc.PMARGM_CONTB < 35) THEN
                                                        0.05
          	                                         ELSE
          		                                        0.06
        	                                         end)) VL_PROVISAO,
        	               0, 'PROVISAO', NULL, SYSDATE, NULL
	                       FROM CRRTR A, PROD_CRRTR B, MARGM_CONTB_CRRTR MCC
                           WHERE B.CUND_PROD          = A.CUND_PROD AND
			                     B.CCRRTR             = A.CCRRTR AND
					             B.CCOMPT_PROD        = TO_CHAR(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1),'YYYYMM') AND
					             B.CTPO_COMIS         = VAR_TIPO_COMISSAO AND
					             B.CGRP_RAMO_PLANO    IN (VAR_RAMO_AUTO) AND
					             A.CCRRTR             BETWEEN 100000 AND 199999 and
					             A.CTPO_PSSOA         = PROV_EXTRA.CTPO_PSSOA AND
					             A.CCPF_CNPJ_BASE     = PROV_EXTRA.CCPF_CNPJ_BASE AND
					             MCC.CCANAL_VDA_SEGUR = pc_util_01.EXTRA AND
					             MCC.CCPF_CNPJ_BASE   = A.CCPF_CNPJ_BASE AND
					             MCC.CTPO_PSSOA       = A.CTPO_PSSOA AND
					             MCC.CCOMPT_MARGM     = B.CCOMPT_PROD 
					        GROUP BY A.CCRRTR, A.CUND_PROD
					              having SUM(B.VPROD_CRRTR * (case when (mcc.PMARGM_CONTB < 27 ) Then
                                                        0.01
      		                                         WHEN (mcc.PMARGM_CONTB >= 27 AND mcc.PMARGM_CONTB < 29) THEN
                                                        0.02
        	                                         WHEN (mcc.PMARGM_CONTB >= 29 AND mcc.PMARGM_CONTB < 31) THEN
                                                        0.03
         	                                         WHEN (mcc.PMARGM_CONTB >= 31 AND mcc.PMARGM_CONTB < 33) THEN
                                                        0.04
           	                                         WHEN (mcc.PMARGM_CONTB >= 33 AND mcc.PMARGM_CONTB < 35) THEN
                                                        0.05
          	                                         ELSE
          		                                        0.06
        	                                         end)) > 0;
			EXCEPTION
			    WHEN OTHERS THEN
			         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. CANAL EXTRA BANCO NAO ATIVO NA PARM_CANAL_VDA_SEGUR.','P',NULL,NULL);
			END;
			COMMIT;
            VAR_CONTA_INSERT := VAR_CONTA_INSERT + 1;
            VAR_CONTA_REG := VAR_CONTA_REG + 1;
       END LOOP;
       VAR_PONTO := '95';
   exception
       when no_data_found then
            PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ATENCAO! NAO SERA FEITO APROVISIONAMENTO PARA CANAL EXTRA BANCO.','P',NULL,NULL);
            PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. CANAL EXTRA BANCO NAO ATIVO NA PARM_CANAL_VDA_SEGUR.','P',NULL,NULL);
            COMMIT;
   END;
   VAR_PONTO := '100';
   IF VAR_CONTA_INSERT <> 0 THEN
      VAR_TEVE_PROVISAO := TRUE;
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. INSERIDA A PROVISAO DE '||VAR_CONTA_INSERT||' CORRETORES RAIZ (EXTRA BANCO).','P',NULL,NULL);
   ELSE
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HOUVE PROVISAO PARA EXTRA BANCO.','P',NULL,NULL);
   END IF;
   COMMIT;
   --
   -- Canal Banco
   --
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'REALIZANDO APROVISIONAMENTO - CANAL BANCO.','P',NULL,NULL);
   COMMIT;
   VAR_TOTAL_INSERT := VAR_TOTAL_INSERT + VAR_CONTA_INSERT;
   VAR_CONTA_INSERT := 0;
   VAR_PONTO := '110';
   begin
       pc_util_01.Sgpb0003(VAR_FAIXA_INICIO, VAR_FAIXA_FIM, pc_util_01.BANCO, VAR_DPROX_CARGA);
       VAR_PONTO := '111';
       for PROV_BANCO IN ( select DISTINCT CEC.CTPO_PSSOA, CEC.CCPF_CNPJ_BASE
	                         from CRRTR C, CRRTR_ELEIT_CAMPA CEC, parm_info_campa pic, 
	                              MARGM_CONTB_CRRTR MCC, PROD_CRRTR PC,  MPMTO_AG_CRRTR MAC
                             WHERE pic.Ccanal_Vda_Segur    = pc_util_01.BANCO AND
                               pic.DFIM_VGCIA_PARM           is null AND
                               CEC.CTPO_PSSOA              = C.CTPO_PSSOA AND
	                           CEC.CCPF_CNPJ_BASE          = C.CCPF_CNPJ_BASE AND
	                           CEC.CCANAL_VDA_SEGUR        = pic.Ccanal_Vda_Segur AND
	                           TRUNC(CEC.DINIC_VGCIA_PARM) = PIC.dinic_vgcia_parm AND
	                           CEC.DCRRTR_SELEC_CAMPA     >= PIC.dinic_vgcia_parm AND
                               C.CCRRTR                    = PC.CCRRTR AND
                               C.CUND_PROD                 = PC.CUND_PROD AND
                               C.CUND_PROD                 = MAC.CUND_PROD AND
                               C.CCRRTR                    = MAC.CCRRTR_DSMEM AND
                               MAC.CCRRTR_ORIGN            BETWEEN 800001 AND 870000 and           
                               ((DSAIDA_CRRTR_AG is null) OR 
                                        (DSAIDA_CRRTR_AG > LAST_DAY(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1)))) AND
                               PC.CCOMPT_PROD              = TO_CHAR(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1),'YYYYMM') AND
                               PC.CTPO_COMIS               = VAR_TIPO_COMISSAO AND
                               PC.CGRP_RAMO_PLANO          IN (VAR_RAMO_AUTO) AND
                               MCC.CCANAL_VDA_SEGUR        = CEC.CCANAL_VDA_SEGUR AND
                               MCC.CCPF_CNPJ_BASE          = CEC.CCPF_CNPJ_BASE AND
                               MCC.CTPO_PSSOA              = CEC.CTPO_PSSOA AND
                               MCC.PMARGM_CONTB           >= VAR_MARGEM AND
                               MCC.CCOMPT_MARGM            = PC.CCOMPT_PROD
	                           GROUP BY CEC.CTPO_PSSOA, CEC.CCPF_CNPJ_BASE
          		                        HAVING (VAR_PROD_MINIMA_BANCO / 3) <= SUM(PC.VPROD_CRRTR))
       LOOP
            VAR_PONTO := '120';
            INSERT INTO HIST_CTBIL ( CCOMPT_MOVTO_CTBIL, CCOMPT_PROD, CCOMPT_PGTO, CPGTO_BONUS, CTPO_PSSOA,
                                     CCPF_CNPJ_BASE, CCRRTR, CUND_PROD, CRAMO, CCTA_CTBIL_CREDR, CCTA_CTBIL_DVDOR,
                                     VPGTO_TOT, CIND_ARQ_EXPOR, RHIST_CTBIL, DEXPOR_CTBIL, DINCL_REG, DULT_ALT)
          			SELECT VAR_COMPT, VAR_COMPT, VAR_COMPT, VAR_CONTA_REG, PROV_BANCO.CTPO_PSSOA,
          			       PROV_BANCO.CCPF_CNPJ_BASE, A.CCRRTR CCRRTR, A.CUND_PROD, VAR_RAMO_AUTO, VAR_CTA_PROV_CREDORA_BANCO,
          			       VAR_CTA_PROV_DEVEDORA_BANCO,
          			       SUM(B.VPROD_CRRTR * (case when (mcc.PMARGM_CONTB < 27 ) Then
                                                        0.01
      		                                         WHEN (mcc.PMARGM_CONTB >= 27 AND mcc.PMARGM_CONTB < 29) THEN
                                                        0.02
        	                                         WHEN (mcc.PMARGM_CONTB >= 29 AND mcc.PMARGM_CONTB < 31) THEN
                                                        0.03
         	                                         WHEN (mcc.PMARGM_CONTB >= 31 AND mcc.PMARGM_CONTB < 33) THEN
                                                        0.04
           	                                         WHEN (mcc.PMARGM_CONTB >= 33 AND mcc.PMARGM_CONTB < 35) THEN
                                                        0.05
          	                                         ELSE
          		                                        0.06
        	                                         end))  VL_PROVISAO,
        	               0, 'PROVISAO', NULL, SYSDATE, NULL
	                       FROM CRRTR A, PROD_CRRTR B, MARGM_CONTB_CRRTR MCC, MPMTO_AG_CRRTR MAC
                           WHERE B.CUND_PROD          = A.CUND_PROD AND
			                     B.CCRRTR             = A.CCRRTR AND
					             B.CCOMPT_PROD        = TO_CHAR(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1),'YYYYMM') AND
					             B.CTPO_COMIS         = VAR_TIPO_COMISSAO AND
					             B.CGRP_RAMO_PLANO    IN (VAR_RAMO_AUTO) AND
					             A.CUND_PROD          = MAC.CUND_PROD AND
                                 A.CCRRTR             = MAC.CCRRTR_DSMEM AND
                                 MAC.CCRRTR_ORIGN     BETWEEN 800001 AND 870000 and                                  
                                 ((DSAIDA_CRRTR_AG is null) OR 
                                         (DSAIDA_CRRTR_AG > LAST_DAY(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1)))) AND
					             A.CTPO_PSSOA         = PROV_BANCO.CTPO_PSSOA AND
					             A.CCPF_CNPJ_BASE     = PROV_BANCO.CCPF_CNPJ_BASE AND
					             MCC.CCANAL_VDA_SEGUR = pc_util_01.BANCO and
					             MCC.CCPF_CNPJ_BASE   = A.CCPF_CNPJ_BASE AND
					             MCC.CTPO_PSSOA       = A.CTPO_PSSOA AND
					             MCC.CCOMPT_MARGM     = B.CCOMPT_PROD 
					        GROUP BY A.CCRRTR, A.CUND_PROD
					              having SUM(B.VPROD_CRRTR * (case when (mcc.PMARGM_CONTB < 27 ) Then
                                                        0.01
      		                                         WHEN (mcc.PMARGM_CONTB >= 27 AND mcc.PMARGM_CONTB < 29) THEN
                                                        0.02
        	                                         WHEN (mcc.PMARGM_CONTB >= 29 AND mcc.PMARGM_CONTB < 31) THEN
                                                        0.03
         	                                         WHEN (mcc.PMARGM_CONTB >= 31 AND mcc.PMARGM_CONTB < 33) THEN
                                                        0.04
           	                                         WHEN (mcc.PMARGM_CONTB >= 33 AND mcc.PMARGM_CONTB < 35) THEN
                                                        0.05
          	                                         ELSE
          		                                        0.06
        	                                         end)) > 0;
			COMMIT;
            VAR_CONTA_INSERT := VAR_CONTA_INSERT + 1;
            VAR_CONTA_REG := VAR_CONTA_REG + 1;
       END LOOP;
       VAR_PONTO := '130';
   exception
       when no_data_found then
            PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ATENCAO! NAO SERA FEITO APROVISIONAMENTO PARA CANAL BANCO.','P',NULL,NULL);
            PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. CANAL BANCO NAO ATIVO NA PARM_CANAL_VDA_SEGUR.','P',NULL,NULL);
            COMMIT;
   END;
   VAR_PONTO := '140';
   IF VAR_CONTA_INSERT <> 0 THEN
      VAR_TEVE_PROVISAO := TRUE;
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. INSERIDA A PROVISAO DE '||VAR_CONTA_INSERT||' CORRETORES RAIZ (BANCO).','P',NULL,NULL);
   ELSE
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HOUVE PROVISAO PARA BANCO.','P',NULL,NULL);
   END IF;
   COMMIT;
   --
   -- Canal Finasa
   --
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'REALIZANDO APROVISIONAMENTO - CANAL FINASA.','P',NULL,NULL);
   COMMIT;
   VAR_TOTAL_INSERT := VAR_TOTAL_INSERT + VAR_CONTA_INSERT;
   VAR_CONTA_INSERT := 0;
   VAR_PONTO := '150';
   begin
       pc_util_01.Sgpb0003(VAR_FAIXA_INICIO, VAR_FAIXA_FIM, pc_util_01.FINASA, VAR_DPROX_CARGA);
       VAR_PONTO := '155';
       for PROV_FINASA IN ( select DISTINCT CEC.CTPO_PSSOA, CEC.CCPF_CNPJ_BASE
	                         from CRRTR C, CRRTR_ELEIT_CAMPA CEC, parm_info_campa pic,
	                              MARGM_CONTB_CRRTR MCC, PROD_CRRTR PC,  MPMTO_AG_CRRTR MAC
                             WHERE pic.Ccanal_Vda_Segur    = pc_util_01.FINASA AND
                               pic.DFIM_VGCIA_PARM           is null AND
                               CEC.CTPO_PSSOA              = C.CTPO_PSSOA AND
	                           CEC.CCPF_CNPJ_BASE          = C.CCPF_CNPJ_BASE AND
	                           CEC.CCANAL_VDA_SEGUR        = pic.Ccanal_Vda_Segur AND
	                           TRUNC(CEC.DINIC_VGCIA_PARM) = PIC.dinic_vgcia_parm AND
	                           CEC.DCRRTR_SELEC_CAMPA     >= PIC.dinic_vgcia_parm AND
                               C.CCRRTR                    = PC.CCRRTR AND
                               C.CUND_PROD                 = PC.CUND_PROD AND
                               C.CUND_PROD                 = MAC.CUND_PROD AND
                               C.CCRRTR                    = MAC.CCRRTR_DSMEM AND
                               MAC.CCRRTR_ORIGN            BETWEEN 870001 AND 879999 and
                               PC.CCOMPT_PROD              = TO_CHAR(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1),'YYYYMM') AND                                                                
                              ((DSAIDA_CRRTR_AG is null) OR 
                                    (DSAIDA_CRRTR_AG > LAST_DAY(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1)))) AND
                               PC.CTPO_COMIS               = VAR_TIPO_COMISSAO AND
                               PC.CGRP_RAMO_PLANO          IN (VAR_RAMO_AUTO) AND
                               MCC.CCANAL_VDA_SEGUR        = CEC.CCANAL_VDA_SEGUR AND
                               MCC.CCPF_CNPJ_BASE          = CEC.CCPF_CNPJ_BASE AND
                               MCC.CTPO_PSSOA              = CEC.CTPO_PSSOA AND
                               MCC.PMARGM_CONTB           >= VAR_MARGEM AND
                               MCC.CCOMPT_MARGM            = PC.CCOMPT_PROD
	                           GROUP BY CEC.CTPO_PSSOA, CEC.CCPF_CNPJ_BASE
          		                        HAVING (VAR_PROD_MINIMA_FINASA / 3) <= SUM(PC.VPROD_CRRTR))
       LOOP
            VAR_PONTO := '160';
            INSERT INTO HIST_CTBIL ( CCOMPT_MOVTO_CTBIL, CCOMPT_PROD, CCOMPT_PGTO, CPGTO_BONUS, CTPO_PSSOA,
                                     CCPF_CNPJ_BASE, CCRRTR, CUND_PROD, CRAMO, CCTA_CTBIL_CREDR, CCTA_CTBIL_DVDOR,
                                     VPGTO_TOT, CIND_ARQ_EXPOR, RHIST_CTBIL, DEXPOR_CTBIL, DINCL_REG, DULT_ALT)
          			SELECT VAR_COMPT, VAR_COMPT, VAR_COMPT, VAR_CONTA_REG, PROV_FINASA.CTPO_PSSOA,
          			       PROV_FINASA.CCPF_CNPJ_BASE, A.CCRRTR CCRRTR, A.CUND_PROD, VAR_RAMO_AUTO, VAR_CTA_PROV_CREDORA_FINASA,
          			       VAR_CTA_PROV_DEVEDORA_FINASA,
          			       SUM(B.VPROD_CRRTR * (case when (mcc.PMARGM_CONTB < 27 ) Then
                                                        0.01
      		                                         WHEN (mcc.PMARGM_CONTB >= 27 AND mcc.PMARGM_CONTB < 29) THEN
                                                        0.02
        	                                         WHEN (mcc.PMARGM_CONTB >= 29 AND mcc.PMARGM_CONTB < 31) THEN
                                                        0.03
         	                                         WHEN (mcc.PMARGM_CONTB >= 31 AND mcc.PMARGM_CONTB < 33) THEN
                                                        0.04
           	                                         WHEN (mcc.PMARGM_CONTB >= 33 AND mcc.PMARGM_CONTB < 35) THEN
                                                        0.05
          	                                         ELSE
          		                                        0.06
        	                                         end)) VL_PROVISAO,
        	               0, 'PROVISAO', NULL, SYSDATE, NULL
	                       FROM CRRTR A, PROD_CRRTR B, MARGM_CONTB_CRRTR MCC, MPMTO_AG_CRRTR MAC
                           WHERE B.CUND_PROD          = A.CUND_PROD AND
			                     B.CCRRTR             = A.CCRRTR AND
					             B.CCOMPT_PROD        = TO_CHAR(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1),'YYYYMM') AND					                                              
                                 ((DSAIDA_CRRTR_AG is null) OR
                                           (DSAIDA_CRRTR_AG > LAST_DAY(ADD_MONTHS(TO_DATE(VAR_COMPT||'01','YYYYMMDD'),-1)))) AND
					             B.CTPO_COMIS         = VAR_TIPO_COMISSAO AND
					             B.CGRP_RAMO_PLANO    IN (VAR_RAMO_AUTO) AND
					             A.CUND_PROD          = MAC.CUND_PROD AND
                                 A.CCRRTR             = MAC.CCRRTR_DSMEM AND
                                 MAC.CCRRTR_ORIGN     BETWEEN 870001 AND 879999 and
					             A.CTPO_PSSOA         = PROV_FINASA.CTPO_PSSOA AND
					             A.CCPF_CNPJ_BASE     = PROV_FINASA.CCPF_CNPJ_BASE AND
					             MCC.CCANAL_VDA_SEGUR = pc_util_01.FINASA AND
					             MCC.CCPF_CNPJ_BASE   = A.CCPF_CNPJ_BASE AND
					             MCC.CTPO_PSSOA       = A.CTPO_PSSOA AND
					             MCC.CCOMPT_MARGM     = B.CCOMPT_PROD 
					        GROUP BY A.CCRRTR, A.CUND_PROD
					              having SUM(B.VPROD_CRRTR * (case when (mcc.PMARGM_CONTB < 27 ) Then
                                                        0.01
      		                                         WHEN (mcc.PMARGM_CONTB >= 27 AND mcc.PMARGM_CONTB < 29) THEN
                                                        0.02
        	                                         WHEN (mcc.PMARGM_CONTB >= 29 AND mcc.PMARGM_CONTB < 31) THEN
                                                        0.03
         	                                         WHEN (mcc.PMARGM_CONTB >= 31 AND mcc.PMARGM_CONTB < 33) THEN
                                                        0.04
           	                                         WHEN (mcc.PMARGM_CONTB >= 33 AND mcc.PMARGM_CONTB < 35) THEN
                                                        0.05
          	                                         ELSE
          		                                        0.06
        	                                         end)) > 0;
			COMMIT;
            VAR_CONTA_INSERT := VAR_CONTA_INSERT + 1;
            VAR_CONTA_REG := VAR_CONTA_REG + 1;
       END LOOP;
       VAR_PONTO := '170';
   exception
       when no_data_found then
            PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ATENCAO! NAO SERA FEITO APROVISIONAMENTO PARA CANAL FINASA.','P',NULL,NULL);
            PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. CANAL FINASA NAO ATIVO NA PARM_CANAL_VDA_SEGUR.','P',NULL,NULL);
            COMMIT;
   END;
   VAR_PONTO := '180';
   IF VAR_CONTA_INSERT <> 0 THEN
      VAR_TEVE_PROVISAO := TRUE;
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. INSERIDA A PROVISAO DE '||VAR_CONTA_INSERT||' CORRETORES RAIZ (FINASA).','P',NULL,NULL);
   ELSE
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HOUVE PROVISAO PARA FINASA.','P',NULL,NULL);
   END IF;
   COMMIT;
   --
   -- Se houve pagamento para o periodo contabil, vai estornar todos os provisionamentos feitos para o periodo referente ao pagto
   --
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'VERIFICANDO NECESSIADE DE ESTORNO DE PROVISAO.','P',NULL,NULL);
   COMMIT;
   VAR_PONTO := '190';
   IF VAR_PAGTO_REALIZADO <> 0
   THEN
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ESTORNANDO PROVISIONAMENTOS DO PERIODO DE PAGAMENTO.','P',NULL,NULL);
      COMMIT;
      --
      -- Pegando os meses de competencia de pagamento que foram provisionados e que pertencem ao pagamento realizado
      -- Será feito o estorno de todos os meses provisionados QUE referem-se aos MESES de Apuração desse pagto, ou seja,
      -- Será feito Estorno de todos os meses anteriores até esse MÊS.
      --
      VAR_PONTO := '200';
      select max(PAP.CCOMPT_PROD) into VAR_ULT_MES_PAGTO_APURC
       				   from PGTO_BONUS_CRRTR pbc, HIST_DISTR_PGTO HDP, PAPEL_APURC_PGTO PAP
					   WHERE pbc.CPGTO_BONUS = hdp.CPGTO_BONUS and
					         pbc.CPGTO_BONUS = pap.CPGTO_BONUS and
					         pbc.CIND_ARQ_EXPOR <> 0 AND
					         pbc.CCOMPT_PGTO = VAR_COMPT;
      VAR_TOTAL_INSERT := VAR_TOTAL_INSERT + VAR_CONTA_INSERT;
      VAR_CONTA_INSERT := 0;
      VAR_PONTO := '210';
       --
       -- Pegando todas as provisões realizadas até a competencia de pagamento e realizando o estorno (VAR_ULT_MES_PAGTO_APURC)
       -- Somente irá estornar se o registro estiver sido enviado para a contabilidade (CIND_ARQ_EXPOR=1) e seja CONTA DE PROVISÃO.
       --
       -- Atenção: É utilizado o campo CIND_ARQ_EXPOR para identificar as Provisões realizadas.
       --          CIND_ARQ_EXPOR = 0 -> Lancamento nao enviado para contabilidade (não vai estornar)
       --          CIND_ARQ_EXPOR = 1 -> Lancamento enviado para contabilidade (se for provisão vai gerar um registro de estorno)
       --          CIND_ARQ_EXPOR = 2 -> Lancamento de provisao enviado para contabilidade e já estornado anteriormente
       -- -------------------------------------------------------------------------------------------------------------
       FOR P IN ( SELECT rowid row_reg, CCOMPT_PROD, CCOMPT_PGTO, CTPO_PSSOA, CCPF_CNPJ_BASE, CCRRTR, CUND_PROD, CRAMO,
                         case    when CCTA_CTBIL_CREDR = VAR_CTA_PROV_CREDORA_BANCO then
        		 		                 VAR_CTA_ESTOR_CREDORA_BANCO
        					        when CCTA_CTBIL_CREDR = VAR_CTA_PROV_CREDORA_FINASA then
           		 					     VAR_CTA_ESTOR_CREDORA_FINASA
           					        when CCTA_CTBIL_CREDR = VAR_CTA_PROV_CREDORA_EXTRA then
           		 					     VAR_CTA_ESTOR_CREDORA_EXTRA
   				        end CCTA_CTBIL_CREDR,
                            case    when CCTA_CTBIL_DVDOR = VAR_CTA_PROV_DEVEDORA_BANCO then
           		 		                 VAR_CTA_ESTOR_DEVEDORA_BANCO
           					        when CCTA_CTBIL_DVDOR = VAR_CTA_PROV_DEVEDORA_FINASA then
           		 					     VAR_CTA_ESTOR_DEVEDORA_FINASA
           					        when CCTA_CTBIL_DVDOR = VAR_CTA_PROV_DEVEDORA_EXTRA then
           		 					     VAR_CTA_ESTOR_DEVEDORA_EXTRA
    				        end CCTA_CTBIL_DVDOR, VPGTO_TOT
                            FROM HIST_CTBIL
                            WHERE CCOMPT_MOVTO_CTBIL <= VAR_ULT_MES_PAGTO_APURC AND -- Vai Estornar até a data do pagto apurado.
                                  CCOMPT_PGTO        <= VAR_ULT_MES_PAGTO_APURC AND -- Vai Estornar até a data do pagto apurado.
                                  CCOMPT_PROD        <= VAR_ULT_MES_PAGTO_APURC AND -- Vai Estornar até a data do pagto apurado.
                                  CCTA_CTBIL_CREDR IN (VAR_CTA_PROV_CREDORA_BANCO,VAR_CTA_PROV_CREDORA_FINASA,
                                                       VAR_CTA_PROV_CREDORA_EXTRA) AND
                                  CCTA_CTBIL_DVDOR IN (VAR_CTA_PROV_DEVEDORA_BANCO,VAR_CTA_PROV_DEVEDORA_FINASA,
                                                       VAR_CTA_PROV_DEVEDORA_EXTRA) AND
                                  CIND_ARQ_EXPOR = 1  and -- Somente o que foi contabilizado e ainda não foi estornado
                                  DEXPOR_CTBIL is not null -- Somente o que foi contabilizado e ainda não foi estornado
                                  )
       LOOP
            VAR_CONTA_REG := VAR_CONTA_REG + 1;
            VAR_CONTA_INSERT := VAR_CONTA_INSERT + 1;
            VAR_PONTO := '220';
            --
            -- Inserindo estorno dos meses que foram provisionados e estao sendo pagos agora.
            --
            INSERT INTO HIST_CTBIL ( CCOMPT_MOVTO_CTBIL, CCOMPT_PROD, CCOMPT_PGTO, CPGTO_BONUS,
                                     CTPO_PSSOA, CCPF_CNPJ_BASE, CCRRTR, CUND_PROD, CRAMO,
                                     CCTA_CTBIL_CREDR, CCTA_CTBIL_DVDOR,
                                     VPGTO_TOT, CIND_ARQ_EXPOR, RHIST_CTBIL, DEXPOR_CTBIL, DINCL_REG, DULT_ALT)
          			 VALUES		  ( VAR_COMPT, P.CCOMPT_PROD, P.CCOMPT_PGTO, VAR_CONTA_REG, P.CTPO_PSSOA,
          			                P.CCPF_CNPJ_BASE, P.CCRRTR, P.CUND_PROD, P.CRAMO, P.CCTA_CTBIL_CREDR,
          			                P.CCTA_CTBIL_DVDOR, P.VPGTO_TOT, 0, 'ESTORNO', NULL, SYSDATE, NULL);
            --
            -- Depois de Inserir o Estorno, marca as Provisoes antigas como estornadas.
            -- Elas estavam com 1 e vão ficar com 2 no campo CIND_ARQ_EXPOR
            --
            VAR_PONTO := '230';
            update HIST_CTBIL set
            	   CIND_ARQ_EXPOR = 2,
            	   DULT_ALT = SYSDATE
            	   where rowid = p.row_reg;
       end loop;
      VAR_PONTO := '240';
      IF VAR_CONTA_INSERT <> 0 THEN
         VAR_TEVE_ESTORNO := TRUE;
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. INSERIDOS '||VAR_CONTA_INSERT||' DE ESTORNOS.','P',NULL,NULL);
      ELSE
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO HOUVERAM REGISTROS INSERIDOS DE ESTORNO. ','P',NULL,NULL);
      END IF;
      COMMIT;
   ELSE
      VAR_PONTO := '250';
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO SERA FEITO ESTORNO. NAO FOI ENCONTRADO PAGAMENTO.','P',NULL,NULL);
      COMMIT;
   END IF;
   VAR_PONTO := '300';
   --
   -- Checando o Processamento. Em alguns casos vai cair para PE em outros vai GERAR apenas mensagem no log.
   --
   VAR_TOTAL_INSERT := VAR_TOTAL_INSERT + VAR_CONTA_INSERT;
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'CONSISTINDO A CONTABILIZACAO.','P',NULL,NULL);
   IF VAR_TEVE_PAGTO = TRUE AND VAR_TEVE_ESTORNO = FALSE THEN
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ERRO! HOUVE PAGTO MAS NAO HOUVE ESTORNO.','P',NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
   ELSIF VAR_PAGTO_CONTABILIZADO <> VAR_PAGTO_REALIZADO THEN
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ERRO! NUMERO DE LANCAMENTOS DE PAGAMENTOS DIFEREM DOS PAGAMENTOS.','P',NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
   ELSIF VAR_TOTAL_INSERT = 0 THEN
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ERRO! NAO FOI GERADO NENHUM LANCAMENTO.','P',NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
   ELSIF VAR_TEVE_PROVISAO = FALSE THEN
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. ATENCAO! NAO HOUVE PROVISAO.','P',NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PO);
   ELSE
      PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'. NAO FORAM ENCONTRADAS INCONSISTENCIAS.','P',NULL,NULL);
   END IF;
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TERMINO DO PROCESSAMENTO, '||VAR_TOTAL_INSERT||' LANCAMENTOS REALIZADOS.','P',NULL,NULL);
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PO);
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    VAR_LOG_ERRO := 'PONTO: '||VAR_PONTO||'. ERRO EXCEPTION. ERRO: '||SQLERRM;
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,VAR_LOG_ERRO,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
    COMMIT;
    Raise_Application_Error(-20210,VAR_LOG_ERRO);
END SGPB0230;
/

