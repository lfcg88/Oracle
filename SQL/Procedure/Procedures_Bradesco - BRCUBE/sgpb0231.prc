CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0231 IS
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0231
  --      DATA            : 25/04/2008
  --      AUTOR           : WASSILY CHUK SEIBLITZ GUANAES
  --      OBJETIVO        : Gerar a exportação do movimento contabil (versão nova).
  -------------------------------------------------------------------------------------------------
  VAR_DCARGA        date;
  VAR_DPROX_CARGA   DATE;
  VAR_IDTRIO_TRAB   varchar2(100);
  VAR_IARQ_TRAB     varchar2(100);
  VAR_CAMBTE        varchar2(100);
  VAR_COMPT         number(6);   
  VAR_ROTINA        CONSTANT CHAR(8) := 'SGPB0231';
  VAR_PARM          NUMBER := 850;
  Var_Arquivo       Utl_File.File_Type;
  Var_Log_Erro      Pc_Util_01.Var_Log_Erro%TYPE;
  Sponto            CHAR(5) := '#XXXX';
  Intcolutilizadas  INTEGER := 0;
  Intcolarquivo     CONSTANT INTEGER := 110;
  Intqtdlinexp      INTEGER := 0;
  VAR_TOTAL_MOV     NUMBER := 0;
  VAR_TEXTO         VARCHAR2(600); 
  VAR_HISTORICO     VARCHAR2(600); 
PROCEDURE Add_Linha ( Chrtexto IN VARCHAR2, Comtrim  BOOLEAN := TRUE ) 
IS 
BEGIN
      IF Comtrim THEN
         VAR_TEXTO := TRIM(Chrtexto);
      ELSE
         VAR_TEXTO := Chrtexto;
      END IF;
      Intcolutilizadas := Intcolutilizadas + Length(VAR_TEXTO);
      Utl_File.Put(Var_Arquivo,VAR_TEXTO);
      VAR_HISTORICO := VAR_HISTORICO||VAR_TEXTO;
END;
PROCEDURE Terminarlinha IS
BEGIN
      Intqtdlinexp := Intqtdlinexp + 1;
      Utl_File.Put(Var_Arquivo,Lpad(' ',Intcolarquivo - Intcolutilizadas));
      Utl_File.New_Line(Var_Arquivo);
      Intcolutilizadas := 0;
END;
PROCEDURE Geraheader IS
BEGIN
      --zera contador      
      Intcolutilizadas := 0;
      --tipo registro 0 header
      Add_Linha('*HEADER');
      --DEFINIÇÃO DO SISTEMA
      Add_Linha('CTA');
      -- COLOCA COMPETENCIA CORRENTE AAAAMM
      Sponto := '#0000';
      Add_Linha(VAR_COMPT); 
      -- discriminação de MC
      Add_Linha('MC');
      -- discriminação do sistema
      Add_Linha('SGP');
      Sponto := '#0001';
      Terminarlinha();
END;
PROCEDURE Geratrailer IS
BEGIN
      --zera contador
      Intcolutilizadas := 0;
      --tipo registro 0 TRAILLER
      Add_Linha('*TRAILER');
      --QUANTIDADE DE REGISTROS + HEADER E TRAILER
      Sponto := '#0002';
      Add_Linha(Lpad(Intqtdlinexp + 1, 9, '0'));
      -- Valor total dos Debitos que devem ocorrer no sistema CTAB
      Sponto := '#0003';
      Add_Linha(Lpad(Trunc(VAR_TOTAL_MOV), 17, '0')); 
      -- Valor total dos Cebitos que devem ocorrer no sistema CTA
      Sponto := '#0004';
      Add_Linha(Lpad(Trunc(VAR_TOTAL_MOV), 17, '0'));
      Sponto := '#0005';
      Terminarlinha();
