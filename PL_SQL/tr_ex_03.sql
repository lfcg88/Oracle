create or replace trigger tr_emp_i_1 
before insert on func
for each row 
declare
	l_qtde			number;
	l_dpto 			func.dpto_id%type;
begin
	if ( :new.mat is null )
	then
--o comando abaixo é para adquirir o novo valor da sequencia e colocar na nova matricula
		select seq_func.nextval
		  into :new.mat
		  from dual;
	end if;
	if ( :new.sal is null )
	then
		if ( :new.crgo <= 40 )
		then
			:new.sal := 1000;
		else
			:new.sal := 1000 +(mod(:new.crgo, 40) * 300);
		end if;
	end if;
	if ( :new.dpto_id is null )
	then
		begin
			select department_id,
				   count(*)
			  into l_dpto ,
				   l_qtde
			  from employees
		  group by department_id
	      order by 2 ;
		exception
			when too_many_rows then
				:new.dpto_id := l_dpto;
			when others then
				raise_application_error(-20000,sqlerrm(sqlcode));
		end;
	end if;
	:new.dt_adm := sysdate;
	:new.nome := upper(:new.nome);
	:new.sb_nome := upper(:new.sb_nome);
exception
	when others then
		raise_application_error(-20000,sqlerrm(sqlcode));
	
end;


--USADO PARA TESTAR A TRIGGER

create table func(
	mat		number(6) 		primary key,
	nome	varchar2(10)	not null,
	sb_nome	varchar2(10)	not null,
	crgo	number(2)		not null,
	sal		number(8,2),
	dt_adm	date,
	dpto_id	number(4)
);

alter table func add constraint fk_departments_func
	foreign key (dpto_id)
	references departments (department_id);

create sequence seq_func
	increment by 1
	start with 1;

insert 
  into func
     ( mat,
	   nome,
	   sb_nome,
	   crgo,
	   sal,
	   dt_adm,
	   dpto_id )
values 
	 ( null,
       'marcio',
	   'briso',
	   40,
	   null,
	   null,
	   null);
	   
insert 
  into func 
values 
	 ( null,
       'luiz',
	   'felipe',
	   42,
	   null,
	   null,
	   null);
	   
insert 
  into func 
values 
	 ( null,
       'Antonio',
	   'Pereira',
	   44,
	   null,
	   null,
	   null);