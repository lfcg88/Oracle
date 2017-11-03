CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0020_TR(Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
                                     Intrcanal       NUMBER) IS
  Intinicialfaixa Parm_Canal_Vda_Segur . Cinic_Faixa_Crrtr %TYPE;
  Intfinalfaixa   Parm_Canal_Vda_Segur . Cfnal_Faixa_Crrtr %TYPE;
  Intquantminrel  Parm_Canal_Vda_Segur . Qtempo_Min_Rlcto %TYPE;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : Sgpb0020_TR
  --      DATA            : 8/3/2006
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para inserir na tabela temporaria os corretores que apresentarem tempo de relacionamento, comissão normal e estiverem no canal Extra-Banco
  --      ALTERAÇÕES      : Corrigido problema de pegar codigos de CPD que não eram da faixa 100 e causavam a eleição de corretores
  --                        novos no Plano de Bônus. Ass. Wassily ( 03/01/2007 ).  
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(08) := 'SGPB9024';
BEGIN
  Pc_Util_01.Sgpb0003(Intinicialfaixa, Intfinalfaixa, Pc_Util_01.Extra_Banco, Intrcompetencia);
  Pc_Util_01.Sgpb0006(Intquantminrel, Intrcanal, Intrcompetencia);
  -- --------------------------------------------------------------------------------
  -- Retirada a query abaixo por que estava considerando Corretores fora da Faixa 100
  -- Ass. Wassily Chuk ( 03/01/2008)
  -- --------------------------------------------------------------------------------
  --UPDATE Crrtr C
  --   SET C.Cind_Crrtr_Selec = 0
  -- WHERE c.cind_crrtr_selec = 1
  --   and (Ccrrtr, Cund_Prod) IN (
  --       SELECT distinct C.Ccrrtr, C.Cund_Prod
  --         FROM (SELECT c.ccpf_cnpj_base, c.ctpo_pssoa
  --                 FROM Crrtr C
  --                GROUP
  --                   BY c.ccpf_cnpj_base, c.ctpo_pssoa
  --               having Months_Between(Last_Day(To_Date(Intrcompetencia, 'YYYYMM')), MIN(C.Dcadto_Crrtr)) < Intquantminrel
  --               ) inner_q
  --         join crrtr c
  --           on c.ccpf_cnpj_base = inner_q.ccpf_cnpj_base
  --          and c.ctpo_pssoa = inner_q.ctpo_pssoa
  --        where c.cind_crrtr_selec = 1
  --        );
  -- Nova Query (vide abaixo) que trata o problema citado acima.
  -- ----------------------------------------------------------- 
   UPDATE Crrtr C
     SET C.Cind_Crrtr_Selec = 0
   WHERE c.cind_crrtr_selec = 1
     and (Ccrrtr, Cund_Prod) IN (SELECT distinct C.Ccrrtr, C.Cund_Prod
                                        FROM (SELECT c.ccpf_cnpj_base, c.ctpo_pssoa
                                                     FROM Crrtr C, PARM_CANAL_VDA_SEGUR pcvs
                                                     where pcvs.CCANAL_VDA_SEGUR = 1 and -- Extra Banco (forcado mesmo)
                                                          (C.Ccrrtr between pcvs.CINIC_FAIXA_CRRTR and pcvs.CFNAL_FAIXA_CRRTR) and
                                                           pcvs.DFIM_VGCIA_PARM is null
                                                     GROUP BY c.ccpf_cnpj_base, c.ctpo_pssoa
                                                     having Months_Between(Last_Day(To_Date(Intrcompetencia,'YYYYMM')),
                                                            MIN(C.Dcadto_Crrtr)) < Intquantminrel) inner_q, 
                                                     crrtr c, PARM_CANAL_VDA_SEGUR pcvs
                                              where c.ccpf_cnpj_base = inner_q.ccpf_cnpj_base and
                                                    c.ctpo_pssoa = inner_q.ctpo_pssoa and
                                                    pcvs.CCANAL_VDA_SEGUR = 1 and -- Extra Banco (forcado mesmo)
                                                    (C.Ccrrtr between pcvs.CINIC_FAIXA_CRRTR and pcvs.CFNAL_FAIXA_CRRTR) and
                                                    pcvs.DFIM_VGCIA_PARM is null and
                                                    c.cind_crrtr_selec = 1
                                ); 
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal ||
                           ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    Raise_Application_Error(-20210,var_log_erro);
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao inserir na tabela temporaria corretores que apresentem tempo de relacionamento e comissão normal.Competência:' ||
                           Intrcompetencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
    Pr_Grava_Msg_Log_Carga_Sgpb(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
    Raise_Application_Error(-20210,var_log_erro);
END Sgpb0020_TR;
/

