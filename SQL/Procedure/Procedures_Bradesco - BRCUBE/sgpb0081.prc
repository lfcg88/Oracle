CREATE OR REPLACE PROCEDURE SGPB_PROC.Sgpb0081(
  Intrcompetencia        Margm_Contb_Crrtr.Ccompt_Margm %TYPE,
  VAR_IDTRIO_TRAB        varchar2,
  VAR_IARQ_TRAB          varchar2,
  Chrnomerotinascheduler VARCHAR2 := 'SGPB9081' )
  -------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0081
  --      DATA            : 31/05/2006 3:59:25 PM
  --      AUTOR           : WASSILY CHUK SEIBLITZ GUANAES
  --      OBJETIVO        : Gerar a exportação do movimento contabil. 
  --                        31/08/2007 - Programa original foi substituido por esse. 
  --                                     O antigo tem erro foi feito a partir de copy e past do programa financeiro.
  --                                     Ass. Wassily.
  --                        26/11/2007 - Implementado (hard Core) para contemplar novo plano de contas, segundo EN 2007-002018
  --                                     Ass. Wassily.
  -------------------------------------------------------------------------------------------------
  IS
  Var_Crotna        CONSTANT CHAR(8) := 'SGPB9081';
  Var_Irotna        CONSTANT CHAR(4) := '850';
  Var_Arquivo       Utl_File.File_Type;
  Var_Log_Erro      Pc_Util_01.Var_Log_Erro%TYPE;
  Intcompetenciadoc CHAR(6) := (Substr(Intrcompetencia,5)||Substr(Intrcompetencia,1,4));
  Sponto            CHAR(5) := '#XXXX';
  Intcolutilizadas  INTEGER := 0;
  Intcolarquivo     CONSTANT INTEGER := 110;
  Intqtdlinexp      INTEGER := 0;
  Totalvalordebito  NUMBER := 0;
  Totalvalorcredito NUMBER := 0;
  VAR_VALOR         NUMBER;
  PROCEDURE Add_Linha ( Chrtexto IN VARCHAR2, Comtrim  BOOLEAN := TRUE )  IS Texto VARCHAR2(200);
  BEGIN
      IF Comtrim THEN
         Texto := TRIM(Chrtexto);
      ELSE
         Texto := Chrtexto;
      END IF;
      Intcolutilizadas := Intcolutilizadas + Length(Texto);
      Utl_File.Put(Var_Arquivo,Texto);
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
      --Add(Intrcompetencia); 
      Add_Linha(to_number(to_char(SYSDATE,'YYYYMM'))); -- revisar na proxima melhoria para pegar a data do mov. contabil e não a sysdate
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
      --qUANTIDADE DE REGISTROS + HEADER E TRAILER
      Sponto := '#0002';
      Add_Linha(Lpad(Intqtdlinexp + 1, 9, '0'));
      -- Valor total dos debitos que devem ocorrer no sistema CTAB
      Sponto := '#0003';
      Add_Linha(Lpad(Trunc(Totalvalordebito), 17, '0')); 
      -- Valor total dos debitos que devem ocorrer no sistema CTA
      Sponto := '#0004';
      Add_Linha(Lpad(Trunc(Totalvalorcredito), 17, '0'));
      Sponto := '#0005';
      Terminarlinha();
  END;
  PROCEDURE Geratransacao IS
    Valortratadoevento INTEGER;
  BEGIN
    Sponto := '#0006';
    Totalvalorcredito := 0;
    Totalvalordebito  := 0;
    -- pegando corretores por cpf base (raiz)
    FOR Movimento IN (select distinct Lpad(HDP.CUND_PROD, 3, 0) Cund_Prod,
       						lpad(hdp.ccrrtr,6,0) ccrrtr,
       						case
          							when Pap.CCANAL_VDA_SEGUR = 1 then
           		 						'2128800020000'
           							when Pap.CCANAL_VDA_SEGUR = 2 then
           		 						'2128800010000'
           							when Pap.CCANAL_VDA_SEGUR = 3 then
           		 						'2128800030000'
    						end Conta_Desvedora,
       						'1113100000000' Conta_Credora,
       						HDP.VDISTR_PGTO_CRRTR
       						from PGTO_BONUS_CRRTR pbc, HIST_DISTR_PGTO HDP, PAPEL_APURC_PGTO PAP
						    WHERE pbc.CPGTO_BONUS=hdp.CPGTO_BONUS and
						          pbc.CPGTO_BONUS=pap.CPGTO_BONUS and
								  pbc.CCOMPT_PGTO=Intcompetenciadoc) 
       LOOP
        Sponto := '#0007';
        FOR Tipoconta IN 1 .. 2 LOOP
            --zera contador
            Intcolutilizadas := 0;
            --Origem
            Add_Linha('103');
            --CIA companhia
            Add_Linha('5312'); -- Revisar para que possa ter outras empresas na mesma campanha.
            --Conta
            Sponto := '#0009';
            Add_Linha(CASE WHEN Tipoconta = 1 THEN Movimento.Conta_Credora 
                           WHEN Tipoconta = 2 THEN Movimento.Conta_Desvedora
            		  end);
            --Ramo
            Add_Linha('120');
            --Sucursal
            Sponto := '#0010';
            Add_Linha(Movimento.Cund_Prod); 
            --Auxiliar
            Add_Linha(movimento.ccrrtr);
            --Documento
            Add_Linha('0000');
            --Data MMAAAA
            Sponto := '#0011';
            Add_Linha(Intcompetenciadoc); -- data da competencia da apuracao do pagamento.
            --Valor
            Sponto := '#0012';
            VAR_VALOR := TRUNC( Movimento.VDISTR_PGTO_CRRTR * 100 );
            Add_Linha(Lpad(VAR_VALOR, 14, '0'));  
            --Código D/C
            Add_Linha(CASE WHEN Tipoconta = 1 THEN 'C' 
                           WHEN Tipoconta = 2 THEN 'D'
                      END);
            --Historico
            Add_Linha(Rpad('MC.SGPB REALIZACAO',33,' '), FALSE);
            -- calculando totais de debito e de credito            
            if Tipoconta = 1 then
               Totalvalorcredito := Totalvalorcredito + VAR_VALOR;
            else
               Totalvalordebito  := Totalvalordebito + VAR_VALOR;
            end if;
            --Inspetoria
            Add_Linha('000');
            --Tipo
            Add_Linha('00');
            --Indicador
            Add_Linha('  ',FALSE);
            --Filler
            Add_Linha('  ',FALSE);
            --CDC
            Add_Linha('00000000');
            Sponto := '#0013';
            Terminarlinha();
        END LOOP;
      END LOOP;
  END;
