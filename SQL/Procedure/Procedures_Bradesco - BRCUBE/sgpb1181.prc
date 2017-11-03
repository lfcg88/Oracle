CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB1181
(
  curvrelat  OUT SYS_REFCURSOR,
  pcanal     IN canal_vda_segur.ccanal_vda_segur %TYPE,
  pTrimestre IN NUMBER,
  pAno       IN NUMBER
)
-------------------------------------------------------------------------------------------------
  --      bradesco seguros s.a.
  --      procedure       : SGPB1181
  --      NEGOCIO         : SGPB PLANO BONUS INTERNET - SITE CORRETOR
  --      data            : 20/09/2007
  --      autor           : ALEXANDRE CYSNE ESTEVES
  --      objetivo        : Retorna a margem mínima de contribuição de um canal - 2º CAMPANHA.
  --      alterações      :
  --                data  : -
  --                autor : -
  --                obs   : -?????????? PROCEDIMENTO COM PENDENCIA DE DEFINICAO ????????????????
  -------------------------------------------------------------------------------------------------  
 IS
 --
   ultimoMes  number(6);
 --
   VAR_LOG_ERRO          VARCHAR2(1000);
   chrLocalErro          VARCHAR2(2) := '00';

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
        -- O ANO DE 2007 ESTA HARD-CODE PARA QUE NO DE 2008
        -- ELE BUSQUE NA TABELA RESUMO O TRIMESTRE DO INICIO
        -- DA CAMPNHA QUE FOI EM 2007
      ultimoMes := to_number(2007 || '12');
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
 --where LAST_DAY(TO_DATE(ultimoMes, 'YYYYMM')) between pcvs.dinic_vgcia_parm and nvl(pcvs.dfim_vgcia_parm,to_date(99991231, 'YYYYMMDD'))
 where pcvs.dinic_vgcia_parm = TO_DATE(20071001,'YYYYMMDD')
 --where pcvs.dinic_vgcia_parm = TO_DATE(20060101,'YYYYMMDD')
   
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

    PR_GRAVA_MSG_LOG_CARGA('SGPB1181',
                               var_log_erro,
                               pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);

END SGPB1181;
/

