create or replace trigger tr_tab_pessoa_insert
before insert on tab_pessoa
for each row
begin
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
			  'INCLUSAO');
	exception
		when others then
			raise_application_error(-20000,'Ocorreu um erro na trigger tr_tab_pessoa_insert '||
									sqlerrm(sqlcode));
	end;
end;

create or replace trigger tr_tab_pessoa_update
before update on tab_pessoa
for each row
begin
	:new.dt_alteracao := sysdate;
	begin
		insert
		  into tab_pessoa_log
			 ( matricula,
			   data_hora,
			   usuario,
			   evento)
		values
			( :old.matricula,
			  sysdate,
			  user,
			  'ALTERACAO');
	exception
		when others then
			raise_application_error(-20000,'Ocorreu um erro na trigger tr_tab_pessoa_insert '||
									sqlerrm(sqlcode));
	end;
end;
