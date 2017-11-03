create or replace trigger tr_emp_iu_1 before
insert or update on func
referencing 	new as n
for each row
declare 
	e_error		exception;
	l_msg 		varchar2(100) := '';
begin
	if ( length(:n.ramal) <> 4  )
	then
		l_msg := l_msg || 'Digite um valor valido para o ramal; '; 
		raise e_error; 
	elsif
	    ( :n.sal <= 500 )
	then
		l_msg := l_msg || 'Digite um valor valido para o salario; ';
		raise e_error;
	elsif
	    ( to_number(to_char(:n.dt_nasc,'yy')) <= 50 )
	then
		l_msg := l_msg || 'Digite um valor valido para a data-nascimento; ';
		raise e_error;
	else
		:n.nome := upper(:n.nome);
		:n.sb_nome := upper(:n.sb_nome);
	end if;
exception
	when e_error then
		raise_application_error(-20000, l_msg||
								sqlerrm(sqlcode));
	when others then
		dbms_output.put_line('Ocorreu um erro entre em contato... '||
							 sqlerrm(sqlcode));
end;

--USADO PARA TESTAR A TRIGGER

create table func(
	mat		number(6) 		primary key,
	nome	varchar2(10)	not null,
	sb_nome varchar2(10)	not null,
	ramal	char(4)			not null,
	sal		number(8,2)		not null,
	dt_nasc	date			not null
);

create sequence seq_func
	increment by 1
	start with 1;

insert 
  into func
values
	 ( seq_func.nextval,
	   'Marcio',
	   'Briso',
	   '1234',
	   1000,
	   '21/02/87');

update func
   set ramal = '123'
   where mat = 3;
   
update func
   set sal = 500
   where mat = 3;
   
update func
   set dt_nasc = '21/02/49'
   where mat = 3;
   
insert 
  into func
values
	 ( seq_func.nextval,
	   'Luiz',
	   'Felipe',
	   '1234',
	   501,
	   '21/02/51');
	   
select *
  from func;
  
drop trigger tr_emp_iu_1; 
drop table func; 
drop sequence seq_func;