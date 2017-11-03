create or replace procedure prc_teste 
is 
	l_msg		varchar2(30);
begin

	delete 
	  from interf_pessoa;
	
	if ( sql%notfound )--usado para saber si a query deletou algum registro
	then
		l_msg := 'não deletou ninguem!!';
	else 
		l_msg := 'deletou';
	end if;
	if ( l_msg is not null )
	then
		dbms_output.put_line(l_msg);
	end if;
exception 
	when others then
		raise_application_error(-20000,'erro!!');
end;
	
