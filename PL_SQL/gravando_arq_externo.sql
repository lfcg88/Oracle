create or replace procedure GERA_LOADER_CTL (diretorio varchar2, owner varchar2, tabela varchar2) is 
v_tab   varchar2(50):= tabela;
v_schema varchar2(100):= owner;
v_directory varchar2(50):= diretorio;
v_arq		utl_file.file_type;
cursor c1 is
 select ' '||column_name || decode(data_type,'DATE',' DATE "yyyy-mm-dd hh24:mi:ss"') ||
decode(lead(owner) over (partition by owner order by column_id),null,'',',') tabdesc 
         from dba_tab_columns t
         where owner=v_schema
         AND TABLE_NAME=v_tab
         order by column_id;
BEGIN
   v_arq := utl_file.fopen(v_directory, v_tab||'.ctl', 'w'); --abri o arquivo para escrita
   utl_file.put_line(v_arq,'load data');--escreve no arquivo sem pular linha 
	  -- pula uma linha no arquivo
   utl_file.put_line(v_arq,'CHARACTERSET WE8MSWIN1252');   
   utl_file.put_line(v_arq,'infile '||'''/home/oracle/migracao/unl/'||v_tab ||'.unl''');
   utl_file.put_line(v_arq,'badfile '||'''/home/oracle/migracao/bad/'||v_tab ||'_bad.unl''');
   utl_file.put_line(v_arq,'insert');
   utl_file.put_line(v_arq,'continueif last preserve != ''{''');
   utl_file.put_line(v_arq,'into table '||v_schema||'.'||v_tab);
   utl_file.put_line(v_arq,'fields TERMINATED BY "{" trailing nullcols ');
   utl_file.put_line(v_arq,'(');
   for reg in c1 loop
      if v_tab = 'AGENTE' and reg.tabdesc = ' OBS' then
        utl_file.put_line(v_arq,reg.tabdesc|| ' CHAR(3000) TERMINATED BY ''{''');
      else
        utl_file.put_line(v_arq,reg.tabdesc);
      end if;
   end loop;
   utl_file.put_line(v_arq,')');
   utl_file.fflush(v_arq); --salva tudo o que foi escrito no arquivo
   utl_file.fclose(v_arq); -- fecha o arquivo
end;
/
