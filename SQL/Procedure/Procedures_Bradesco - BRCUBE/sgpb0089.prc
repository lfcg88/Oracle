CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0089
(
  intCodCanal_vda_segur parm_canal_vda_segur.ccanal_vda_segur %TYPE
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0089
  --      DATA            : 16/03/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure que faz update em todas as apurações para serem liberadas por encerramento/suspensao
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  --
  Intqmes_Perdc_Pgto     Parm_Per_Apurc_Canal.Qmes_Perdc_Pgto%TYPE;
  INTCOMP number(6);
  intLoop integer;
  Intcomptemp      Prod_Crrtr.Ccompt_Prod %TYPE;
  --
  --
  PROCEDURE deletaDeixouProdMesExtraBanco(intQtdMes integer) IS
  BEGIN
    UPDATE apurc_prod_crrtr a
       SET cind_apurc_selec = 0
     WHERE cind_apurc_selec = 1
       AND a.Ctpo_Apurc = pc_util_01.NORMAL
       AND ( --
            ccrrtr, --
            cund_prod --
           ) --
           IN --
           ( --
            SELECT apc.ccrrtr,
                    apc.cund_prod
              FROM apurc_prod_crrtr apc
              JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                          AND c.cund_prod = apc.cund_prod
             WHERE apc.cind_apurc_selec = 1
               AND ( --
                    c.ccpf_cnpj_base, --
                    c.ctpo_pssoa --
                   ) --
                   IN --
                   ( --
                    SELECT tap.ccpf_cnpj_base,
                            tap.ctpo_pssoa
                      FROM (SELECT apc.ccompt_apurc,
                                    c.ccpf_cnpj_base,
                                    c.ctpo_pssoa
                               FROM apurc_prod_crrtr apc
                               JOIN crrtr c ON c.ccrrtr = apc.ccrrtr
                                           AND c.cund_prod = apc.cund_prod
                              WHERE APC.CIND_APURC_SELEC = 1
                              GROUP BY apc.ccompt_apurc,
                                       c.ccpf_cnpj_base,
                                       c.ctpo_pssoa) tap
                     GROUP BY tap.ccpf_cnpj_base,
                               tap.ctpo_pssoa
                    HAVING COUNT(ccpf_cnpj_base) < intQtdMes) --
            );
  END deletaDeixouProdMesExtraBanco;
  --
  --
  PROCEDURE deletaDeixouProdMesBanco(intQtdMes integer) IS
  BEGIN
      UPDATE Apurc_Prod_Crrtr
       SET Cind_Apurc_Selec = 0
     WHERE Cind_Apurc_Selec = 1
       AND ( --
            Ccrrtr, --
            Cund_Prod --
           ) --
           IN --
           ( --
            SELECT Tap.Ccrrtr,
                    Tap.Cund_Prod
              FROM (SELECT Apc.Ccompt_Apurc,
                            Apc.Ccrrtr,
                            Apc.Cund_Prod
                       FROM Apurc_Prod_Crrtr Apc
                      WHERE Apc.Cind_Apurc_Selec = 1
                      GROUP BY Apc.Ccompt_Apurc,
                               Apc.Ccrrtr,
                               Apc.Cund_Prod) Tap
             GROUP BY Tap.Ccrrtr,
                       Tap.Cund_Prod
            HAVING COUNT(Ccrrtr) < (intQtdMes) --
            );
  end deletaDeixouProdMesBanco;
BEGIN
  --
  --SETA O STATUS PARA LS QUE SIGNIFICA QUE SERÁ LIBERADO POR ENCERRAMENTO OU SUSPENSÃO
  UPDATE apurc_prod_crrtr
     SET CSIT_APURC = 'LS'
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
           WHERE APC.ccanal_vda_segur = intCodCanal_vda_segur
             AND APC.CSIT_APURC IN ('LM','BG') --
          );
  --
  --
  --
  --Competencia atual (parte-se do principio que o encerramento/cancelamento ocorrerá apenas depois da rotina pagamento)
  INTCOMP := PC_UTIL_01.SGPB0017(SYSDATE, 0);
  --
  --busca periodicidade do pagamento
  SELECT Qmes_Perdc_Pgto
    INTO Intqmes_Perdc_Pgto
    FROM Parm_Per_Apurc_Canal Ppac
   WHERE Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
     AND Ppac.Ctpo_Apurc = Pc_Util_01.Normal
     AND Sgpb0016(INTCOMP) BETWEEN Ppac.Dinic_Vgcia_Parm AND
         Nvl(Ppac.Dfim_Vgcia_Parm,
             To_Date('99991231',
                     'YYYYMMDD'));
  --
  -- variavel que diminui meses da competencia
  -- ex.: o pagamento paga para quem tem 3 meses consecutivos ou seja 200601 ate 200603, passando 2 para a Sgpb0017;
  -- porem temos que liberar quem tem 2 seguidos e quem tem 1, no caso do parametro ser 3 (mas pode ser 10) :(
  -- entao por isso fazemos o loop começando com -2.
  --
  intLoop := Intqmes_Perdc_Pgto - 2;  /*-1 a sgpb0025 ja faz, aqui precisamos ir de -2 até q chegue a 0*/
  --
  -- Zera a tabela
  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
  --
  --
  /*PEGA A COMPETENCIA ATUAL*/
  while intLoop >= 0 loop
                  --busca a data inferior do between
                  Intcomptemp := Pc_Util_01.Sgpb0017(INTCOMP, intLoop); --OLHANDO PARA TRÁS
                  --
                  --marca as apurações que se enquadram
                  UPDATE Apurc_Prod_Crrtr
                     SET Cind_Apurc_Selec = 1
                   WHERE (Ccanal_Vda_Segur, --
                          Ctpo_Apurc, --
                          Ccompt_Apurc, --
                          Cgrp_Ramo_Plano, --
                          Ccompt_Prod, --
                          Ctpo_Comis, --
                          Ccrrtr, --
                          Cund_Prod --
                         ) --
                         IN --
                         ( --
                          SELECT Apc.Ccanal_Vda_Segur,
                                  Apc.Ctpo_Apurc,
                                  Apc.Ccompt_Apurc,
                                  Apc.Cgrp_Ramo_Plano,
                                  Apc.Ccompt_Prod,
                                  Apc.Ctpo_Comis,
                                  Apc.Ccrrtr,
                                  Apc.Cund_Prod
                            FROM Apurc_Prod_Crrtr Apc
                           WHERE Apc.Ccompt_Apurc BETWEEN Intcomptemp AND INTCOMP
                             AND Apc.Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
                             AND Apc.Csit_Apurc IN ('AP', 'BG', 'LM', 'LG', 'PR', 'PL')
                             AND NOT EXISTS (SELECT 1
                                    FROM Papel_Apurc_Pgto Pap
                                   WHERE Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                                     AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
                                     AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
                                     AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                     AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
                                     AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
                                     AND Pap.Ccrrtr = Apc.Ccrrtr
                                     AND Pap.Cund_Prod = Apc.Cund_Prod
                                     AND Pap.Cindcd_Papel = 1 /*ELEICAO*/
                                  ));
                  --
                  -- Exclui quem deixou de produzir todos os meses
                  if (intCodCanal_vda_segur = pc_util_01.Banco or intCodCanal_vda_segur = pc_util_01.Finasa ) then
                     deletaDeixouProdMesBanco(intLoop+1);
                  else
                     deletaDeixouProdMesExtraBanco(intLoop+1);
                  end if;

                  --libera a apuração.. (note como o flag é LS da proxima vez a mesma não entrará no select)
                  UPDATE apurc_prod_crrtr
                     SET CSIT_APURC = 'LS'
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
                           WHERE APC.ccanal_vda_segur = intCodCanal_vda_segur
                             AND apc.Cind_Apurc_Selec = 1 --
                          );
                  --zera
                  UPDATE apurc_prod_crrtr SET cind_apurc_selec = 0 WHERE cind_apurc_selec = 1;
                  --decrementa
                  intLoop := intLoop - 1;
  end loop;
END SGPB0089;
/

