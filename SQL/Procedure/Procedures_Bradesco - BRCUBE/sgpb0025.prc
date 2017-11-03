CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0025
(
  Intrcompetencia        Prod_Crrtr.Ccompt_Prod %TYPE,
  Intcodcanal_Vda_Segur  Parm_Canal_Vda_Segur.Ccanal_Vda_Segur %TYPE,
  Chrnomerotinascheduler VARCHAR2 := 'SGPB0025'
)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0025
  --      DATA            : 10/3/2006
  --      AUTOR           : Victor H. Bilouro - ANALISE E DESENVOLVIMENTO DE SISTEMAS
  --      OBJETIVO        : Procedure para realizar a liberação automatica de apurações que ultrapassem o minimo para tal
  --      ALTERAÇÕES      : obs: 1) Aparentemente essa procedure é obsoleta. 
  --					         2) Essa procedure não existe em producao. 
  --							 Ass. Wassily 07/08/2007
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  /*controle de procedure*/
  Var_Log_Erro VARCHAR2(1000);
  Chrlocalerro VARCHAR2(10) := '00';
  Intqmes_Perdc_Pgto     Parm_Per_Apurc_Canal.Qmes_Perdc_Pgto%TYPE;
  Intproxcodigopgtocrrtr Pgto_Bonus_Crrtr.Cpgto_Bonus%TYPE;
  Intvmin_Librc_Pgto     Parm_Canal_Vda_Segur.Vmin_Librc_Pgto%TYPE;
  Intcodmaiorcrrtr Crrtr.Ccrrtr%TYPE;
  Intcomptemp      Prod_Crrtr.Ccompt_Prod %TYPE;