BEGIN
    Sponto := '#0014';
    PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler, Var_Irotna, Pc_Util_01.Var_Rotna_Pc);
    commit;
    Sponto := '#0015';
    Var_Arquivo := Utl_File.Fopen(VAR_IDTRIO_TRAB, VAR_IARQ_TRAB,'W');
    Sponto := '#0016';
    Geraheader();
    Sponto := '#0017';
    Geratransacao();
    Sponto := '#0018';
    Geratrailer();
    Sponto := '#0019';
    Utl_File.Fflush(Var_Arquivo);
    Sponto := '#0020';
    Utl_File.Fclose(Var_Arquivo);
    Sponto := '#0022';
    UPDATE Apurc_Movto_Ctbil Am 
  	       SET Am.Cind_Arq_Expor = 1 
  	       WHERE Am.Ccompt_Movto_Ctbil = Intrcompetencia;
    commit;
    Sponto := '#0023';
    PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler, Var_Irotna, Pc_Util_01.Var_Rotna_Po);
    COMMIT;
EXCEPTION
    WHEN Utl_File.Invalid_Path THEN
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, '||' INVALID PATH',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,Var_Irotna,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
    WHEN Utl_File.Invalid_Mode THEN
      rollback;
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||' INVALID MODE',1,PC_UTIL_01.VAR_TAM_MSG_ERRO);
      PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,Var_Irotna,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20210,var_log_erro);
    WHEN Utl_File.Invalid_Operation THEN
      var_log_erro := substr('PROBLEMA NA ABERTURA ARQUIVO, VAR_IDTRIO_TRAB: '||'Invalid_Operation. ERRO: '||SQLERRM,1,
                             PC_UTIL_01.VAR_TAM_MSG_ERRO);      
      rollback;
      PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler,Var_Irotna,PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20212,var_log_erro);
    WHEN Utl_File.Invalid_Maxlinesize THEN
      var_log_erro := substr('Invalid_Maxlinesize '||SQLERRM,1,PC_UTIL_01.VAR_TAM_MSG_ERRO);      
      rollback;
      PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler,var_log_erro,pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler, Var_Irotna, PC_UTIL_01.Var_Rotna_pe);
      commit;
      Raise_Application_Error(-20213,'Invalid_Maxlinesize '||SQLERRM);
    WHEN OTHERS THEN
      Var_Log_Erro := Substr('Erro ao ao gerar o documento de Movimento Contabil. Competência:' || 
                            Intrcompetencia || ' #' || Sponto || '# '||SQLERRM,1,Pc_Util_01.Var_Tam_Msg_Erro);    
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA(Chrnomerotinascheduler, Var_Log_Erro, Pc_Util_01.Var_Log_Processo, NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA(Chrnomerotinascheduler, Var_Irotna, Pc_Util_01.Var_Rotna_Pe);
      COMMIT;
      Raise_Application_Error(-20213,var_log_erro); 
END Sgpb0081;
/

