CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0181
(
  curvrelat  OUT SYS_REFCURSOR,
  pcanal     in canal_vda_segur.ccanal_vda_segur %TYPE,
  pTrimestre in number,
  pAno       in number
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB0181
  --      data            : 08/05/07
  --      autor           : Vinícius Faria - analise e desenvolvimento de sistemas
  --      objetivo        : Retorna a margem mínima de contribuição de um canal
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -
  -------------------------------------------------------------------------------------------------
 IS
 --
   ultimoMes  number(6);
 --
   VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';

BEGIN

   --
    If pTrimestre = 1 then
      -- JANEIRO / FEVEREIRO / MARCO
      ultimoMes := to_number(pAno || '03');
    Elsif pTrimestre = 2 then
      -- ABRIL / MAIO / JUNHO
      ultimoMes := to_number(pAno || '06');
    Elsif pTrimestre = 3 then
      -- JULHO / AGOSTO / SETEMBRO
      ultimoMes := to_number(pAno || '09');
    Elsif pTrimestre = 4 then
      -- OUTUBRO / NOVEMBRO / DEZEMBRO
      ultimoMes := to_number(pAno || '12');
    End If;

  --
  OPEN curvrelat FOR
  --


SELECT 'valorMargem',
       pcvs.pmargm_contb_min,
       'competenciaInicial',
       ultimoMes,
       'competenciaFinal',
       To_Number(To_Char(Add_Months(To_Date(ultimoMes, 'yyyymm'), -11), 'YYYYMM'))
       --
  FROM parm_canal_vda_segur pcvs
  --
 where LAST_DAY(TO_DATE(ultimoMes, 'YYYYMM')) between pcvs.dinic_vgcia_parm and nvl(pcvs.dfim_vgcia_parm,to_date(99991231, 'YYYYMMDD'))
   AND pcvs.ccanal_vda_segur = pcanal;
  --
  EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' # ' || SQLERRM,
                          1,
                          PC_UTIL_01.VAR_TAM_MSG_ERRO);

    PR_GRAVA_MSG_LOG_CARGA('SGPB0179',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

END SGPB0181;
/

