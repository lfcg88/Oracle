/*procedure para atualizar através da
linha corrente do cursor*/
create or replace procedure prc_teste 
is 
	cursor cur_func
	is    select vl_sal
	        from func
   for update of vl_sal, status ;
	reg_func	cur_func%rowtype;
begin
	for reg_func in cur_func
	loop
		if ( reg_func.vl_sal < 3000 )
		then
			update func
			   set vl_sal = vl_sal * 1.3,
			       status = 'ALTERADO'
			 where current of cur_func;
		end if;
	end loop;
end;

/*procedure para deletar através da
linha corrente do cursor*/
create or replace procedure prc_teste2
is 
	cursor cur_func
	is    select status
	        from func
      for update;
	reg_func	cur_func%rowtype;
begin
	for reg_func in cur_func
	loop
		if ( reg_func.status = 'ALTERADO' )
		then
			delete 
			  from func
			 where current of cur_func;
		end if;
	end loop;
	commit;
end;

--necessario para testar as procedures
create table func (
	cd_mat		number(6) primary key,
	nome		varchar2(20),
	vl_sal		number(8,2),
	status		varchar2(20)
);

create sequence seq_func
	increment by 1
	start with 1;

insert 
  into func
values
	 ( seq_func.nextval,'Marcio',2000, null );

insert 
  into func
values
	 ( seq_func.nextval,'Maria',3000, null );
	  
insert 
  into func
values
	 ( seq_func.nextval,'Thiago',1000, null ),
	   
insert 
  into func
values	   
	 ( seq_func.nextval,'Luciano',2000, null );
	   
insert 
  into func
values
	 ( seq_func.nextval,'Edmar',4000, null );
	 
insert 
  into func
values
	 ( seq_func.nextval,'Eduardo',5000,null );
	 
insert 
  into func
values
	 ( seq_func.nextval,'Jose',2000,null );
	 
insert 
  into func
values
	 ( seq_func.nextval,'Marcia',4000,null );