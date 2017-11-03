CREATE OR REPLACE PROCEDURE SGPB_PROC.sgpb0141
(
  IntrDtExecucao  Parm_Canal_Vda_Segur.Dinic_Vgcia_Parm %TYPE
) IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : sgpb0141
  --      DATA            : 23/01/2007
  --      AUTOR           : Vinícius Faria - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para suspender automaticamente o canal.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
  Var_Log_Erro Pc_Util_01.Var_Log_Erro %TYPE;
  Var_Crotna   VARCHAR2(8) := 'sgpb0141';
  Var_Qmes_Duracao parm_canal_vda_segur.qmes_durac_campa %type;

  -------------------------------------------------------------------------------------------------
  /*Recupera a duração padrão em meses da campanha*/
  -------------------------------------------------------------------------------------------------
  procedure getDuracaoCanal(canal in canal_vda_segur.ccanal_vda_segur %type,
             dataInicio in parm_canal_vda_segur.dinic_vgcia_parm %type,
             qmesDuracao out Parm_Canal_Vda_Segur.Qmes_Durac_Campa %TYPE)is
  BEGIN
       SELECT T.QMES_DURAC_CAMPA INTO qmesDuracao
       FROM PARM_CANAL_VDA_SEGUR T
       WHERE T.CCANAL_VDA_SEGUR = canal
         AND T.DINIC_VGCIA_PARM = dataInicio;
  END getDuracaoCanal;
  -------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------
BEGIN
  --
  --
  for c in (SELECT cvs.ccanal_vda_segur, pic.dinic_vgcia_parm
    FROM parm_info_campa pic, canal_vda_segur cvs
   WHERE cvs.ccanal_vda_segur = pic.ccanal_vda_segur
     AND pic.dfim_vgcia_parm is null)loop

    --
    --
    getDuracaoCanal(C.ccanal_vda_segur, C.dinic_vgcia_parm,Var_Qmes_Duracao);
    --
    --
    if (TO_NUMBER(to_char(add_months(C.dinic_vgcia_parm, Var_Qmes_Duracao), 'YYYYMM')) >= TO_NUMBER(to_char(IntrDtExecucao, 'YYYYMM'))) then

        UPDATE tpo_apurc_canal_vda tpo
           SET tpo.csit_apurc_canal = 'S', /*SUSPENDER*/
               tpo.dult_alt = sysdate,
               tpo.cresp_ult_alt = PC_UTIL_01.Usuario_Responsavel
         WHERE tpo.ccanal_vda_segur = C.ccanal_vda_segur
           AND tpo.dinic_vgcia_parm = c.dinic_vgcia_parm;
      END IF;

  end loop;

  --
  --
EXCEPTION
  WHEN No_Data_Found THEN
    Var_Log_Erro := Substr('Retorno de nenhum valor. Data de Execução:' || IntrDtExecucao || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN Too_Many_Rows THEN
    Var_Log_Erro := Substr('Retorno de mais de um valor. Data de Execução:' || IntrDtExecucao || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Erro ao suspender automaticamente o canal. Data de Execução:' ||
                           IntrDtExecucao || ' # ' || SQLERRM,
                           1,
                           Pc_Util_01.Var_Tam_Msg_Erro);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,
                                Var_Log_Erro,
                                Pc_Util_01.Var_Log_Processo,
                                NULL,
                                NULL);
    RAISE;
END sgpb0141;
/

