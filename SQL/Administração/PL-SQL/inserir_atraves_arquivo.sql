/*LENDO DADOS DE UM ARQUIVO EXTERNO
E ADICIONANDO NO BD*/

declare 
	l_arq		utl_file.file_type;
	l_linha 	varchar2(50);
	reg_1		projatv%rowtype;
begin
--o ultimo parametro significa o modo do arquivo "r" para leitura, "w" para grava��o
--"a" para criar um arquivo ou adicionar linhas ao fim de um arquivo existente
	l_arq := utl_file.fopen('c:\marcio', 'carga.sql', 'r');
--o loop sera feito ate cair na excess�o no_data_found 
--onde indica que n�o h� mais linhas no arquivo	
	loop
--lendo a linha N do arquivo(l_arq) e colocando o seu valor na variavel(l_linha)
		utl_file.get_line(l_arq, l_linha);
		reg_1.cd_proj := substr(l_linha,1,6);--recebe da 1� posi��o a 6�
		reg_1.cd_ativ := substr(l_linha,7,3);--recebe da 7� posi��o a 9�
		reg_1.dt_ini := to_date(substr(l_linha,10,10),'dd/mm/yyyy');--recebe da 10� posi��o a 19�
		reg_1.dt_fim := to_date(substr(l_linha,20,10),'dd/mm/yyyy');--recebe da 20� posi��o a 29�
		insert 
		  into projatv
			 ( cd_proj,
			   cd_ativ,
			   dt_ini,
			   dt_fim )
		values
			 ( reg_1.cd_proj,
			   reg_1.cd_ativ,
			   reg_1.dt_ini,
			   reg_1.dt_fim );
	end loop;
exception 
/*quando chegar ao fim do arquivo entrar� na excess�o
onde ser� comitada todas as transa��es
e o arquivo sera fechado*/
	when no_data_found then
		commit;
		utl_file.fclose_all;
end;

create table projatv(
	cd_proj		char(6) primary key,
	cd_ativ		char(3),
	dt_ini		date,
	dt_fim		date
);