END;
PROCEDURE Geratransacao IS Valortratadoevento INTEGER;
BEGIN
    Sponto := '#0006';
    VAR_TOTAL_MOV := 0;
    FOR Movimento IN (select ROWID ROWID_REG, Lpad(CUND_PROD,3,0) Cund_Prod, LPAD(CCRRTR,6,0) ccrrtr, CRAMO, RHIST_CTBIL, 
       						 CCTA_CTBIL_DVDOR Conta_Devedora, CCTA_CTBIL_CREDR Conta_Credora,
       						 TRUNC( VPGTO_TOT * 100 ) VPGTO_TOT
       						 from HIST_CTBIL 
       						 WHERE CCOMPT_MOVTO_CTBIL = VAR_COMPT ) 
       LOOP
         Sponto := '0007';
         --
         -- Lançando DÈBITO
         --
            Intcolutilizadas := 0;            
            VAR_HISTORICO := ' LANC.DEBITO: ';  
            Add_Linha('103');
            Add_Linha('5312');
            Sponto := '#0009';
            Add_Linha(Movimento.Conta_Devedora); 
            Add_Linha('120');
            Sponto := '#0010';
            Add_Linha(Movimento.Cund_Prod); 
            Add_Linha(movimento.ccrrtr);
            Add_Linha('0000');
            Sponto := '#0011';
            Add_Linha(VAR_COMPT);
            Sponto := '#0012';
            Add_Linha(Lpad(Movimento.VPGTO_TOT, 14, '0'));
            Add_Linha('D');
            IF MOVIMENTO.RHIST_CTBIL = 'PAGAMENTO' THEN
               Add_Linha(Rpad('MC.SGPB REALIZACAO',33,' '), FALSE);
            ELSIF MOVIMENTO.RHIST_CTBIL = 'PROVISAO' THEN
               Add_Linha(Rpad('MC.SGPB PROVISAO  ',33,' '), FALSE);
            ELSE
               Add_Linha(Rpad('MC.SGPB ESTORNO   ',33,' '), FALSE);
            END IF;
            Add_Linha('000');
            Add_Linha('00');
            Add_Linha('  ',FALSE);
            Add_Linha('  ',FALSE);
            Add_Linha('00000000');
            Sponto := '#0013';
            Terminarlinha();
         Sponto := '#0008';    
         --
         -- Lançando CRÉDITO ( ATENÇÃO: É UM POUCO DIFERENTE DO DÉDITO)
         --
            VAR_HISTORICO := VAR_HISTORICO||' LANC.CREDITO: ';
            Intcolutilizadas := 0;
            Add_Linha('103');
            Add_Linha('5312');
            Sponto := '#0009';
            Add_Linha(Movimento.Conta_Credora);
            IF Movimento.Conta_Credora = '1113100000000' -- Se for essa conta não tem RAMO
            THEN
               Add_Linha('000');
            ELSE
               Add_Linha('120');
            END IF;
            Sponto := '#0010';
            IF Movimento.Conta_Credora = '1113100000000' -- Se for essa conta não tem UNIDADE DE PRODUCAO
            THEN
               Add_Linha('000');
            ELSE
               Add_Linha(Movimento.Cund_Prod);
            END IF;
            Add_Linha(movimento.ccrrtr);
            Add_Linha('0000');
            Sponto := '#0011';
            Add_Linha(VAR_COMPT);
            Sponto := '#0012';
            Add_Linha(Lpad(Movimento.VPGTO_TOT, 14, '0'));  
            Add_Linha('C'); 
            IF MOVIMENTO.RHIST_CTBIL = 'PAGAMENTO' THEN
               Add_Linha(Rpad('MC.SGPB REALIZACAO',33,' '), FALSE);
            ELSIF MOVIMENTO.RHIST_CTBIL = 'PROVISAO' THEN
               Add_Linha(Rpad('MC.SGPB PROVISAO  ',33,' '), FALSE);
            ELSE
               Add_Linha(Rpad('MC.SGPB ESTORNO   ',33,' '), FALSE);
            END IF;
            Add_Linha('000');
            Add_Linha('00');
            Add_Linha('  ',FALSE);
            Add_Linha('  ',FALSE);
            Add_Linha('00000000');
            Sponto := '#0013'; 
            Terminarlinha();
            -- Gravando Lay-Outs dos lançamentos realizados (Colocando 1 para dizer que eles foram EXPORTADOS)
            UPDATE HIST_CTBIL 
            SET
                   RHIST_CTBIL   = VAR_HISTORICO,                    
                   Cind_Arq_Expor= 1,
                   DEXPOR_CTBIL  = SYSDATE,
                   DULT_ALT      = SYSDATE
            WHERE ROWID          = MOVIMENTO.ROWID_REG;            
            -- calculando totais para usar no final do arquivo gerado
            VAR_TOTAL_MOV := VAR_TOTAL_MOV + MOVIMENTO.VPGTO_TOT;
      END LOOP;
