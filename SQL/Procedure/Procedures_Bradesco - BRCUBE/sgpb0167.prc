CREATE OR REPLACE PROCEDURE SGPB_PROC.SGPB0167
(
  	p_canal        		in Crrtr_Eleit_Campa.Ccanal_Vda_Segur%TYPE,
  	p_ctpo_pssoa       	in Crrtr_Eleit_Campa.CTPO_PSSOA%TYPE,
  	p_ccpf_cnpj_base   	in Crrtr_Eleit_Campa.CCPF_CNPJ_BASE%TYPE,
  	p_competencia  		in PROD_CRRTR.CCOMPT_PROD%type,
  	p_retorno           out LOG_ERRO_IMPOR.IPROCS_IMPOR%type
) IS
  --------------------------------------------------------------------------------------------------------------------
  --      BRADESCO SEGUROS S.A.
  --      PROCEDURE       : SGPB0167
  --      DATA            : 27/02/2007
  --      AUTOR           : Wassily Chuk Seiblitz Guanaes
  --      OBJETIVO        : Procedure para inserir 1 corretor na tabela de corretores selecionados do plano de bonus
  --------------------------------------------------------------------------------------------------------------------
  var_dinic_vgcia_parm 	Crrtr_Eleit_Campa.dinic_vgcia_parm%TYPE;
  Var_Log_Erro 			Pc_Util_01.Var_Log_Erro%TYPE;
  Var_Crotna   			VARCHAR2(8) := 'SGPB0167';
  Var_Usuario           VARCHAR2(30);
BEGIN

  -- Verificando Se o Corretor Existe, se não existir gera mensagem de erro 
  
  begin
      select null into p_retorno from CRRTR_UNFCA_CNPJ
             where CTPO_PSSOA=UPPER(p_ctpo_pssoa) and
                   CCPF_CNPJ_BASE=p_CCPF_CNPJ_BASE;
  exception
     WHEN No_Data_Found THEN
    	  p_retorno := 'Erro. CNPJ Base '||p_CCPF_CNPJ_BASE||' e Tipo '||UPPER(p_ctpo_pssoa)||
    	               ' Informados Inexistentes No Cadastro de CNPJ Raiz.';
          return;
     WHEN OTHERS THEN
    	Var_Log_Erro := 'Erro Na Rotina '||Var_Crotna||'. Erro na Selecao do Corretor Base. Erro => '||substr(SQLERRM,1,200);
        PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    	RAISE;     	  
  end;
  
  -- Pegando Vigencia do Canal pela data de competencia passada
  
  begin  
    SELECT pic.dinic_vgcia_parm into var_dinic_vgcia_parm from parm_info_campa pic
        where pic.Ccanal_Vda_Segur = p_canal and
              Last_Day(To_Date(p_competencia,'YYYYMM')) 
                   BETWEEN pic.dinic_vgcia_parm AND Nvl(pic.Dfim_Vgcia_Parm, To_Date('99991231', 'YYYYMMDD')) AND
              ROWNUM < 2						 -- Para garantir que será pega apenas uma data de vigencia.
              ORDER BY pic.dinic_vgcia_parm ASC; -- Para garantir que será pega a menor data de vigencia para um mesmo periodo.
  exception
     WHEN No_Data_Found THEN
    	  p_retorno := 'Erro. Canal Informado Inexistente Ou Sem Data de Vigencia Para a Data Informada.';
          return;
     WHEN OTHERS THEN
    	Var_Log_Erro := 'Erro Na Rotina '||Var_Crotna||'. Erro na Selecao do Corretor Base. Erro => '||substr(SQLERRM,1,200);
        PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    	RAISE;     	  
  end;
                   
  -- Se chegou aqui é por que o cnpj base e data de vigencia existem. Entao vai Inserir.
  
  begin
      insert into crrtr_eleit_campa (ccanal_vda_segur, dinic_vgcia_parm, ctpo_pssoa, ccpf_cnpj_base, dcrrtr_selec_campa)
        		  values (p_canal, var_dinic_vgcia_parm, UPPER(p_ctpo_pssoa), p_ccpf_cnpj_base, sysdate);
      p_retorno := 'CNPJ Base: '||p_ccpf_cnpj_base||', Tipo: '||UPPER(p_ctpo_pssoa)||', Foi Inserido na Tabela de Eleitos, No Canal '||p_canal;
            
      -- Pegando quem fez o insert      
      select user into Var_Usuario from dual; 
      
      -- Logando o Insert       
      Var_Log_Erro := 'Rotina: '||Var_Crotna||', Usuario: '||Var_Usuario||', Data/Hora: '||
                       to_char(sysdate,'DD/MM/YYYY HH24:MI')||', '||p_retorno;      
      PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL); 
      
      -- Saindo Fora            
      commit;
      return;
      
  exception
     WHEN Dup_Val_on_Index THEN
    	  p_retorno := 'Erro. CNPJ Informado Ja Foi Eleito Para Esse Canal.';
          return;
     WHEN OTHERS THEN
    	Var_Log_Erro := 'Erro na Rotina '||Var_Crotna||'. Erro no Insert do Corretor Base. Erro => '||substr(SQLERRM,1,200);
        PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
        RAISE;     	  
  end;
EXCEPTION
  WHEN OTHERS THEN
    Var_Log_Erro := 'Erro na tentativa de inserir corretores eleitos.'||' canal: '||p_canal||' Erro: '||substr(SQLERRM,1,200);
    PR_GRAVA_MSG_LOG_CARGA(Var_Crotna,Var_Log_Erro,Pc_Util_01.Var_Log_Processo,NULL,NULL);
    RAISE;
END SGPB0167;
/

