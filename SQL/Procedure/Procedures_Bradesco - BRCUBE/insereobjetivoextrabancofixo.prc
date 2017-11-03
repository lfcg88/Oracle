CREATE OR REPLACE PROCEDURE SGPB_PROC.insereObjetivoExtraBancoFixo(
      chrNomeRotinaScheduler VARCHAR2
    ) IS
    
             -- insere objetivo apenas alguns corretores com hard code (vide esse fonte)
             -- somente 200701, 200702 e 200703
             -- pega a produção de 200601, 200602, 200603 e aplica o percentual de crescimento.
             -- wassily (testando)
  i         integer := 1;
  type      TLinha is table of carac_crrtr_canal%rowtype index by binary_integer;
  vLinha    TLinha; 
  --
  VAR_LOG_ERRO VARCHAR2(1000);
  chrLocalErro VARCHAR2(2) := '00'; 
  --  
begin
  
  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 91953836;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 85326544;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 85229540;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 81340994;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 80420458;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 78513348;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 75768325;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 69324291;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 65869471;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 50939685;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 41330481;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 32779142;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 26747287;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 26703199;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 26417485;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 24342404;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 13365416;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 11927894;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 11748654;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 10410025;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 7694881;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 7517617;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 7125448;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 6340800;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 5412181;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 4886928;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 4881881;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 4859412;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 4712296;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 4137811;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 4011426;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 3610806;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 3175092;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 3174889;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 3074180;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 2643661;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 2594424;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 2087595;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 1856255;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 1764886;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 1533854;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 1159941;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 1159940;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 1021899;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 797204;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 432276;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 303137;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 103863;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 100821;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 76797;  
  vLinha(i).PCRSCT_PROD_ORIGN := 10;  
  I := I + 1;

  vLinha(i).CTPO_PSSOA := 'J';
  vLinha(i).CCPF_CNPJ_BASE := 66446;  
  vLinha(i).PCRSCT_PROD_ORIGN := 5;  
  
  --DBMS_OUTPUT.put_line(vLinha.LAST);
  for idx in 1..vLinha.LAST loop
    --DBMS_OUTPUT.put_line(vLinha(idx).CCPF_CNPJ_BASE);
    
    --
    chrLocalErro := 01;
    --   
    ------------------------------------------------------
    -- DELETE    
    ------------------------------------------------------
    delete 
      from objtv_prod_crrtr opc
     where opc.ctpo_pssoa     = vLinha(idx).CTPO_PSSOA
       and opc.ccpf_cnpj_base = vLinha(idx).CCPF_CNPJ_BASE
       and opc.cano_mes_compt_objtv between 200701 and 200703  -- ok. wassily
       and opc.cgrp_ramo_plano = 120
       and opc.ccanal_vda_segur = 1;
 commit; 
      
    --
    chrLocalErro := 02;
    --   
    ------------------------------------------------------
    -- INSERT
    ------------------------------------------------------
    INSERT INTO objtv_prod_crrtr
      (
         ctpo_pssoa,
         ccpf_cnpj_base,
         cgrp_ramo_plano,
         ccanal_vda_segur,
         cano_mes_compt_objtv,
         cseq_objtv_crrtr,
         vobjtv_prod_crrtr_alt,
         vobjtv_prod_crrtr_orign,
         cind_reg_ativo,
         dult_alt,
         cresp_ult_alt
      )
      SELECT C.CTPO_PSSOA,
             C.CCPF_CNPJ_BASE,
             pc.cgrp_ramo_plano,
             1,  --EXTRA-BANCO
             To_Number(To_Char(Add_Months(To_Date(pc.ccompt_prod, 'yyyymm'), 12), 'YYYYMM')), -- soma um ano
             1, --sequencial burro
             SUM(PC.VPROD_CRRTR * (1+ (vLinha(idx).PCRSCT_PROD_ORIGN/100) )),
             SUM(PC.VPROD_CRRTR * (1+ (vLinha(idx).PCRSCT_PROD_ORIGN/100) )),
             'S',
             sysdate,
             'CARGA-FIXO'
               --
                 FROM CRRTR C
                 JOIN PROD_CRRTR PC ON PC.CCRRTR = C.CCRRTR
                                   AND PC.CUND_PROD = C.CUND_PROD
                                   AND PC.CGRP_RAMO_PLANO = 120
                                   AND PC.CCOMPT_PROD BETWEEN 200601 and 200603--intComptInicialAnterior AND IntrcompetenciaAnterior
                                   AND PC.CTPO_COMIS = 'CN'
                                   AND PC.CCRRTR BETWEEN 100000 and 200000
               --
               --
               where c.ctpo_pssoa     = vLinha(idx).CTPO_PSSOA
                 and c.ccpf_cnpj_base = vLinha(idx).CCPF_CNPJ_BASE
               
                GROUP BY C.CTPO_PSSOA,C.CCPF_CNPJ_BASE,pc.cgrp_ramo_plano,pc.ccompt_prod;
  end loop;
  EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro ||
                           ' Canal: ' || to_char(PC_UTIL_01.Extra_Banco) || ' # ' || SQLERRM,
                           1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169',
                           var_log_erro, pc_util_01.VAR_LOG_PROCESSO, NULL, NULL);
    --
    PR_ATUALIZA_STATUS_ROTINA('SGPB0169'||' - insereObjetivoExtraBancoFixo',
                              722,  PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20213,'CARGA COM ERRO. COD. ERRO: 20 - Erro Ora: '||SUBSTR(SQLERRM,1,100));
    -- 
end insereObjetivoExtraBancoFixo;
/

