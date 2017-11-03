create or replace procedure sgpb_proc.SGPB0169 is
  COMPT DECIMAL(6) := 200703;
begin
  -- Inicio
  PR_LIMPA_LOG_CARGA('SGPB0169');
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','CARGA OBJETIVOS A PARTIR DO PERC. CRESCIMENTO E PRODUÇÃO DO ANO PASSADO.',
                         pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.Var_Rotna_pc); 
  commit;
  --  
  /*Excluir todos da tabela de impedidos com flag ativo igual 'N'*/ 
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Excluindo todos da tabela de impedidos com flag ativo igual N.',
                         pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  commit;
/*  DELETE FROM CRRTR_IMPED_CANAL_VDA CICV
  	     WHERE CICV.CIND_REG_ATIVO = 'N';  -- testado. Wassily
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Exclusao com sucesso.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  COMMIT;
  --  
  \*Deletar e Inserir a corrtora como eleitos*\
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Deletar a corretora 1263388 de eleitos.',
                         pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  commit;
  begin
      DELETE FROM CRRTR_ELEIT_CAMPA CEC
      	WHERE CEC.CCANAL_VDA_SEGUR = 1
     		AND CEC.DINIC_VGCIA_PARM =
         		(SELECT PIC.DINIC_VGCIA_PARM
            		FROM PARM_INFO_CAMPA PIC
           			WHERE PIC.CCANAL_VDA_SEGUR = 1
             			AND PIC.DFIM_VGCIA_PARM IS NULL)
     					AND CEC.CTPO_PSSOA = 'J'
     					AND CEC.CCPF_CNPJ_BASE = 1263388; -- testado. Wassily.
  exception
  	when no_data_found then 
  	            null;
  	when others then 
  	            Raise_Application_Error(-20213,'CARGA COM ERRO. COD. ERRO: 1 - Erro Ora: '||SUBSTR(SQLERRM,1,100));
  end;
  --
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Exclusao com sucesso.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Inserir a corretora 1263388 como eleitos para o primeiro trimestre de 2007.',
                         pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  commit;
  --
  begin
    INSERT INTO SGPB.CRRTR_ELEIT_CAMPA
    (CCANAL_VDA_SEGUR,
     DINIC_VGCIA_PARM,
     DCRRTR_SELEC_CAMPA,
     CTPO_PSSOA,
     CCPF_CNPJ_BASE)
    	SELECT PIC.CCANAL_VDA_SEGUR,PIC.DINIC_VGCIA_PARM,TO_DATE('02/02/2007 15:08:09','DD/MM/YYYY hh24:MI:ss'),
           'J',1263388
      	FROM PARM_INFO_CAMPA PIC
     	WHERE PIC.CCANAL_VDA_SEGUR = 1
       		AND PIC.DFIM_VGCIA_PARM IS NULL;  -- testado. Wassily.
    COMMIT;
  exception
  	when no_data_found then 
  	            null;
  	when others then 
  	            Raise_Application_Error(-20213,'CARGA COM ERRO. COD. ERRO: 1A - Erro Ora: '||SUBSTR(SQLERRM,1,100));
  end;
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Insersao com sucesso.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  COMMIT;
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Inicio da seleção Extrabanco. Executando a SGPB0024 Com Competencia 200703.',
  					     pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  commit;*/
   
  
