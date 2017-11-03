CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0331(intrCPF_CNPJ             in CRRTR.CCPF_CNPJ_CRRTR %type,
                                     chrTpPessoa              in CRRTR_UNFCA_CNPJ.CTPO_PSSOA %type,
                                     dCompt                   in date,
                                     intrELEITO_Ebanco        out number,
                                     intrELEITO_banco         out number,
                                     intrELEITO_Finasa        out number,
                                     intrELEITO_CCanal_Ebanco out number,
                                     intrELEITO_CCanal_banco  out number,
                                     intrELEITO_CCanal_Finasa out number,
                                     chELEITO_Ebanco          out varchar2,
                                     chELEITO_banco           out varchar2,
                                     chELEITO_Finasa          out varchar2)
-------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0331
  --      DATA            : 12/01/2007
  --      AUTOR           : Bruno Marcondes
  --      OBJETIVO        : Verifico se o Corretor está eleito ou não.
  --      ALTERAÇÕES      :
  --                DATA  : -
  --                AUTOR : -
  --                OBS   : -
  -------------------------------------------------------------------------------------------------
 IS
  --
  --
  VAR_LOG_ERRO           VARCHAR2(1000);
  chrLocalErro           VARCHAR2(2) := '00';
  intrCPF_CNPJ_BASE      CRRTR.CCPF_CNPJ_BASE%type;
  chrNomeRotinaScheduler VARCHAR2(10) := 'SGPB0331';
  --

  ----------------------------------------------------------------------------------------geraDetail
  ----------------------------------------------------------------------------------------
  PROCEDURE geraDetail IS
  BEGIN
  
    -- É passado o CPF_CNPJ completo por isso, calculo o CPF_CNPJ_BASE.
    If chrTpPessoa = 'F' then
      intrCPF_CNPJ_BASE := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 2);
    Else
      intrCPF_CNPJ_BASE := substr(intrCPF_CNPJ, 1, length(intrCPF_CNPJ) - 6);
    End If;
  
    intrELEITO_Ebanco := 0;
    intrELEITO_banco  := 0;
    intrELEITO_Finasa := 0; 
    
    For C in (SELECT cec.Ccanal_Vda_Segur CANAL,
                     cvs.icanal_vda_segur ICANAL,
                     count(*) Eleito
                FROM parm_info_campa pic
              
                join crrtr_eleit_campa cec on cec.Ccanal_Vda_Segur =
                                              pic.Ccanal_Vda_Segur
                                          and cec.dinic_vgcia_parm =
                                              pic.dinic_vgcia_parm
              
                join canal_vda_segur cvs on cvs.ccanal_vda_segur =
                                            cec.ccanal_vda_segur
              
               where dCompt BETWEEN pic.dinic_vgcia_parm AND
                     Nvl(pic.Dfim_Vgcia_Parm,
                         To_Date('99991231', 'YYYYMMDD'))
                    
                 and cec.ccpf_cnpj_base = intrCPF_CNPJ_BASE
                 and cec.ctpo_pssoa = chrTpPessoa
              
               group by cec.Ccanal_Vda_Segur, cvs.icanal_vda_segur
                                  
              ) Loop

      If C.CANAL = 1 then
        intrELEITO_Ebanco        := C.Eleito;
        intrELEITO_CCanal_Ebanco := PC_UTIL_01.Extra_Banco;
        chELEITO_Ebanco          := C.ICANAL;
      
      Elsif C.CANAL = 2 then
        intrELEITO_banco        := C.Eleito;
        intrELEITO_CCanal_banco := PC_UTIL_01.Banco;
        chELEITO_banco          := C.ICANAL;
      
      Elsif C.CANAL = 3 then
        intrELEITO_Finasa        := C.Eleito;
        intrELEITO_CCanal_Finasa := PC_UTIL_01.Finasa;
        chELEITO_Finasa          := C.ICANAL;
      
      End If;
    
    End Loop;
  END;

BEGIN
  -------------------------------------------------------------------------------------------------
  --
  --  CORPO DA PROCEDURE
  --
  -------------------------------------------------------------------------------------------------
  --
  --
  -- PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
  --                               708,
  --                               PC_UTIL_01.Var_Rotna_Pc);
  --
  --
  geraDetail();
  --
  --
  --PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
  --                               708,
  --                               PC_UTIL_01.Var_Rotna_Po);
  --
  --
  chrLocalErro := '07';
  COMMIT;
  --
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    --
    ROLLBACK;
    --
    var_log_erro := substr('Cod.Erro: ' || chrLocalErro || ' Compet: ' ||
                           to_char(dCompt) || ' # ' || SQLERRM,
                           1,
                           PC_UTIL_01.VAR_TAM_MSG_ERRO);
    --
    PR_GRAVA_MSG_LOG_CARGA('SGPB0331',
                                var_log_erro,
                                pc_util_01.VAR_LOG_PROCESSO,
                                NULL,
                                NULL);
    --
    --
    --PR_ATUALIZA_STATUS_ROTINA(chrNomeRotinaScheduler,
    --                               708,
    --                               PC_UTIL_01.VAR_ROTNA_PE);
    --
END SGPB0331;
/

