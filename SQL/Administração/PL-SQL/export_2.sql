declare 
	l_arq		utl_file.file_type;
	l_linha		varchar2(50);
	cursor cur_func
	is ( select cd_mat,
				nm_func,
				sb_nome,
				dt_nasc,
				vl_sal
		   from func );
	reg_func	func%rowtype;
begin
	for reg_func in cur_func
	loop
		l_arq := utl_file.fopen("c:\marcio", reg_func.nm_func||".sql","w");
		utl_file.put(reg_func.cd_mat||", ");
		utl_file.put(reg_func.nm_func||", ");
		utl_file.put(reg_func.sb_nome||", ");
		utl_file.put(reg_func.dt_nasc||", ");
		utl_file.put(reg_func.vl_sal||".");
		utl_file.fflush(l_arq);
		utl_file.fclose(l_arq);
	end loop;
end;
			    