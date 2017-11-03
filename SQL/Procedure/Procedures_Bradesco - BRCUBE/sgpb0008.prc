CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0008(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                             Intrcanal NUMBER) IS
  Intinicialfaixa Parm_Canal_Vda_Segur.Cinic_Faixa_Crrtr%TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur.Cfnal_Faixa_Crrtr%TYPE;
  Intquantminrel  Parm_Canal_Vda_Segur.Qtempo_Min_Rlcto%TYPE;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0008
  --      DATA            : 8/3/2006 14:46:47
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para inserir na tabela temporaria os corretores que apresentarem tempo de relacionamento, 
  --                        comissão normal e estiverem nos canais Banco e Finasa
  --                        25/09/2007 - MELHORADAS ROTINAS DE EXCEPTION. ASS. WASSILY
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(8) := 'SGPB0008';
BEGIN
  Pc_Util_01.Sgpb0003(Intinicialfaixa, Intfinalfaixa, Intrcanal, Intrcompetencia); -- retornar faixa corretor
  Pc_Util_01.Sgpb0006(Intquantminrel, Intrcanal, Intrcompetencia); -- tempo minimo de relacionamento
  UPDATE Crrtr Cr
     SET Cr.Cind_Crrtr_Selec = 1 -- marca como eleito
   WHERE (Ccrrtr, Cund_Prod) IN
         (select c.ccrrtr, c.cund_prod
            from crrtr c
            join (SELECT c.ccpf_cnpj_base, c.ctpo_pssoa                 
                         FROM MPMTO_AG_CRRTR MAC                 
                         join crrtr c on c.ccrrtr = mac.ccrrtr_dsmem
                                     and c.cund_prod = mac.cund_prod                 
                        WHERE MAC.CCRRTR_ORIGN BETWEEN Intinicialfaixa AND Intfinalfaixa
                          AND last_day(TO_DATE(Intrcompetencia, 'YYYYMM')) >= MAC.DENTRD_CRRTR_AG
                          AND last_day(TO_DATE(Intrcompetencia, 'YYYYMM')) < NVL(MAC.DSAIDA_CRRTR_AG, TO_DATE(99991231, 'YYYYMMDD'))                 
                     group by c.ccpf_cnpj_base, c.ctpo_pssoa                 
                     having Months_Between(Last_Day(To_Date(Intrcompetencia, 'YYYYMM')), min(c.Dcadto_Crrtr)) >= Intquantminrel) m 
            on m.ccpf_cnpj_base = c.ccpf_cnpj_base
           and m.ctpo_pssoa = c.ctpo_pssoa);
EXCEPTION
  WHEN No_Data_Found THEN
       Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
       ROLLBACK;
       PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
       COMMIT;
       RAISE_APPLICATION_ERROR(-21000,Var_Log_Erro);
  WHEN Too_Many_Rows THEN
       Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
       ROLLBACK;
       PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
       COMMIT;
       RAISE_APPLICATION_ERROR(-21000,Var_Log_Erro);
  WHEN OTHERS THEN
       Var_Log_Erro := Substr('Erro ao inserir corretores que apresentem tempo de relacionamento. Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
       ROLLBACK;
       PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
       COMMIT;
       RAISE_APPLICATION_ERROR(-21000,Var_Log_Erro);
END Sgpb0008;
/