END;
BEGIN
   Sponto := 'A001';
   -- LIMPA A TABELA DE LOG NO INICIO DO PROCESSO (O TRIGGER JOGARAH AS INFORMACOES PARA A TABELA DE HISTORICO)
   PR_LIMPA_LOG_CARGA(VAR_ROTINA);
   Sponto := 'A002';
   -- RECUPERA OS DADOS DE PARAMETRO DE CARGA
   PR_LE_PARAMETRO_CARGA(VAR_PARM, VAR_DCARGA, VAR_DPROX_CARGA);
   VAR_COMPT := TO_NUMBER(TO_CHAR(VAR_DPROX_CARGA,'YYYYMM'),'FM999999');
   Sponto := 'A003';
   -- GRAVA LOG INICIAL DE CARGA
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'INICIO DO PROCESSO. EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   -- Vendo em que ambiente está
   Sponto := 'A004';
   VAR_CAMBTE := FC_VERIFICA_AMBIENTE_ROTINA;
   -- RECUPERA OS DADOS DE diretorio e arquivo
   PR_DIRETORIO_ARQUIVO( VAR_CAMBTE, 'SGPB' , 'SGPB9081' , 'W' , 1 , VAR_IDTRIO_TRAB , VAR_IARQ_TRAB);
   -- Se viver o nome do arquivo com nulo, vai colocar o nome constante
   Sponto := 'A005';
   if VAR_IARQ_TRAB is null then
      VAR_IARQ_TRAB := 'SGPB0081';
   end if;
   -- Colocando a Competencia no Arquivo (trata se o arquivo está vindo ou nao com o .dat, senao tive vai colocar)
   IF ( UPPER(substr(VAR_IARQ_TRAB,-4,4)) <> '.DAT' ) THEN
        Sponto := 'A006';
   		VAR_IARQ_TRAB := VAR_IARQ_TRAB||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   ELSE
        Sponto := 'A007';
   		VAR_IARQ_TRAB := substr(VAR_IARQ_TRAB,1,(LENGTH(VAR_IARQ_TRAB)-4))||'_'||to_char(VAR_DPROX_CARGA,'YYYYMMDD')||'.dat';
   END IF;
   Sponto := 'A008'; 
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'SERA GERADO O ARQUIVO '||VAR_IARQ_TRAB||' NO DIRETORIO '||VAR_IDTRIO_TRAB,'P',NULL,NULL);
   COMMIT;
    Sponto := '014';
    PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA, VAR_PARM, Pc_Util_01.Var_Rotna_Pc);
    commit;
    Sponto := '015';
    Var_Arquivo := Utl_File.Fopen(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB,'W');
    Sponto := '016';
    Geraheader();
    Sponto := '017';
    Geratransacao();
    Sponto := '018';
    Geratrailer();
    Sponto := '019';
    Utl_File.Fflush(Var_Arquivo);
    Sponto := '020';
    Utl_File.Fclose(Var_Arquivo);
    Sponto := '022';
    PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA, VAR_PARM, Pc_Util_01.Var_Rotna_Po);
    COMMIT;
   PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,'FIM DO PROCESSAMENTO EM '||TO_CHAR(SYSDATE,'DD/MM/YYYY'),'P',NULL,NULL);
   COMMIT;   
EXCEPTION
    WHEN Utl_File.Invalid_Path THEN
         rollback;
         var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, '||' INVALID PATH',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARM,PC_UTIL_01.Var_Rotna_pe);
         commit;
         Raise_Application_Error(-20210,var_log_erro);
    WHEN Utl_File.Invalid_Mode THEN
         rollback;
         var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||' INVALID MODE',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARM,PC_UTIL_01.Var_Rotna_pe);
         commit;
         Raise_Application_Error(-20210,var_log_erro);
    WHEN Utl_File.Invalid_Operation THEN
         var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||'Invalid_Operation. ERRO: '||SQLERRM,1,
                                PC_UTIL_01.VAR_TAM_MSG_ERRO);      
         rollback;
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA,VAR_PARM,PC_UTIL_01.Var_Rotna_pe);
         commit;
         Raise_Application_Error(-20212,var_log_erro);
    WHEN Utl_File.Invalid_Maxlinesize THEN
         var_log_erro := substr('Invalid_Maxlinesize '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);      
         rollback;
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA, VAR_PARM, PC_UTIL_01.Var_Rotna_pe);
         commit;
         Raise_Application_Error(-20213,'Invalid_Maxlinesize '||SQLERRM);
    WHEN OTHERS THEN
         Var_Log_Erro := Substr('Erro ao ao gerar o documento de Movimento Contabil.' || 
                         ' #' || Sponto || '# '||SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);    
         ROLLBACK;
         PR_GRAVA_MSG_LOG_CARGA(VAR_ROTINA, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL,NULL);
         PR_ATUALIZA_STATUS_ROTINA(VAR_ROTINA, VAR_PARM, Pc_Util_01.Var_Rotna_Pe);
         COMMIT;
         Raise_Application_Error(-20213,var_log_erro); 
END;
/