BEGIN
  Chrlocalerro := 01;
  --  Informa ao scheduler o começo da procedure
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,708,'PC');
  COMMIT;
  Chrlocalerro := 02;
  -- Zera a tabela temporária
  UPDATE Apurc_Prod_Crrtr SET Cind_Apurc_Selec = 0 WHERE Cind_Apurc_Selec = 1;
  Chrlocalerro := 05;
  --  busca de quanto em quanto tempo paga-se para o canal
  SELECT Qmes_Perdc_Pgto
    	INTO Intqmes_Perdc_Pgto
    	FROM Parm_Per_Apurc_Canal Ppac
   		WHERE Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
     	AND Ppac.Ctpo_Apurc = Pc_Util_01.Normal
     	AND Sgpb0016(Intrcompetencia) BETWEEN Ppac.Dinic_Vgcia_Parm AND Nvl(Ppac.Dfim_Vgcia_Parm,To_Date('99991231','YYYYMMDD'));
  Chrlocalerro := 06;
  --  busca o minimo para liberar o pagamento para o canal
  SELECT Pcvs.Vmin_Librc_Pgto
    	INTO Intvmin_Librc_Pgto
    	FROM Parm_Canal_Vda_Segur Pcvs
   		WHERE Pcvs.Ccanal_Vda_Segur = Intcodcanal_Vda_Segur
     	AND Sgpb0016(Intrcompetencia) BETWEEN Pcvs.Dinic_Vgcia_Parm AND Nvl(Pcvs.Dfim_Vgcia_Parm,To_Date('99991231','YYYYMMDD'));
  Chrlocalerro := 07;
  Intcomptemp := Pc_Util_01.Sgpb0017(Intrcompetencia,Intqmes_Perdc_Pgto - 1); --OLHANDO PARA TRÁS
  Chrlocalerro := 08;
  --insere na temporaria todos os registros selecionados para trabalho
  UPDATE Apurc_Prod_Crrtr
     SET Cind_Apurc_Selec = 1
   WHERE (Ccanal_Vda_Segur, Ctpo_Apurc, Ccompt_Apurc, Cgrp_Ramo_Plano, Ccompt_Prod, Ctpo_Comis, Ccrrtr, Cund_Prod 
         ) IN (
          SELECT Apc.Ccanal_Vda_Segur, Apc.Ctpo_Apurc, Apc.Ccompt_Apurc, Apc.Cgrp_Ramo_Plano, Apc.Ccompt_Prod, Apc.Ctpo_Comis,
                  Apc.Ccrrtr, Apc.Cund_Prod
            		FROM Apurc_Prod_Crrtr Apc
           			WHERE Apc.Ccompt_Apurc BETWEEN Intcomptemp AND Intrcompetencia
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
  Chrlocalerro := 9.1;
  -- insere registros que já estejam liberados para pagamento porem abaixo do minimo. NORMAL
  Sgpb0035(Pc_Util_01.Normal, Intqmes_Perdc_Pgto, Intrcompetencia, Pc_Util_01.Banco);
  Chrlocalerro := 9.2;
  -- insere registros que já estejam liberados para pagamento porem abaixo do minimo. EXTRA
  Sgpb0035(Pc_Util_01.Extra, Intqmes_Perdc_Pgto, Intrcompetencia, Pc_Util_01.Banco);
  Chrlocalerro := 10;
  FOR c IN (SELECT c.Ccpf_Cnpj_Base,
                   c.Ctpo_Pssoa,
                   CASE
                     WHEN SUM(Pc.Vprod_Crrtr * (Apc.Pbonus_Apurc / 100)) >= Intvmin_Librc_Pgto THEN
                      'PG' /*TRUE*/
                     ELSE
                      'LM' /*FALSE*/
                   END AS Novo_Status
              FROM Apurc_Prod_Crrtr Apc
              JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                          AND c.Cund_Prod = Apc.Cund_Prod
              JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                AND Pc.Cund_Prod = Apc.Cund_Prod
                                AND Pc.Ccrrtr = Apc.Ccrrtr
                                AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
                                AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
              LEFT JOIN Papel_Apurc_Pgto Pap ON Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                                            AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
                                            AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
                                            AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                            AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
                                            AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
                                            AND Pap.Ccrrtr = Apc.Ccrrtr
                                            AND Pap.Cund_Prod = Apc.Cund_Prod
                                            AND Pap.Cindcd_Papel = 0
             WHERE Apc.Cind_Apurc_Selec = 1
               AND Pap.Ccrrtr IS NULL /* só soma no total e altera situacao de quem não foi pago ainda*/
             GROUP BY c.Ccpf_Cnpj_Base,
                      c.Ctpo_Pssoa) LOOP
    -- 'AP','BG','LM','LG' => vira PG se for maior que minimo
    -- 'AP' => vira LM se for menor que minimo
    Chrlocalerro := 11;
    UPDATE Apurc_Prod_Crrtr Tt
       SET Csit_Apurc = c.Novo_Status
     WHERE (c.Novo_Status = 'PG' OR Tt.Csit_Apurc = 'AP')
       AND (Ccompt_Apurc, --
            Ccanal_Vda_Segur, --
            Cgrp_Ramo_Plano, --
            Ccompt_Prod, --
            Ctpo_Comis, --
            Ctpo_Apurc, --
            Ccrrtr, --
            Cund_Prod --
           ) --
           IN --
           ( --
            SELECT Apc.Ccompt_Apurc,
                    Apc.Ccanal_Vda_Segur,
                    Apc.Cgrp_Ramo_Plano,
                    Apc.Ccompt_Prod,
                    Apc.Ctpo_Comis,
                    Apc.Ctpo_Apurc,
                    Apc.Ccrrtr,
                    Apc.Cund_Prod
              FROM Apurc_Prod_Crrtr Apc
              JOIN Crrtr Cc ON Cc.Ccrrtr = Apc.Ccrrtr
                           AND Cc.Cund_Prod = Apc.Cund_Prod
             WHERE Apc.Cind_Apurc_Selec = 1
               AND Cc.Ccpf_Cnpj_Base = c.Ccpf_Cnpj_Base
               AND Cc.Ctpo_Pssoa = c.Ctpo_Pssoa --
            );
  END LOOP;
  Chrlocalerro := 12;
  -- Deleta quem ta abaixo do minimo da temp
  UPDATE Apurc_Prod_Crrtr
     SET Cind_Apurc_Selec = 0
   WHERE Cind_Apurc_Selec = 1
     AND ( --
          Ccrrtr, --
          Cund_Prod --
         ) --
         IN --
         ( --
          SELECT Apc.Ccrrtr,
                  Apc.Cund_Prod
            FROM Apurc_Prod_Crrtr Apc
            JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                        AND c.Cund_Prod = Apc.Cund_Prod
           WHERE Apc.Cind_Apurc_Selec = 1
             AND ( --
                  c.Ccpf_Cnpj_Base, --
                  c.Ctpo_Pssoa --
                 ) --
                 IN (SELECT c.Ccpf_Cnpj_Base,
                            c.Ctpo_Pssoa
                       FROM Apurc_Prod_Crrtr Apc
                       JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                                   AND c.Cund_Prod = Apc.Cund_Prod
                       JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                         AND Pc.Cund_Prod = Apc.Cund_Prod
                                         AND Pc.Ccrrtr = Apc.Ccrrtr
                                         AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
                                         AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
                       LEFT JOIN Papel_Apurc_Pgto Pap ON Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                                                     AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
                                                     AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
                                                     AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                                     AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
                                                     AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
                                                     AND Pap.Ccrrtr = Apc.Ccrrtr
                                                     AND Pap.Cund_Prod = Apc.Cund_Prod
                                                     AND Pap.Cindcd_Papel = 0
                      WHERE Pap.Ccrrtr IS NULL /* só soma no total e altera situacao de quem não foi pago ainda*/
                        AND Apc.Cind_Apurc_Selec = 1
                      GROUP BY c.Ccpf_Cnpj_Base,
                               c.Ctpo_Pssoa
                     HAVING SUM(Pc.Vprod_Crrtr * (Apc.Pbonus_Apurc / 100)) < Intvmin_Librc_Pgto) --
          );
  Chrlocalerro := 13;
  -- Pega o próximo registro a ser inserido
  SELECT Nvl(MAX(Cpgto_Bonus),0) + 1 INTO Intproxcodigopgtocrrtr
    			FROM Pgto_Bonus_Crrtr;
  Chrlocalerro := 14;
  -- Insere os registros na tabela de pagamento
  FOR Ca IN (SELECT c.Ctpo_Pssoa,
                    c.Ccpf_Cnpj_Base,
                    SUM(CASE
                          WHEN Pap.Ccrrtr IS NULL THEN
                           Pc.Vprod_Crrtr * (Apc.Pbonus_Apurc / 100)
                          ELSE
                           0
                        END) AS Total,
                    SUM(CASE
                          WHEN ((pap.ccrrtr IS NULL) AND (pc.vprod_crrtr > 0)) THEN
                           abs(pc.vprod_crrtr * (apc.pbonus_apurc / 100))
                          ELSE
                           0
                        END) AS totalModulo,/*rateio*/
                    SUM(CASE
                          WHEN ((pap.ccrrtr IS NULL) AND (pc.vprod_crrtr < 0)) THEN
                           abs(pc.vprod_crrtr * (apc.pbonus_apurc / 100))
                          ELSE
                           0
                        END) AS totalNegativo /*rateio*/
               FROM Apurc_Prod_Crrtr Apc
               JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                           AND c.Cund_Prod = Apc.Cund_Prod
               JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                 AND Pc.Cund_Prod = Apc.Cund_Prod
                                 AND Pc.Ccrrtr = Apc.Ccrrtr
                                 AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
                                 AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
               LEFT JOIN Papel_Apurc_Pgto Pap ON Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                                             AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
                                             AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
                                             AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                             AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
                                             AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
                                             AND Pap.Ccrrtr = Apc.Ccrrtr
                                             AND Pap.Cund_Prod = Apc.Cund_Prod
                                             AND Pap.Cindcd_Papel = 0
              WHERE Apc.Cind_Apurc_Selec = 1
              GROUP BY c.Ccpf_Cnpj_Base,
                       c.Ctpo_Pssoa) LOOP
    Chrlocalerro := 15;
    INSERT INTO Pgto_Bonus_Crrtr
      (Cpgto_Bonus,
       Vpgto_Tot,
       Ctpo_Pssoa,
       Ccpf_Cnpj_Base,
       Ccompt_Pgto,
       Ctpo_Pgto,
       Cind_Arq_Expor)
    VALUES
      (Intproxcodigopgtocrrtr,
       Ca.Total,
       Ca.Ctpo_Pssoa,
       Ca.Ccpf_Cnpj_Base,
       Intrcompetencia,
       1,
       0);
    Chrlocalerro := 16;
    -- Insere os registros na tabela de historico-distribuicao-pagamento-bonus
    FOR Caint IN (SELECT c.Ctpo_Pssoa,
                         c.Ccpf_Cnpj_Base,
                         Apc.Cund_Prod,
                         SUM(CASE
                               WHEN Pap.Ccrrtr IS NULL THEN
                                Pc.Vprod_Crrtr * (Apc.Pbonus_Apurc / 100)
                               ELSE
                                0
                             END) AS Total
                    FROM Apurc_Prod_Crrtr Apc
                    JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                                AND c.Cund_Prod = Apc.Cund_Prod
                    JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                      AND Pc.Cund_Prod = Apc.Cund_Prod
                                      AND Pc.Ccrrtr = Apc.Ccrrtr
                                      AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
                                      AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
                    LEFT JOIN Papel_Apurc_Pgto Pap ON Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                                                  AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
                                                  AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
                                                  AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                                  AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
                                                  AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
                                                  AND Pap.Ccrrtr = Apc.Ccrrtr
                                                  AND Pap.Cund_Prod = Apc.Cund_Prod
                                                  AND Pap.Cindcd_Papel = 0
                   WHERE Apc.Cind_Apurc_Selec = 1
                     and pc.vprod_crrtr > 0 /*rateio*/
                     AND c.Ctpo_Pssoa = Ca.Ctpo_Pssoa
                     AND c.Ccpf_Cnpj_Base = Ca.Ccpf_Cnpj_Base
                   GROUP BY c.Ccpf_Cnpj_Base,
                            c.Ctpo_Pssoa,
                            Apc.Cund_Prod) LOOP
      Chrlocalerro := 17;
      -- Busca o maior CPD por sucursal
      SELECT Ss.Ccrrtr
        INTO Intcodmaiorcrrtr
        FROM (SELECT Ss.Ccrrtr,
                     Ss.Total
                FROM (SELECT c.Ctpo_Pssoa,
                             c.Ccpf_Cnpj_Base,
                             Apc.Cund_Prod,
                             Apc.Ccrrtr,
                             SUM(Pc.Vprod_Crrtr) AS Total
                        FROM Apurc_Prod_Crrtr Apc
                        JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                                    AND c.Cund_Prod = Apc.Cund_Prod
                        JOIN Prod_Crrtr Pc ON Pc.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                          AND Pc.Cund_Prod = Apc.Cund_Prod
                                          AND Pc.Ccrrtr = Apc.Ccrrtr
                                          AND Pc.Ccompt_Prod = Apc.Ccompt_Prod
                                          AND Pc.Ctpo_Comis = Apc.Ctpo_Comis
                       WHERE Apc.Cind_Apurc_Selec = 1
                         AND c.Ctpo_Pssoa = Caint.Ctpo_Pssoa
                         AND c.Ccpf_Cnpj_Base = Caint.Ccpf_Cnpj_Base
                         AND c.cund_prod = caInt.Cund_Prod
                       GROUP BY c.Ctpo_Pssoa,
                                c.Ccpf_Cnpj_Base,
                                Apc.Cund_Prod,
                                Apc.Ccrrtr) Ss
               ORDER BY Ss.Total DESC) Ss
       WHERE Rownum < 2;
      Chrlocalerro := 18;
      -- Insere na tabela HISTORICO-DISTR-PAGAMENTO-BONUS
      INSERT INTO Hist_Distr_Pgto
        (Vdistr_Pgto_Crrtr,
         Cpgto_Bonus,
         Ccrrtr,
         Cund_Prod)
      VALUES
        (caInt.Total - ( ca.totalnegativo * (caInt.Total/ca.totalModulo) ) ,  /*rateio*/
         Intproxcodigopgtocrrtr,
         Intcodmaiorcrrtr,
         Caint.Cund_Prod);
    END LOOP;
    Chrlocalerro := 19;
    -- Insere os registros na tabela de papel-apuracao-pagamento
    FOR Caint IN (SELECT Apc.Ccompt_Apurc,
                         Apc.Ccanal_Vda_Segur,
                         Apc.Cgrp_Ramo_Plano,
                         Apc.Ccompt_Prod,
                         Apc.Ctpo_Comis,
                         Apc.Ctpo_Apurc,
                         Apc.Ccrrtr,
                         Apc.Cund_Prod,
                         Apc.Pbonus_Apurc,
                         CASE
                           WHEN Pap.Ccrrtr IS NULL THEN
                            0
                           ELSE
                            1
                         END Tempagamento
                    FROM Apurc_Prod_Crrtr Apc
                    JOIN Crrtr c ON c.Ccrrtr = Apc.Ccrrtr
                                AND c.Cund_Prod = Apc.Cund_Prod
                    LEFT JOIN Papel_Apurc_Pgto Pap ON Pap.Ccanal_Vda_Segur = Apc.Ccanal_Vda_Segur
                                                  AND Pap.Ctpo_Apurc = Apc.Ctpo_Apurc
                                                  AND Pap.Ccompt_Apurc = Apc.Ccompt_Apurc
                                                  AND Pap.Cgrp_Ramo_Plano = Apc.Cgrp_Ramo_Plano
                                                  AND Pap.Ccompt_Prod = Apc.Ccompt_Prod
                                                  AND Pap.Ctpo_Comis = Apc.Ctpo_Comis
                                                  AND Pap.Ccrrtr = Apc.Ccrrtr
                                                  AND Pap.Cund_Prod = Apc.Cund_Prod
                                                  AND Pap.Cindcd_Papel = 0
                   WHERE Apc.Cind_Apurc_Selec = 1
                     AND c.Ctpo_Pssoa = Ca.Ctpo_Pssoa
                     AND c.Ccpf_Cnpj_Base = Ca.Ccpf_Cnpj_Base) LOOP
      Chrlocalerro := 20;
      -- Insere papel eleição
      INSERT INTO Papel_Apurc_Pgto
        (Cpgto_Bonus,
         Ccrrtr,
         Cund_Prod,
         Ccanal_Vda_Segur,
         Ctpo_Apurc,
         Ccompt_Apurc,
         Cgrp_Ramo_Plano,
         Ccompt_Prod,
         Ctpo_Comis,
         Cindcd_Papel)
      VALUES
        (Intproxcodigopgtocrrtr,
         Caint.Ccrrtr,
         Caint.Cund_Prod,
         Caint.Ccanal_Vda_Segur,
         Caint.Ctpo_Apurc,
         Caint.Ccompt_Apurc,
         Caint.Cgrp_Ramo_Plano,
         Caint.Ccompt_Prod,
         Caint.Ctpo_Comis,
         1);
      /* não tem pagamento*/
      IF Caint.Tempagamento = 0 THEN
        Chrlocalerro := 21;
        -- Insere papel pagamento se naum tiver antes claro
        INSERT INTO Papel_Apurc_Pgto
          (Cpgto_Bonus,
           Ccrrtr,
           Cund_Prod,
           Ccanal_Vda_Segur,
           Ctpo_Apurc,
           Ccompt_Apurc,
           Cgrp_Ramo_Plano,
           Ccompt_Prod,
           Ctpo_Comis,
           Cindcd_Papel)
        VALUES
          (Intproxcodigopgtocrrtr,
           Caint.Ccrrtr,
           Caint.Cund_Prod,
           Caint.Ccanal_Vda_Segur,
           Caint.Ctpo_Apurc,
           Caint.Ccompt_Apurc,
           Caint.Cgrp_Ramo_Plano,
           Caint.Ccompt_Prod,
           Caint.Ctpo_Comis,
           0);
      END IF;
    END LOOP;
    Chrlocalerro := 22;
    -- acrescenta um no contador
    Intproxcodigopgtocrrtr := Intproxcodigopgtocrrtr + 1;
  END LOOP;
  Chrlocalerro := 23;
  PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,708,'PO');
  Chrlocalerro := 24;
  -- Volta a configuração inicial
  UPDATE Apurc_Prod_Crrtr SET Cind_Apurc_Selec = 0 WHERE Cind_Apurc_Selec = 1;
  Chrlocalerro := 27;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    Var_Log_Erro := Substr('Cod.Erro: ' || Chrlocalerro || ' Compet: ' || To_Char(Intrcompetencia) ||
                           ' Canal: ' || To_Char(Intcodcanal_Vda_Segur) || ' # ' || SQLERRM,
                           1,Pc_Util_01.Var_Tam_Msg_Erro);
    
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL, NULL);
    PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler, 708, Pc_Util_01.Var_Rotna_Pe);
END Sgpb0025;
/

