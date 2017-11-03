create or replace procedure prc_questao01 
is 
	l_arq			utl_file.file_type;
	reg_interf		interf_pessoa%rowtype;
	l_linha			varchar2(70);
	l_cont			number := 0;
	l_msg			varchar2(100);
begin
	delete
	  from interf_pessoa;
	delete
	  from interf_pessoa_erro;
	l_arq := utl_file.fopen('c:\temp\curso','pessoa.txt','r');
	loop
	--lendo a linha do arquivo(l_arq) e colocando o valor na variavel(l_linha)
		utl_file.get_line(l_arq,l_linha);
		l_msg := '';
		l_cont := l_cont + 1;
		begin
			reg_interf.matricula := to_number((substr(l_linha,1,6)));
		exception
			when others then
				l_msg := l_msg || 'Erro na Conversão da Matricula ';
				dbms_output.put_line(l_msg||sqlerrm(sqlcode));
		end;
		begin
			reg_interf.nome := substr(l_linha,7,45);
		exception
			when others then
				l_msg := l_msg || 'Erro na Extração do Nome ';
				dbms_output.put_line(l_msg||sqlerrm(sqlcode));
		end;
		begin
			reg_interf.cpf := to_number((substr(l_linha,52,11)));
		exception
			when others then
				l_msg := l_msg || 'Erro na Conversão do CPF ';
				dbms_output.put_line(l_msg||sqlerrm(sqlcode));
		end;
		begin
			reg_interf.dt_nascimento := to_date(substr(l_linha,63,8),'dd/mm/yy');
		exception
			when others then
				l_msg := l_msg || 'Erro na Conversão da Data de Nascimento ';
				dbms_output.put_line(l_msg||sqlerrm(sqlcode));
		end;
		-- se a variavel não estiver vazia e pq ocorreu algum erro, logo
		--o erro e gravado na tabela de erros
		if ( l_msg is not null  )
		then
			insert
			  into interf_pessoa_erro
			     ( num_registro,
				   msg_erro )
			values
				 ( l_cont,
				   l_msg );
		--caso não tenha ocorrido nenhum erro, é gravado uma linha na tabela interf_pessoa
		else
			insert
			  into interf_pessoa
			     ( matricula,
				   nome,
				   cpf,
				   dt_nascimento,
				   status,
				   msg_erro )
			values
			     ( reg_interf.matricula,
				   reg_interf.nome,
				   reg_interf.cpf,
				   reg_interf.dt_nascimento,
				   'A PROCESSAR',
				   null ); 
		end if;
	end loop;
exception 
--quando chegar ao final do arquivo txt, levanta a excessão no_data_found,
--onde o erro e tratado, é efetuado um commit e o fechamento do arquivo  
	when no_data_found then
		commit;
		utl_file.fclose_all;
	when others then
		rollback;
		raise_application_error(-20000,'Ocorreu um erro '||
								sqlerrm(sqlcode));
end;