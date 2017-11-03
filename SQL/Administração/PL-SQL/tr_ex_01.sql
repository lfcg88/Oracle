create or replace trigger tr_log_emp_iud_1 before
insert or update or delete of salary on employees
for each row 
declare 
	l_op	char(1);
begin
	if( inserting )
	then
		l_op := 'I';
	elsif
		( updating )
	then
		l_op := 'A';
	else
		l_op := 'D';
	end if;
	
	if( l_op = 'I' )
	then
		begin
			insert 
			  into log_emp
				 ( id_log_emp,
				   mat,
				   operacao,
				   vlr_atl,
				   vlr_ant,
				   dta )
			values
				 ( seq_log_emp.nextval,
				   :new.employee_id,
				   l_op,
				   :new.salary,
				   null,
				   sysdate );
		exception
			when others then
				raise_application_error(-20000,'Ocorreu um erro na tr_log_emp entre em... '||
										sqlerrm(sqlcode));
		end;
	elsif
	    ( l_op = 'A' )
	then
		begin
			insert 
			  into log_emp
				 ( id_log_emp,
				   mat,
			       operacao,
				   vlr_atl,
				   vlr_ant,
				   dta )
			values
			     ( seq_log_emp.nextval,
			       :new.employee_id,
			       l_op,
			       :new.salary,
			       :old.salary,
			       sysdate );
		exception
			when others then
				raise_application_error(-20000,'Ocorreu um erro na tr_log_emp entre em... '||
										sqlerrm(sqlcode));
		end;
	else
		begin
			insert 
			  into log_emp
			     ( id_log_emp,
				   mat,
			       operacao,
			       vlr_atl,
			       vlr_ant,
			       dta )
		    values
			     ( seq_log_emp.nextval,
			       :old.employee_id,
			       l_op,
			       null,
			      :old.salary,
			       sysdate );
		exception
			when others then
				raise_application_error(-20000,'Ocorreu um erro na tr_log_emp entre em... '||
									 sqlerrm(sqlcode));
		end;
	end if; 
exception
	when others then
		raise_application_error(-20000,'Ocorreu um erro na tr_log_emp entre em... '||
								sqlerrm(sqlcode));
end;


--NECESSÁRIO PARA TESTAR TRIGGER ACIMA--

create table log_emp(
	id_log_emp	number(6) 	primary key,
	mat			number(6) 	not null,
	operacao	char(1) 	not null,
	vlr_atl		number(8,2)		 	,
	vlr_ant		number(8,2)			,
	dta			date				
);

create sequence seq_log_emp
	increment by 1
	start with 1;
	
insert
  into employees
     ( employee_id,
	   last_name,
	   email,
	   hire_date,
	   job_id,
	   salary)
values
     ( 207,
	   'Marcio',
	   'marciobriso@hotmail.com',
	   '23/05/98',
	   'ST_MAN', 
	   2000 );

update employees
   set salary = 3000
 where employee_id = 207;
	   
delete
  from employees
 where employee_id = 207;

select *
  from log_emp;
  
--NECESSÁRIO PARA DELETAR OS OBJETOS CRIADOS

drop table log_emp;

drop sequence seq_log_emp;

drop trigger tr_log_emp_iud_1;
	   
	   
	   
	