/*  --excluir os corretores eleitos no dia 20/04/2007
  SGPB0024(200703,'SGPB9024'); -- seleção extrabanco
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Inicio da seleção Finasa. Executando diretamente a SGPB8022.',
  						 pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);*/
  						 --Atualizar o perfil padrão dos canais Banco e Finasa
  -- fazendo update pedido pelo vitor para acertar parametros na producao. 2007-05-10
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','FAZENDO UPDATE NAS TABELAS DE PARAMETROS.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  COMMIT;
  begin
      update sgpb.parm_canal_vda_segur cvs
      set cprfil_pdrao_crrtr = 'N'
      where cvs.ccanal_vda_segur in (1, 3)
      and cvs.dfim_vgcia_parm is null;
      update sgpb.parm_per_apurc_canal set qmes_perdc_apurc = 3;
  Exception
    when others then
      ROLLBACK;
      PR_GRAVA_MSG_LOG_CARGA('SGPB0169',' ERRO NO UPDATE: '||SUBSTR(SQLERRM,1,200),pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.Var_Rotna_pe);  
      commit;
      Raise_Application_Error(-20213,'ERRO NO UPDATE.');
  end;
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','FEZ O UPDATE NAS TABELAS DE PARAMETROS.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  -- ----------------------------------------------------------------------------------------------------------------------
  COMMIT;
  /*1º TRIMESTRE*/
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Inicio da Inserção do Objetivo.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  COMPT := 200703;
  begin
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBanco20',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp),' - insereObjetivoExtraBanco20'); 
    commit;
    insereObjetivoExtraBanco20(COMPT,'SGPB0169');
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp),' - insereObjetivoExtraBanco20'); 
    commit;
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBanco20',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
  exception
    when others then
      PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBanco20, Erro: '||SUBSTR(SQLERRM,1,100),pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.Var_Rotna_pe); 
      pc_util_01.Sgpb0028('ERRO data: '||to_char( COMPT)||' hora '||to_char(current_timestamp),' - insereObjetivoExtraBanco20'); 
      commit;
      Raise_Application_Error(-20213,'CARGA DO ERRO');
  end;
  --
  /*2º TRIMESTRE*/
  COMPT := 200706;
  begin
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBanco20',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp), ' - insereObjetivoExtraBanco20'); 
    commit;
    insereObjetivoExtraBanco20(COMPT,'SGPB0169');
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp), ' - insereObjetivoExtraBanco20'); 
    commit;
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBanco20',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
  exception
    when others then
      PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBanco20, Erro: '||SUBSTR(SQLERRM,1,100),pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.Var_Rotna_pe); 
      pc_util_01.Sgpb0028('ERRO data: '||to_char( COMPT)||' hora '||to_char(current_timestamp), ' - insereObjetivoExtraBanco20'); 
      commit;
      Raise_Application_Error(-20213,'CARGA COM ERRO. COD. ERRO: 2');
  end;
  --  
  /*2º TRIMESTRE*/
  COMPT := 200706;
  begin
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBancoEsp',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp), ' - insereObjetivoExtraBancoEsp'); 
    commit;
    insereObjetivoExtraBancoEsp(COMPT,'SGPB0169');
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp), ' - insereObjetivoExtraBancoEsp'); 
    commit;
  exception
    when others then
      PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBancoEsp, Erro: '||SUBSTR(SQLERRM,1,100),pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.Var_Rotna_pe); 
      pc_util_01.Sgpb0028('ERRO data: '||to_char( COMPT)||' hora '||to_char(current_timestamp), ' - insereObjetivoExtraBanco20');
      commit;
      Raise_Application_Error(-20213,'CARGA COM ERRO. COD. ERRO: 3');
  end;
  --  
  /*1º TRIMESTRE*/
  COMPT := 200703;
  begin  
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBancoFixo',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    commit;
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Inicio: '||to_char(current_timestamp), ' - insereObjetivoExtraBancoFixo');
    commit;
    insereObjetivoExtraBancoFixo('SGPB0169');
    pc_util_01.Sgpb0028('Competencia: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp), ' - insereObjetivoExtraBancoFixo');
    commit;
  exception
    when others then
      PR_GRAVA_MSG_LOG_CARGA('SGPB0169','Comp: '||to_char(COMPT)||' Hora Fim: '||to_char(current_timestamp)||
                           ' - insereObjetivoExtraBancoFixo, Erro: '||SUBSTR(SQLERRM,1,100),pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
      PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.Var_Rotna_pe); 
      pc_util_01.Sgpb0028('ERRO data: '||to_char( COMPT)||' hora '||to_char(current_timestamp), ' - insereObjetivoExtraBanco20'); 
      commit;
  end;
  PR_GRAVA_MSG_LOG_CARGA('SGPB0169','FIM DA CARGA COM SUCESSO.',pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
  PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.Var_Rotna_PO); 
  commit;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    PR_GRAVA_MSG_LOG_CARGA('SGPB0169','CARGA COM ERRO. Erro: '||substr(SQLERRM,1,150),pc_util_01.VAR_LOG_PROCESSO,NULL,NULL);
    PR_ATUALIZA_STATUS_ROTINA('SGPB0169',722,PC_UTIL_01.VAR_ROTNA_PE);
    commit;
    Raise_Application_Error(-20213,'CARGA COM ERRO. COD. ERRO: 4');
end SGPB0169;
/

