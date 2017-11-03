create or replace trigger tr_tab_pessoa_iu
before insert or update on tab_pessoa
for each row
begin
	if ( inserting )
	then
		:new.dt_inclusao := sysdate;
		:new.dt_alteracao := sysdate;
		begin
			insert
			  into tab_pessoa_log
				 ( matricula,
				   data_hora,
				   usuario,
				   evento )
			values
				 ( :new.matricula,
				   sysdate,
				   user,
				   'INCLUSAO' );
		exception
			when others then
				raise_application_error(-20000,'Ocorreu um erro na trigger 
										tr_tab_pessoa_iu, quando foi efetuada
										uma inclus�o'||
										sqlerrm(sqlcode));
		end;
	else 
		:new.dt_alteracao := sysdate;
		begin
			insert
			  into tab_pessoa_log
				 ( matricula,
				   data_hora,
				   usuario,
			       evento )
			values
				 ( :old.matricula,
				   sysdate,
				   user,
				   'ALTERACAO');
		exception
			when others then
				raise_application_error(-20001,'Ocorreu um erro na trigger 
										tr_tab_pessoa_iu, quando foi efetuada
										uma altera��o'||
										sqlerrm(sqlcode));
		end;
	end if;
end;