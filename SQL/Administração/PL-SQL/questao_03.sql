create or replace procedure prc_questao03 
is 
	cursor cur_interf
	is   select matricula,
				nome,
				cpf,
				dt_nascimento
		   from interf_pessoa
		  where status = 'A PROCESSAR'
  for update of status, msg_erro;
	reg_interf		cur_interf%rowtype;
	l_msg			varchar2(100) := '';
begin
	open cur_interf;
	loop
		fetch cur_interf into reg_interf;
		if ( cur_interf%notfound )-- usa-se para saber chegou ao fim do cursor 
		then
			l_msg := '';
			exit;
		else
			l_msg := '';
			if ( ((months_between(sysdate,reg_interf.dt_nascimento))/12) < 21 )
			then
				l_msg := l_msg|| 'Pessoa não tem 21 anos completos ';
			end if;
			if (not valida_cpf(reg_interf.cpf)) 
			then
				l_msg := l_msg||'CPF inválido ';
			end if;
			if (l_msg is not null)
			then
				update interf_pessoa
				   set status = 'ERRO',
					   msg_erro = l_msg
				 where current of cur_interf;
			else
				begin
					insert
					  into tab_pessoa
					     ( matricula,
						   nome,
						   cpf,
						   dt_nascimento )
					values
					     ( reg_interf.matricula,
						   reg_interf.nome,
						   reg_interf.cpf,
						   reg_interf.dt_nascimento );
				
					update interf_pessoa
					   set status = 'PROCESSADO'
					 where current of cur_interf;
			
				exception
					when dup_val_on_index then
						update interf_pessoa
						   set status = 'ERRO',
						       msg_erro = 'Matricula já existente'
						 where current of cur_interf;
				end;	   
			end if;
		end if;
	end loop;
	commit;
	close cur_interf;
exception	
	when others then
		close cur_interf;
		--efetua um rollback em todas as operações que não tenham cido comitadas
		--e envia uma mensagem de erro para o usuario
		raise_application_error(-20000, 'Ocorreu um erro na procedure prc_questao03 '||
						   sqlerrm(sqlcode));
end;

