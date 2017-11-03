/*inserindo a partir de um arq externo*/

create procedure prc_import
is 
	l_arq 		utl_file.file_type;
	l_linha 	varchar2(100);
	reg_func	func%rowtype;
begin
	--abre o arquivo para leitura 'r'
	l_arq := utl_file.fopen('c:\marcio','teste.txt','r');
	loop
		utl_file.get_line(l_arq,l_linha);
		reg_func.mat := to_number(substr(l_linha,1,6));
		reg_func.nome := substr(l_linha,6,20);
/*LER TODAS AS LINHAS,
JOGA OS VALORES NAS VARIAVEIS 
INSERE NO BANCO*/
	end loop;
exception 
	when no_data_found then
		commit;
		utl_file_close_all;
	when others then
		utl_file_close_all;
		raise_application_error (-2000, 'Ocorreu um erro '||
								 sqlerrm(sqlcode));
end;

/*criando um arq externo*/

create or replace procedure prc_export
is 
	cursor cur_func
	is  ( select cd_mat,
				 nome,
				 vl_sal
		    from func );
	reg_func	cur_func%rowtype;
	l_carta		utl_file.file_type;
begin
	for reg_func in cur_func
	loop
		--abre o arquivo para gravação 'w'
		l_carta := utl_file.fopen('c:\marcio',reg_func.nome||'.txt', 'w'); 
		utl_file.put_line(l_carta, reg_func.cd_mat);--escreve no arquivo e pula uma linha 
		utl_file.put_line(l_carta, reg_func.nome);
		utl_file.put_line(l_carta, reg_func.vl_sal);
		utl_file.fflush(l_carta);--grava o arquivo
		utl_file.fclose(l_carta);--fexa o arquivo
	end loop;
end;
