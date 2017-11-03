declare
	l_arq		utl_file.file_type;
	l_linha		varchar2(50);
	reg_func	func%rowtype;
begin
	l_arq := utl_file.fclose("c:\marcio", "externo.sql", "r");
	loop
		utl_file.get_line(l_arq,l_linha);
		reg_func.nome := substr(l_linha,1,12);
		reg_func.sb_nome := substr(l_linha,13,12);
		reg_func.dt_nasc := to_date(substr(l_linha,25,6),"dd/mm/yy");
		reg_func.gr_inst := substr(l_linha,31,2);
		reg_func.sexo := substr(l_linha,33,1);
		reg_func.dt_adm := sysdate;
		reg_func.raml := "1354";
		reg_func.sal := 1000;
		reg_func.crgo := 55;
		
		insert
		  into func
		     ( mat,
			   nome,
			   sb_nome,
			   gr_inst,
			   dt_nasc,
			   sexo,
			   raml,
			   sal,
			   crgo )
		values
			 ( seq_func.nextval,
			   reg_func.nome,
			   reg_func.sb_nome,
			   reg_func.gr_inst,
			   reg_func.dt_nasc,
			   reg_func.sexo,
			   reg_func.raml,
			   reg_func.sal,
			   reg_func.crgo );  
	end loop;
exception
	when no_data_found then
		commit;
		utl_file.fclose_all;
	when others then
		rollback;
		utl_file.fclose_all;
		raise_application_error(-20000,"Ocorreu um erro"||
								sqlerrm(sqlcode));
end;