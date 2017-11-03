declare

function calculo_intervalo_tarefas (v_prli_num_sol scl_tarefa_eventual.prli_num_sol%type) return real as 
  TYPE T_Intervalo IS RECORD (
  	   Suspensao date, 
	   Retorno date);
  TYPE Table_Intervalos IS table OF T_Intervalo index by pls_integer;
  Intervalos Table_Intervalos;
  soma real;

function busca_sobreposicao (Suspensao date, Retorno date) return pls_integer as
begin 
  if Intervalos.count = 0 then
    return(0);
  end if;	
  for i in Intervalos.first .. Intervalos.last
  loop
    if suspensao >= Intervalos(i).Suspensao and suspensao <= Intervalos(i).Retorno then
	  return (i);
    end if;
  end loop;
  return (0);
end busca_sobreposicao;	

procedure insere_Intervalo (Suspensao date, Retorno date) as
  proximo pls_integer;
  indice_sobreposicao pls_integer;
begin
  indice_sobreposicao:= busca_sobreposicao (suspensao, Retorno);
  proximo:= Intervalos.count+1;
  if indice_sobreposicao = 0 then
    Intervalos(proximo).suspensao:= suspensao;
    Intervalos(proximo).retorno:= retorno;
  else
    if Retorno >= Intervalos(indice_sobreposicao).retorno then
	  Intervalos(indice_sobreposicao).retorno:= retorno;
    end if;
  end if;		  
end insere_Intervalo;

function soma_intervalos return real as 
  soma real:= 0;
begin
  if Intervalos.count > 0 then
    for i in Intervalos.first .. Intervalos.last
    loop
--     dbms_output.put_line ('Suspensão = ' || to_char (Intervalos(i).Suspensao,'dd/mm/yyyy hh24:mi:ss') || '- Retorno = ' || to_char (Intervalos(i).Retorno,'dd/mm/yyyy hh24:mi:ss')); 
      soma:= soma+ Intervalos(i).Retorno - Intervalos(i).Suspensao;
    end loop;
  end if;	
  return (soma);
end soma_intervalos;	

procedure popula_intervalos (V_PRLI_NUM_SOL SCL_TAREFA_EVENTUAL.prli_num_sol%type) as
  cursor c_Intervalos_tarefas (V_PRLI_NUM_SOL SCL_TAREFA_EVENTUAL.prli_num_sol%type) is  
  SELECT NVL(TAEV_DAT_RETORNO, sysdate) as  retorno, TAEV_DAT_SUSPENSAO as suspensao
            FROM  SCL_TAREFA_EVENTUAL 
			WHERE PRLI_NUM_SOL = V_PRLI_NUM_SOL;
  Linha_Intervalos c_Intervalos_Tarefas%Rowtype;			
			
begin
  open c_Intervalos_tarefas (V_PRLI_NUM_SOL);
  
  loop
    fetch c_Intervalos_tarefas into Linha_Intervalos;
    exit when c_Intervalos_tarefas%notfound;
    insere_Intervalo (Linha_Intervalos.Suspensao, Linha_Intervalos.retorno);
  end loop;

close c_Intervalos_tarefas;			
end popula_intervalos;

	   
begin
  popula_intervalos (v_prli_num_sol);
    		 
  return (soma_intervalos);
  
end calculo_intervalo_tarefas;

begin

  dbms_output.put_line ('soma = ' || calculo_intervalo_tarefas(800050500008));
end;  
