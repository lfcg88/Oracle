CREATE OR REPLACE PACKAGE BODY SGPB_PROC.Pc_Util_01 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0017
  --      DATA            : 7/3/2006 09:03:55
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Função que converte uma data para a uma competencia sendo retuzida de "n" meses
  -------------------------------------------------------------------------------------------------
  FUNCTION Sgpb0017(Dtmvvigencia DATE, Intvqtmesanlse NUMBER)
    RETURN Prod_Crrtr.Ccompt_Prod%TYPE AS
    Var_Crotna VARCHAR2(8) := 'SGPB0017';
  BEGIN
    RETURN To_Number(To_Char(Add_Months(Dtmvvigencia,(Intvqtmesanlse * -1)),'YYYYMM'));
  EXCEPTION
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao Converter uma data em competencia.Competência:' ||
                             Dtmvvigencia || ' Quantidade de Meses: ' ||
                             Intvqtmesanlse || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro, Pc_Util_01.Var_Log_Processo,NULL, NULL);
      RAISE;
  END Sgpb0017;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0017
  --      DATA            : 7/3/2006 09:03:55
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Função que converte uma competencia para uma competencia sendo retuzida de "n" meses
  -------------------------------------------------------------------------------------------------
  FUNCTION Sgpb0017(Dtmvvigencia   Prod_Crrtr.Ccompt_Prod%TYPE,
                    Intvqtmesanlse NUMBER) RETURN Prod_Crrtr.Ccompt_Prod%TYPE AS
    Var_Crotna VARCHAR2(8) := 'SGPB0017';
    Var_Retorno NUMBER;
  BEGIN
       --RETURN To_Number(To_Char(Add_Months(To_Date(Dtmvvigencia, 'yyyymm'), (Intvqtmesanlse * -1)), 'YYYYMM'));
        Var_Retorno := To_Number(To_Char(Add_Months(To_Date(Dtmvvigencia, 'yyyymm'), (Intvqtmesanlse * -1)), 'YYYYMM'));
        --caso a data seja maior que a data atual - subtrair ano - 1
        if to_date(Var_Retorno) > sysdate then
            Var_Retorno := To_Number(To_Char(Add_Months(Add_Months(To_Date(Dtmvvigencia, 'yyyymm'),-12), (Intvqtmesanlse * -1)), 'YYYYMM'));
        end if; 
        
        RETURN Var_Retorno;
        
  EXCEPTION
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao converter uma competencia para uma competencia reduzida de n meses.Competência:' ||
                             Dtmvvigencia ||' Quantidade de Meses: '||Intvqtmesanlse||' # '||SQLERRM, 1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0017;
 -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0001
  --      DATA            : 7/3/2006 09:03:55
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno do estado do canal
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0001(Chrrestado   OUT tpo_apurc_canal_vda.csit_apurc_canal%TYPE, -- Retorno do Estado
                     Intrcanal    IN Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE, -- Canal que deve ser avaliado
                     IntrTipoApurc IN Tpo_Apurc.Ctpo_Apurc%TYPE,
                     Intrvigencia IN Prod_Crrtr.Ccompt_Prod%TYPE -- Data para vigencia de ana
                     ) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0001';
  BEGIN
      SELECT tacv.Csit_Apurc_Canal inTO Chrrestado
      FROM tpo_apurc_canal_vda tacv
      join parm_info_campa pic
        on pic.ccanal_vda_segur = tacv.ccanal_vda_segur
       and pic.dinic_vgcia_parm = tacv.dinic_vgcia_parm
     WHERE tacv.Ccanal_Vda_Segur = Intrcanal
       and tacv.ctpo_apurc = IntrTipoApurc
       and last_day(to_date(Intrvigencia, 'YYYYMM'))
           between pic.dinic_vgcia_parm and nvl(pic.dfim_vgcia_parm, to_date(99991231, 'YYYYMMDD'));
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Erro por não retornar linha. Competência:' || Intrvigencia || ' canal: ' || Intrcanal ||
                             ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Erro por retornar com varias linhas. Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar se o canal esta ativo ou não.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0001;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0002
  --      DATA            : 7/3/2006 09:04:36
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a margem de contribuição minima para o corretor em um determindado canal
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0002(Dblrmargem   OUT Parm_Canal_Vda_Segur.Pmargm_Contb_Min%TYPE,
                     Intrcanal    IN Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE,
                     Intrvigencia IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0002';
  BEGIN
    SELECT Vs.Pmargm_Contb_Min
      INTO Dblrmargem
      FROM Parm_Canal_Vda_Segur Vs
     WHERE Vs.Ccanal_Vda_Segur = Intrcanal AND Vs.Dfim_Vgcia_Parm IS NULL;
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
                             Intrvigencia || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
                             Intrvigencia || ' # ' || SQLERRM,
                             1,
                             Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                  Var_Log_Erro,
                                  Pc_Util_01.Var_Log_Processo,
                                  NULL,
                                  NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar margem de contribuição mínima.Competência:' ||
                             Intrvigencia || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0002;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0003
  --      DATA            : 7/3/2006 09:05:00
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno da faixa correspondente a um corretor de um determinado canal
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0003(Intrfaixainicial OUT Parm_Canal_Vda_Segur. Cinic_Faixa_Crrtr%TYPE,
                     Intrfaixafinal   OUT Parm_Canal_Vda_Segur. Cfnal_Faixa_Crrtr%TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     Intrvigencia     IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0003';
  BEGIN
    SELECT Vs.Cinic_Faixa_Crrtr, Vs.Cfnal_Faixa_Crrtr
      INTO Intrfaixainicial, Intrfaixafinal
      FROM Parm_Canal_Vda_Segur Vs
     WHERE Vs.Ccanal_Vda_Segur = Intrcanal and VS.Dfim_Vgcia_Parm IS NULL;
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' ||
                             Intrvigencia || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
                             Intrvigencia || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL,  NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar faixa do corretor.Competência:' ||
                             Intrvigencia || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0003;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0003
  --      DATA            : 7/3/2006 09:05:00
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno da faixa correspondente a um corretor de um determinado canal
 -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0003(Intrfaixainicial OUT Parm_Canal_Vda_Segur. Cinic_Faixa_Crrtr%TYPE,
                     Intrfaixafinal   OUT Parm_Canal_Vda_Segur. Cfnal_Faixa_Crrtr%TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     IntrDia          IN date) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0003';
  BEGIN
    SELECT Vs.Cinic_Faixa_Crrtr, Vs.Cfnal_Faixa_Crrtr
      INTO Intrfaixainicial, Intrfaixafinal
      FROM Parm_Canal_Vda_Segur Vs
     WHERE Vs.Ccanal_Vda_Segur = Intrcanal AND Vs.Dfim_Vgcia_Parm IS NULL;
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || IntrDia || ' # ' || SQLERRM,
                             1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo,  NULL, NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || IntrDia || ' # ' || SQLERRM,
                             1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar faixa do corretor.Competência:' ||
                             IntrDia || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0003;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0004
  --      DATA            : 7/3/2006 09:05:19
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a meta minima para quantidade de apolises e valor minimo para ser elegivel no Plano de Bonus
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0004(Dblrvalmin        OUT Parm_Prod_Min_Crrtr. Vmin_Prod_Crrtr%TYPE,
                     Intrqtdmin        OUT Parm_Prod_Min_Crrtr. Qitem_Min_Prod_Crrtr%TYPE,
                     Intrcanal         IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     Intrvigencia      IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrramo          IN Parm_Prod_Min_Crrtr.Cgrp_Ramo_Plano%TYPE,
                     Chrrperiodicidade IN Parm_Prod_Min_Crrtr.Ctpo_Per%TYPE,
                     Chrrtppessoa      IN Parm_Prod_Min_Crrtr.Ctpo_Pssoa%TYPE) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0004';
  BEGIN
    SELECT Pm.Vmin_Prod_Crrtr, Pm.Qitem_Min_Prod_Crrtr
      INTO Dblrvalmin, Intrqtdmin
      FROM Parm_Prod_Min_Crrtr Pm
     WHERE Pm.Ccanal_Vda_Segur = Intrcanal
       AND Sgpb0016(Intrvigencia) BETWEEN Pm.Dinic_Vgcia_Parm AND
           Sgpb0031(Pm.Dfim_Vgcia_Parm)
       AND Cgrp_Ramo_Plano = Intrramo
       AND Ctpo_Per = Chrrperiodicidade
       AND (Ctpo_Pssoa = Chrrtppessoa OR
           (Ctpo_Pssoa IS NULL AND Chrrtppessoa IS NULL));
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Ramo: ' || Intrramo || ' Periodicidade: ' || Chrrperiodicidade || ' Tipo de Pessoa: ' ||
                             Chrrtppessoa || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Ramo: ' || Intrramo || ' Periodicidade: ' || Chrrperiodicidade || ' Tipo de Pessoa: ' ||
                             Chrrtppessoa || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar quantidade e valor minimo para as apolices.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal || ' Ramo: ' || Intrramo || ' Periodicidade: ' ||
                             Chrrperiodicidade || ' Tipo de Pessoa: ' || Chrrtppessoa || ' # ' || SQLERRM, 1,
                             Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0004;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0005
  --      DATA            : 7/3/2006 09:05:45
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno da quantidade de meses de aptidão para analise de seleção
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0005(Intrqtmesanlse OUT Parm_Per_Apurc_Canal. Qmes_Anlse%TYPE,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc%TYPE) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0005';
  BEGIN
    SELECT Pp.Qmes_Anlse
      INTO Intrqtmesanlse
      FROM Parm_Per_Apurc_Canal Pp
     WHERE Pp.Ccanal_Vda_Segur = Intrcanal
       AND Sgpb0016(Intrvigencia) BETWEEN Pp.Dinic_Vgcia_Parm AND
           Sgpb0031(Pp.Dfim_Vgcia_Parm)
       AND Pp.Ctpo_Apurc = Intrtpapurc;
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                'Execução correta ao retornar quantidade de meses para analise de seleção.',
                                Pc_Util_01.Var_Log_Processo, NULL, NULL);
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Tipo de Apuração: ' || Intrtpapurc || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' || Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Tipo de Apuração: ' || Intrtpapurc || ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar quantidade de meses para analise de seleção.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal || ' Tipo de Apuração: ' || Intrtpapurc || ' # ' ||
                             SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0005;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0006
  --      DATA            : 7/3/2006 09:06:23
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure para retorno o tempo minimo de relacionamento com o canal
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0006(Intrqttemprelcto OUT Parm_Canal_Vda_Segur. Qtempo_Min_Rlcto%TYPE,
                     Intrcanal        IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     Intrvigencia     IN Prod_Crrtr.Ccompt_Prod%TYPE) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0006';
  BEGIN
    SELECT Vs.Qtempo_Min_Rlcto -- tempo minimo de relacionamento
      INTO Intrqttemprelcto
      FROM Parm_Canal_Vda_Segur Vs
     WHERE Vs.Ccanal_Vda_Segur = Intrcanal AND Vs.Dfim_Vgcia_Parm IS NULL;
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, 'Execução correta ao retornar tempo minimo de relacionamento com o canal.',
                                Pc_Util_01.Var_Log_Processo, NULL, NULL);
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrvigencia || ' canal: ' || Intrcanal ||
                             ' # ' || SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal ||' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar tempo minimo de relacionamento com o canal.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal ||' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      RAISE;
  END Sgpb0006;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0007
  --      DATA            : 7/3/2006 09:07:51
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a quantidade de meses (intervalo) para que seja feita a apuração
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0007(Intrqtmesapurc OUT Parm_Per_Apurc_Canal.Qmes_Perdc_Apurc%TYPE,
                     Intrcanal      IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     Intrvigencia   IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrtpapurc    IN Tpo_Apurc.Ctpo_Apurc%TYPE) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0007';
  BEGIN
    SELECT Pp.Qmes_Perdc_Apurc
      INTO Intrqtmesapurc
      FROM Parm_Per_Apurc_Canal Pp
     WHERE Pp.Ccanal_Vda_Segur = Intrcanal
       AND Sgpb0016(Intrvigencia) BETWEEN Pp.Dinic_Vgcia_Parm AND
           Sgpb0031(Pp.Dfim_Vgcia_Parm)
       AND Pp.Ctpo_Apurc = Intrtpapurc;
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,'Execução correta ao retornar quantidade de meses para apuração.',
                                Pc_Util_01.Var_Log_Processo,NULL,NULL);
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:'||Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Tipo de Apuração: ' || Intrtpapurc || ' # ' ||SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Tipo de Apuração: ' || Intrtpapurc || ' # ' ||
                             SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar quantidade de meses para apuração.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal ||' Tipo de Apuração: ' || Intrtpapurc || ' # ' ||
                             SQLERRM, 1, Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0007;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPBSGPB0031
  --      DATA            : 13/03/06 15:18:40
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_BANCO_01.SQL
  --      OBJETIVO        : Definir qual é a data final de Vigencia
  -------------------------------------------------------------------------------------------------
  FUNCTION Sgpb0031(Intvvigencia IN DATE) RETURN DATE AS
    Var_Crotna VARCHAR2(8) := 'SGPB0031';
  BEGIN
  	RETURN Nvl(Intvvigencia, To_Date('99991231', 'YYYYMMDD'));
  EXCEPTION
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao definir a data final:' ||Intvvigencia || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0031;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0032
  --      DATA            : 14/03/06 09:05:44
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_BANCO_01.SQL
  --      OBJETIVO        : Deletar informações da tabela temporaria
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0032(Intrvigencia IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrcanal    IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE) AS
    Var_Crotna VARCHAR2(8) := 'SGPB0032';
  BEGIN
     UPDATE Crrtr c SET c.Cind_Crrtr_Selec = 0 WHERE c.Cind_Crrtr_Selec = 1; -- tira todo mundo de eleito
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -2292
      THEN
        Var_Log_Erro := Substr('CUIDADO AS INFORMAÇÔES DE APURAÇÂO JÁ ESTÂO SENDO UTILIZADAS:# ', 1, Pc_Util_01.Var_Tam_Msg_Erro);
        PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
      ELSE
        Var_Log_Erro := Substr('Erro ao deletar as informaçõesda tabela temporario:# ' ||
                               SQLERRM || ' Cod Erro ' || SQLCODE, 1, Pc_Util_01.Var_Tam_Msg_Erro);
        PR_GRAVA_MSG_LOG_CARGA(Var_Crotna, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
        RAISE;
      END IF;
  END Sgpb0032;
  PROCEDURE Sgpb0028(Var_Log_Erro_Ori VARCHAR2, Var_Crotna_Ori VARCHAR2)
  -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : SGPBSGPB0028
    --      DATA            : 24/03/06 18:25:23
    --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : inserir na tabela de Hístorico
    -------------------------------------------------------------------------------------------------
   AS
  BEGIN
    INSERT INTO Log_Erro_Impor (Clog_Erro_Impor,Iprocs_Impor,Derro_Impor,Rmsgem_Erro_Impor)
    VALUES
      ((SELECT Nvl(MAX(Clog_Erro_Impor), 0) + 1 FROM Log_Erro_Impor),
       Nvl(Var_Crotna_Ori, 'SGPB'),Current_Timestamp,Substr(Var_Log_Erro_Ori, 1, 1999));
  EXCEPTION
    WHEN OTHERS THEN
      Dbms_Output.Put_Line(Substr(Var_Crotna_Ori || SQLERRM, 1, 254));
  END Sgpb0028;

  FUNCTION Sgpb0068(Vprod           NUMBER,
                    Qprod           NUMBER,
                    Intrcompetencia Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
                    Ccrrtr          Prod_Crrtr.Ccrrtr%TYPE,
                    Cund_Prod       Prod_Crrtr.Cund_Prod%TYPE,
                    Intrqtmesanlse  Parm_Per_Apurc_Canal.Qmes_Anlse%TYPE)
    RETURN INTEGER
  -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : SGPB0068
    --      DATA            : 29/03/06 5:47:49 PM
    --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : averiguar se o corretor apresenta valores para poder ser eleito
    -------------------------------------------------------------------------------------------------
   IS
    Var_Crotna CONSTANT CHAR(8) := 'SGPB0068';
    Var_Log_Erro Pc_Util_01.Var_Log_Erro%TYPE;
    Resultado    INTEGER;
  BEGIN
    SELECT CASE
             	WHEN Vprod <= SUM(Po.Vprod_Crrtr) OR
                  			Qprod <= SUM(Po.Qtot_Item_Prod) THEN
              						1
             	ELSE
              						0
           		END
      INTO Resultado
      FROM Prod_Crrtr Po
     WHERE Po.Ccrrtr = Ccrrtr
       AND Po.Cund_Prod = Cund_Prod
       AND Po.Ctpo_Comis = 'CN'
       AND Po.Ccompt_Prod BETWEEN
           Pc_Util_01.Sgpb0017(Sgpb0016(Intrcompetencia),
                               Intrqtmesanlse - 1) AND Intrcompetencia
       AND Po.Cgrp_Ramo_Plano = 120
     GROUP BY Po.Ccrrtr,
              Po.Cund_Prod;
    RETURN Resultado;
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                'Execução correta ao Conferir se o corretor se apresenta na faixa durante uma determinada quantidade de meses.',
                                Pc_Util_01.Var_Log_Processo,NULL,NULL);
  EXCEPTION
    WHEN No_Data_Found OR
         Too_Many_Rows THEN
      					RETURN 0;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao Conferir se o corretor se apresenta na faixa durante uma determinada quantidade de meses. Competência:' ||
                             Intrcompetencia || ' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      RAISE;
  END Sgpb0068;
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0069
  --      DATA            : 7/3/2006 09:07:51
  --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      PROGRAMA        : PC_UTIL_01.SQL
  --      OBJETIVO        : Procedure que retornará a quantidade de meses (intervalo) para que seja feita o pagamento
  -------------------------------------------------------------------------------------------------
  PROCEDURE Sgpb0069(Intrqtmespgto OUT Parm_Per_Apurc_Canal.Qmes_Perdc_Apurc%TYPE,
                     Intrcanal     IN Canal_Vda_Segur. Ccanal_Vda_Segur%TYPE,
                     Intrvigencia  IN Prod_Crrtr.Ccompt_Prod%TYPE,
                     Intrtpapurc   IN Tpo_Apurc.Ctpo_Apurc%TYPE) IS
    Var_Crotna VARCHAR2(8) := 'SGPB0007';
  BEGIN
    SELECT Pp.Qmes_Perdc_Pgto
      INTO Intrqtmespgto
      FROM Parm_Per_Apurc_Canal Pp
     WHERE Pp.Ccanal_Vda_Segur = Intrcanal
       AND Sgpb0016(Intrvigencia) BETWEEN Pp.Dinic_Vgcia_Parm AND
           Sgpb0031(Pp.Dfim_Vgcia_Parm)
       AND Pp.Ctpo_Apurc = Intrtpapurc;
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                'Execução correta ao retornar quantidade de meses para apuração.',
                                Pc_Util_01.Var_Log_Processo,NULL,NULL);
  EXCEPTION
    WHEN No_Data_Found THEN
      Var_Log_Erro := Substr('Retorno de nenhum valor.Competência:' || Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Tipo de Apuração: ' || Intrtpapurc || ' # ' ||
                             SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      RAISE;
    WHEN Too_Many_Rows THEN
      Var_Log_Erro := Substr('Retorno de mais de um valor.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal ||' Tipo de Apuração: ' || Intrtpapurc || ' # ' ||
                             SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      RAISE;
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao retornar quantidade de meses para apuração.Competência:' ||
                             Intrvigencia || ' canal: ' || Intrcanal ||
                             ' Tipo de Apuração: ' || Intrtpapurc || ' # ' ||SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
      RAISE;
  END Sgpb0069;
  PROCEDURE Sgpb0079(Intrcontacredora  OUT Parm_Canal_Vda_Segur.Ccta_Ctbil_Credr%TYPE,
                     Intrcontadevedora OUT Parm_Canal_Vda_Segur.Ccta_Ctbil_Dvdor%TYPE,
                     Intrvigencia      Margm_Contb_Crrtr.Ccompt_Margm%TYPE,
                     Intrcanal         Canal_Vda_Segur.Ccanal_Vda_Segur%TYPE)
  -------------------------------------------------------------------------------------------------
    --      BRADESCO SEGUROS S.A.
    --      PROCEDURE       : SGPB0079
    --      DATA            : 30/05/2006 11:51:09 AM
    --      AUTOR           : Mariano Aloi - ANALISE E DESENVOLVIMENTO DE SISTEMAS
    --      OBJETIVO        : Buscar contas para movimento contabil, por canal
    -------------------------------------------------------------------------------------------------
   IS
    Var_Crotna CONSTANT CHAR(8) := 'SGPB0079';
    Var_Log_Erro Pc_Util_01.Var_Log_Erro%TYPE;
  BEGIN
    SELECT Ccta_Ctbil_Credr, Ccta_Ctbil_Dvdor
      INTO Intrcontacredora, Intrcontadevedora
      FROM Parm_Canal_Vda_Segur Vs
     WHERE Vs.Ccanal_Vda_Segur = Intrcanal AND Vs.Dfim_Vgcia_Parm IS NULL;
  EXCEPTION
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao buscar informações de contas de credito e debito do canal ' ||
                             Intrcanal || '. Competência:' || Intrvigencia ||' # ' || SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo, NULL, NULL);
      RAISE;
  END Sgpb0079;
END Pc_Util_01;
/

