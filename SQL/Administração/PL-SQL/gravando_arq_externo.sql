/*TRANSFERINDO DADOS PARA UM ARQUIVO EXTERNO*/

declare 
	l_carta		utl_file.file_type;
	l_hoje 		varchar2 := to_char(sysdate,'dd/mm/yy');
	cursor cur_func
	   ( p_mes in number ) 
	is   select nm_func,
				ltrim(to_char(vl_sal/5,'999g990d00')) vl_sal,
				to_char(dt_nasc, 'dd/mm') dt_nasc
		   from func
		  where to_number(to_char(dt_nasc,'mm')) = p_mes
	   order by cd_mat;
	reg_func	cur_func%rowtype;
begin
	for reg_func in cur_func(&mes)
	loop
		l_carta := utl_file.fopen('c:\marcio', reg_func.nm_func||'.txt', 'w');
		utl_file.put(l_carta,'Rio de Janeiro '||l_hoje);--escreve no arquivo sem pular linha 
		utl_file.new_line(l_carta,2);--pula uma linha no arquivo l_carta
		utl_file.put(l_carta,'Prezado(a) Senhor(a) '||reg_func.nm_func);
		utl_file.new_line(l_carta,2);
--escreve no arquivo e pula para a proxima linha
		utl_file.put_line(l_carta,'Parabéns pelo seu aniversario dia '||reg_func.dt_nasc);
		utl_file_put(l_carta,'Seu presente será uma bonificação de ');
--substitui o %s pela variavel apos a virgula
		utl_file_putf(l_carta,'R$ %s no ',reg_func.vl_sal);
		utl_file.new_line(l_carta);
		utl_file.put(l_carta,'mes subsequente');
		utl_file.new_line(l_carta,2);
		utl_file.put_line(l_carta,'Dpto Pessoal');
--salva tudo o que foi escrito de fato no arquivo
		utl_file.fflush(l_carta);
--fecha o arquivo
		utl_file.fclose(l_carta);
	end loop;
end;

--O ARQUIVO FICARA NO SEGUINTE FORMATO 
/* Rio de Janeiro xx/xx/xxxx 

Prezado(a) Senhor(a) xxxxxxxxxx.
Seu presente sera uma bonificação de R$ XXX.XXX,XX no
mês subsequente.

Dpto Pessoal.*/
