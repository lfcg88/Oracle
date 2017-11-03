
declare
 
  cursor V_CURSOR is 
    select table_name, column_name,data_type,data_precision, data_scale, data_length,nullable
      from all_tab_columns where table_name LIKE 'VW%'
      ORDER BY TABLE_NAME,COLUMN_ID;
	  
  
  table_name varchar2(30);
  table_name_ant varchar2(30):= ' ';
  column_name varchar2(30);
  data_type varchar2(30);
  data_precision number;
  data_scale number;
  data_length number;
  nullable char(1);
  
  column_decl varchar2(100);
  conta pls_integer := 0;

 
begin
open V_CURSOR;
loop
  fetch V_CURSOR into table_name, column_name,data_type,data_precision, data_scale, data_length,nullable;
  exit when v_cursor%notfound;
 
  column_decl := column_name || ' ' || data_type || ' '; 
  if data_type not in ('DATE','BLOB','CLOB','ROWID') then
    column_decl:= column_decl || '(';
    if data_precision is null then
	  column_decl:= column_decl ||  to_char(data_length);
    else
        column_decl:= column_decl ||  to_char(data_precision) || ',' || to_char(data_scale);
    end if;
    column_decl:= column_decl || ')';
  end if;
  if nullable = 'Y' then    			
    column_decl:= column_decl || ' NULL';
  else
    column_decl:= column_decl || ' NOT NULL';
  end if;	

  conta:= conta+1;
  if table_name <> table_name_ant then
    if conta > 1 then
	  dbms_output.put_line (');');
	end if;
    dbms_output.put_line ('CREATE TABLE ' || table_name || '(');
 	dbms_output.put_line ('   ' || column_decl);
	table_name_ant:= table_name;
  else
  	dbms_output.put_line ('  ,' || column_decl);
  end if;
end loop;

if conta > 0 then  
  	  dbms_output.put_line (');');
end if;
end;
/	  
  
  


 
