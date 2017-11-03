CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0034
(
  tipo               NUMBER,
  intQmes_perdc_pgto parm_per_apurc_canal.qmes_perdc_pgto%TYPE,
  intrCompetencia    Prod_Crrtr.CCOMPT_PROD %TYPE,
  intCanal           canal_vda_segur.ccanal_vda_segur%type
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0034
  --      DATA            : 10/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Sub-Procedure de SGPB0034. Insert em tabela temporaria
  --      ALTERA¿¿ES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  intCompTemp Prod_Crrtr.CCOMPT_PROD %TYPE;
BEGIN
  --
  --
  intCompTemp := PC_UTIL_01.SGPB0017(intrCompetencia,
                                          intQmes_perdc_pgto - 1); --OLHANDO PARA TR¿S
  --
  --
  UPDATE apurc_prod_crrtr
     SET cind_apurc_selec = 1
   WHERE ( --
          ccanal_vda_segur, --
          ctpo_apurc, --
          ccompt_apurc, --
          cgrp_ramo_plano, --
          ccompt_prod, --
          ctpo_comis, --
          ccrrtr, cund_prod --
         ) --
         IN --
         ( --
          SELECT apc.ccanal_vda_segur,
                  apc.ctpo_apurc,
                  apc.ccompt_apurc,
                  apc.cgrp_ramo_plano,
                  apc.ccompt_prod,
                  apc.ctpo_comis,
                  apc.ccrrtr,
                  apc.cund_prod
            FROM apurc_prod_crrtr APC
           WHERE apc.ctpo_apurc = tipo
             AND APC.CCOMPT_APURC BETWEEN intCompTemp AND intrCompetencia
             AND APC.ccanal_vda_segur = intCanal
             AND APC.CSIT_APURC in ('AP','BG','LM','LG','PR','PL')
             AND NOT EXISTS (SELECT 1
                    FROM papel_apurc_pgto PAP
                   WHERE PAP.ccanal_vda_segur = APC.ccanal_vda_segur
                     AND PAP.ctpo_apurc = APC.ctpo_apurc
                     AND PAP.ccompt_apurc = APC.ccompt_apurc
                     AND PAP.cgrp_ramo_plano = APC.cgrp_ramo_plano
                     AND PAP.ccompt_prod = APC.ccompt_prod
                     AND PAP.ctpo_comis = APC.ctpo_comis
                     AND PAP.ccrrtr = APC.ccrrtr
                     AND PAP.cund_prod = APC.cund_prod
                     AND PAP.CINDCD_PAPEL = 1 /*ELEICAO*/
                  ) --
          );
END SGPB0034;
/

