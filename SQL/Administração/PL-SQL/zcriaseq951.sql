declare
  valor int;
  cont int;
  cmdsql varchar2(255);
begin
  select count(1) into cont from user_sequences where sequence_name = 'BOL_SEQ';
  if cont > 0 then 
    cmdsql := 'DROP SEQUENCE BOL_SEQ';
    execute immediate cmdsql;
  end if;
  select nvl(max(IdBOL), 0) + 1 into valor from Bol;
  cmdsql := 'CREATE SEQUENCE BOL_SEQ START WITH '|| to_char(valor);
  execute immediate cmdsql;
  end;

/

