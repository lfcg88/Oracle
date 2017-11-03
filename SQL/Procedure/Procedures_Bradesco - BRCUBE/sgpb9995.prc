CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB9995
-------------------------------------------------------------------------------------------------
--      BRADESCO SEGUROS S.A.
--      PROCEDURE       : SGPB9995
--      DATA            : 28/03/2008
--      AUTOR           : Alexandre Cysne Esteves
--      OBJETIVO        : 
--      ALTERA��ES      : 
--                DATA  :
--                AUTOR : 
--                OBS   : 
-------------------------------------------------------------------------------------------------
IS
  --dwsheluler
  VAR_ROTINA					VARCHAR2(10) := 'SGPB9995';
  VAR_PARAMETRO		    NUMBER := 722;
BEGIN
   -- DWSHEDULER
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO 
   PR_LIMPA_LOG_CARGA(VAR_ROTINA); 
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;
   -- INICIANDO A EXECUCAO
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PC);
   COMMIT;
   --

   BEGIN          
   
    --inserindo na tabela de eleito
    --extrabanco
    --GEORGE CORRETORA DE SEGUROS LTDA
    --INSERT INTO CRRTR_ELEIT_CAMPA VALUES(1,'01/10/2007',SYSDATE,'J',5638386);
    --INSERT INTO CRRTR_ELEIT_CAMPA VALUES(1,'01/10/2007','31/03/2008','J',5638386);

    --
    --COMMIT;
    --calculando objetivo para o corretor extrabanco
    --200801 200802 200803

    --SGPB0170(200712,'SGPB9170',007944737,'J');
    --COMMIT;
     
    --INCLUINDO O GRUPO ECONOMICO 'OM CORRETORA DE SEGUROS'
    INSERT INTO AGPTO_ECONM_CRRTR VALUES('J',41088519,'01/10/2007','G.E. OM CORRETORA DE SEGUROS LTDA','descr: nao informada',NULL,'S','K143154',SYSDATE,NULL);
    INSERT INTO CRRTR_PARTC_AGPTO_ECONM VALUES('J',41088519,'01/10/2007','J',41088519,'01/04/2008',NULL);
    COMMIT;
    --INSERT INTO CRRTR_PARTC_AGPTO_ECONM VALUES('J',41088519,'01/10/2007','J',881534,'01/04/2008',NULL);
    --ENVIAR E-MAIL COM QUE ESTA SEM META E A CORRETORA MONTEIRO AINDA N�O ESTA ELEITA -- NO PROCESSO DE ELEI��O ELA VAI ENTRAR.
    
    --INCLUINDO O GRUPO ECONOMICO 'MARCOS ROBERTO DE ANDRADE'
    INSERT INTO AGPTO_ECONM_CRRTR VALUES('F',372835290,'01/10/2007','G.E. MARCOS ROBERTO DE ANDRADE SCHWANZ CORR DE SEGS','descr: nao informada',NULL,'S','K143154',SYSDATE,NULL);
    INSERT INTO CRRTR_PARTC_AGPTO_ECONM VALUES('F',372835290,'01/10/2007','F',372835290,'01/04/2008',NULL);
    INSERT INTO CRRTR_PARTC_AGPTO_ECONM VALUES('F',372835290,'01/10/2007','J',8979331,'01/04/2008',NULL);
    --ENVIAR E-MAIL COM QUE ESTA SEM META E A CORRETORA MARCOS SCHWANZ AINDA N�O ESTA ELEITA -- NO PROCESSO DE ELEI��O ELA VAI ENTRAR.
    COMMIT;
    
/*DELETE FROM CRRTR_PARTC_AGPTO_ECONM  CPAE WHERE CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR =  41088519;
COMMIT;
DELETE FROM AGPTO_ECONM_CRRTR AEC WHERE AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = 41088519;
COMMIT;
-------------
DELETE FROM CRRTR_PARTC_AGPTO_ECONM  CPAE WHERE CPAE.CCPF_CNPJ_AGPTO_ECONM_CRRTR =  372835290;
COMMIT;
DELETE FROM AGPTO_ECONM_CRRTR AEC WHERE AEC.CCPF_CNPJ_AGPTO_ECONM_CRRTR = 372835290;
COMMIT;*/

    --DELETE FROM RSUMO_OBJTV_CRRTR A WHERE A.CCOMPT IN(200804,200805,200806);
    --COMMIT;
     
   --          
   EXCEPTION
      WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-99971,'PL GEORGE CORRETORA DE SEGUROS LTDA' || SUBSTR(SQLERRM,1,100));
           --VAR_LOG_ERRO := SUBSTR(SQLERRM,1,500);
           ROLLBACK;
           PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'TERMINO COM ERRO, COD. DO ERRO : '||SUBSTR(SQLERRM,1,500),'P',NULL,NULL);
           PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PE);
           COMMIT;
   END;
                     
   COMMIT;
   -- DWSHEDULER
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'FIM DO PROCESSO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARAMETRO,PC_UTIL_01.VAR_ROTNA_PO);
   COMMIT;
   --

END SGPB9995;
/
