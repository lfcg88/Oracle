alter session set current_schema = plsqldemo;


CREATE OR REPLACE FUNCTION PLSQLDEMO.Tablespace_Datafiles (Ts_Name in varchar)
RETURN sys_refcursor
AS
  v1 sys_refcursor;
BEGIN
  open v1 for select file_name from dba_data_files where tablespace_name = Ts_Name; 

  return (v1);
end Tablespace_Datafiles;
/

set serveroutput on 

declare
  V_CURSOR sys_refcursor;
  datafile_name varchar(512);
BEGIN
  dbms_output.put_line ('inicio');
  v_cursor := plsqldemo.Tablespace_Datafiles ('TOOLS'); 
  loop
    fetch v_cursor into  datafile_name; 
    exit when v_cursor%notfound;
    dbms_output.put_line (datafile_name); 
  end loop;
    dbms_output.put_line ('fim');
END;
/

Resposta:
inicio
D:\ORACLE\ORADATA\GENERICO\DF_TOOLS_D_01.DBF
fim


create table funcionario
 (matricula number (10) not null,
  nome varchar2(50) not null
);

CREATE TABLE LOG_ERRO_APLIC
(
  DT_LOG           DATE                         DEFAULT sysdate               NOT NULL,
  DS_REFER_OBJ     VARCHAR2(60 BYTE)            NOT NULL,
  CD_ERRO          NUMBER(10),
  TX_TEXTO_ERRO    VARCHAR2(256 BYTE)           NOT NULL,
  TX_LOGIN_OPERAD  VARCHAR2(30 BYTE)            NOT NULL,
  DS_APLIC         VARCHAR2(60 BYTE),
  NM_ESTAC         VARCHAR2(60 BYTE)            NOT NULL
);

CREATE OR REPLACE PROCEDURE SP_LOG_ERRO (
      V_DS_REFER_OBJ IN LOG_ERRO_APLIC.ds_refer_obj%TYPE,
      V_TX_TEXTO_ERRO IN LOG_ERRO_APLIC.tx_texto_erro%TYPE,
      V_CD_ERRO IN LOG_ERRO_APLIC.cd_erro%TYPE,
      V_DS_APLIC IN LOG_ERRO_APLIC.ds_aplic%TYPE
      )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
  V_TX_TEXTO_ERRO_W LOG_ERRO_APLIC.tx_texto_erro%TYPE;
BEGIN
  IF LENGTH(V_TX_TEXTO_ERRO) > 256 THEN
    V_TX_TEXTO_ERRO_W := SUBSTR(V_TX_TEXTO_ERRO,1,256);
  ELSE
    V_TX_TEXTO_ERRO_W := V_TX_TEXTO_ERRO;
  END IF;
  INSERT INTO LOG_ERRO_APLIC
   (DS_REFER_OBJ,CD_ERRO,TX_TEXTO_ERRO,TX_LOGIN_OPERAD,DS_APLIC,NM_ESTAC)
   VALUES(V_DS_REFER_OBJ,V_CD_ERRO,V_TX_TEXTO_ERRO_W,SYS_CONTEXT('USERENV','SESSION_USER'),V_DS_APLIC ,SYS_CONTEXT('USERENV','TERMINAL'));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END SP_LOG_ERRO;
/

create or replace procedure SP_INSERT_FUNCIONARIO (v_matricula in funcionario.matricula%type, v_nome in funcionario.nome%type) as
-- VARIÁVEIS PADRÕES
  V_MINHA_EXCECAO EXCEPTION;
  V_PROCNAME CONSTANT VARCHAR(30) := 'SP_INSERT_FUNCIONARIO';
  V_MSG_ERRO_APLIC VARCHAR2(255) :=  'Erro de aplicação';
  V_CD_ERRO_APLIC BINARY_INTEGER := -20000; 
begin
  if v_matricula  is null then
    V_CD_ERRO_APLIC:= -20001;
    V_MSG_ERRO_APLIC:= 'Matrícula do funcionário é obrigatória'; 
    RAISE V_MINHA_EXCECAO;
  end if;	

  if v_nome is null then
    V_CD_ERRO_APLIC:= -20002;
    V_MSG_ERRO_APLIC:= 'Nome do funcionário é obrigatório'; 
    RAISE V_MINHA_EXCECAO;
  end if;	
  
  insert into funcionario (nome, matricula) values (v_nome, v_matricula);


EXCEPTION
  WHEN V_MINHA_EXCECAO THEN
    SP_LOG_ERRO (V_PROCNAME,V_MSG_ERRO_APLIC,V_CD_ERRO_APLIC,NULL);
    RAISE_APPLICATION_ERROR (V_CD_ERRO_APLIC,V_PROCNAME || ' - ' || V_MSG_ERRO_APLIC,true);
  WHEN PROGRAM_ERROR THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN TOO_MANY_ROWS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN DUP_VAL_ON_INDEX THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN OTHERS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
END SP_INSERT_FUNCIONARIO;
/  


--inserção de funcionário

exec SP_INSERT_FUNCIONARIO (v_matricula => 987639 , v_nome => 'José das Couves');
commit;

select * from plsqldemo.funcionario;

-- Resposta
 MATRICULA NOME                                              
---------- --------------------------------------------------
    987639 José das Couves         


--inserção de funcionário com erro - teste da rotina de excecão	
exec SP_INSERT_FUNCIONARIO (v_matricula => null, v_nome => 'José das Couves');
commit;

ou

begin SP_INSERT_FUNCIONARIO (v_matricula => null, v_nome => 'José das Couves'); end;
commit;



-- Resposta 
ORA-20001: SP_INSERT_FUNCIONARIO - Matrícula do funcionário é obrigatória
ORA-06512: at "PLSQLDEMO.SP_INSERT_FUNCIONARIO", line 26
ORA-06510: PL/SQL: unhandled user-defined exception
ORA-06512: at line 1;


alter session set nls_date_format = 'DD/MM/YYYY HH24:MI:SS';
select * from plsqldemo.log_erro_aplic;

DT_LOG                   DS_REFER_OBJ                      CD_ERRO    TX_TEXTO_ERRO                             TX_LOGIN_OPERAD   DS_APLIC      NM_ESTAC
-----------------------  ----------------------------      ---------  -------------------------------------     ---------------   ---------     ----------------
23/06/2005 6:59:19 PM    SP_INSERT_FUNCIONARIO             -20001     Matrícula do funcionário é obrigatória    SYS               {null}        RJASTEC-01786                                                


CREATE OR REPLACE PROCEDURE SP_Select_Func_por_matricula (V_Cursor out sys_refcursor)
AS

BEGIN
  open V_Cursor for select * from funcionario order by matricula;  

end SP_Select_Func_por_matricula;
/

-- Insere mais funcionários 
exec SP_INSERT_FUNCIONARIO (v_matricula => 8490030, v_nome => 'Zezinho');
exec SP_INSERT_FUNCIONARIO (v_matricula => 4944944, v_nome => 'Huginho'); 
exec SP_INSERT_FUNCIONARIO (v_matricula => 4840392, v_nome => 'Luizinho');
commit;



set serveroutput on 

declare
  V_CURSOR sys_refcursor;
  reg_func funcionario%rowtype; 
BEGIN
  dbms_output.put_line ('inicio');
  plsqldemo.SP_Select_Func_por_matricula (V_CURSOR); 
  loop
    fetch v_cursor into  reg_func;
    exit when v_cursor%notfound;
    dbms_output.put_line ('Matricula = ' || to_char(reg_func.matricula) || ', nome = ' || reg_func.nome);
  end loop;
    dbms_output.put_line ('fim');
END;
/

-- Resposta
inicio
Matricula = 987639, nome = José das Couves
Matricula = 4840392, nome = Luizinho
Matricula = 4944944, nome = Huginho
Matricula = 8490030, nome = Zezinho
fim
PL/SQL procedure successfully completed.


CREATE OR REPLACE PROCEDURE SP_Select_Func_ordenado  (V_Cursor out sys_refcursor, ordem in number)
AS
  query varchar2(100);

BEGIN
  query := 'select * from funcionario order by ' || to_char(ordem);
  open V_Cursor for query;  

end SP_Select_Func_ordenado;
/

set serveroutput on
declare
  V_CURSOR sys_refcursor;
  reg_func funcionario%rowtype; 
BEGIN
  dbms_output.put_line ('inicio select func por matrícula');
  plsqldemo.SP_Select_Func_ordenado (V_CURSOR,1); 
  loop
    fetch v_cursor into  reg_func;
    exit when v_cursor%notfound;
    dbms_output.put_line ('Matricula = ' || to_char(reg_func.matricula) || ', nome = ' || reg_func.nome);
  end loop;
    dbms_output.put_line ('fim');
END;
/

inicio select func por matrícula
Matricula = 987639, nome = José das Couves
Matricula = 4840392, nome = Luizinho
Matricula = 4944944, nome = Huginho
Matricula = 8490030, nome = Zezinho
fim
PL/SQL procedure successfully completed.


set serveroutput on
declare
  V_CURSOR sys_refcursor;
  reg_func funcionario%rowtype; 
BEGIN
  dbms_output.put_line ('inicio select func por nome');
  plsqldemo.SP_Select_Func_ordenado (V_CURSOR,2); 
  loop
    fetch v_cursor into  reg_func;
    exit when v_cursor%notfound;
    dbms_output.put_line ('Matricula = ' || to_char(reg_func.matricula) || ', nome = ' || reg_func.nome);
  end loop;
    dbms_output.put_line ('fim');
END;
/

inicio select func por matrícula
Matricula = 987639, nome = José das Couves
Matricula = 4840392, nome = Luizinho
Matricula = 4944944, nome = Huginho
Matricula = 8490030, nome = Zezinho
fim
PL/SQL procedure successfully completed.


set serveroutput on
declare
  V_CURSOR sys_refcursor;
  reg_func funcionario%rowtype; 
BEGIN
  dbms_output.put_line ('inicio select func por xxxx');
  plsqldemo.SP_Select_Func_ordenado (V_CURSOR,3); 
  loop
    fetch v_cursor into  reg_func;
    exit when v_cursor%notfound;
    dbms_output.put_line ('Matricula = ' || to_char(reg_func.matricula) || ', nome = ' || reg_func.nome);
  end loop;
    dbms_output.put_line ('fim');
END;
/

ORA-01785: ORDER BY item must be the number of a SELECT-list expression
ORA-06512: at "PLSQLDEMO.SP_SELECT_FUNC_ORDENADO", line 7
ORA-06512: at line 6


-- Mesma procedure com tratamento de exceção  
  
CREATE OR REPLACE PROCEDURE SP_Select_Func_ordenado_exc  (V_Cursor out sys_refcursor, ordem in number)
AS
  query varchar2(100);
  ordernador_invalido exception;
  PRAGMA EXCEPTION_INIT (ordernador_invalido,-1785);
  V_MINHA_EXCECAO EXCEPTION;
  V_PROCNAME CONSTANT VARCHAR(30) := 'SP_Select_Func_ordenado_exc';
  V_MSG_ERRO_APLIC VARCHAR2(255) :=  'Erro de aplicação';
  V_CD_ERRO_APLIC BINARY_INTEGER := -20000; 

BEGIN
  begin	 
    query := 'select * from funcionario order by ' || to_char(ordem);
    open V_Cursor for query;
  exception
    when ordernador_invalido then
	    dbms_output.put_line ('Foi retirada a ordenação');
	    query := 'select * from funcionario'; -- sem ordenação 
        open V_Cursor for query;
    when others then
	    raise v_minha_excecao;
  end;		
  
exception
  WHEN V_MINHA_EXCECAO THEN
    SP_LOG_ERRO (V_PROCNAME,V_MSG_ERRO_APLIC,V_CD_ERRO_APLIC,NULL);
    RAISE_APPLICATION_ERROR (V_CD_ERRO_APLIC,V_PROCNAME || ' - ' || V_MSG_ERRO_APLIC,true);
  WHEN PROGRAM_ERROR THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN TOO_MANY_ROWS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN DUP_VAL_ON_INDEX THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN OTHERS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;

end SP_Select_Func_ordenado_exc;
/

set serveroutput on
declare
  V_CURSOR sys_refcursor;
  reg_func funcionario%rowtype; 
BEGIN
  dbms_output.put_line ('inicio select func por xxxx');
  plsqldemo.SP_Select_Func_ordenado_exc (V_CURSOR,3); 
  loop
    fetch v_cursor into  reg_func;
    exit when v_cursor%notfound;
    dbms_output.put_line ('Matricula = ' || to_char(reg_func.matricula) || ', nome = ' || reg_func.nome);
  end loop;
    dbms_output.put_line ('fim');
END;
/

-- Resposta 
inicio select func por xxxx
Foi retirada a ordenação
Matricula = 8490030, nome = Zezinho
Matricula = 4944944, nome = Huginho
Matricula = 4840392, nome = Luizinho
Matricula = 987639, nome = José das Couves
fim
PL/SQL procedure successfully completed.


CREATE OR REPLACE TRIGGER tr_insert_update_func
BEFORE INSERT OR UPDATE
ON PLSQLDEMO.FUNCIONARIO
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
  :NEW.NOME := UPPER (:NEW.Nome);
END tr_insert_update_func;
/

exec SP_INSERT_FUNCIONARIO (v_matricula => 6948575, v_nome => 'Nome com letras minúsculas');
commit;

select nome from plsqldemo.funcionario where matricula = 6948575;



NOME                                              
--------------------------------------------------
NOME COM LETRAS MINÚSCULAS                        

1 row selected.




create or replace package pkg_funcionario as

PROCEDURE SP_Select_Func_ordenado_exc  (V_Cursor out sys_refcursor, ordem in number);

procedure SP_INSERT_FUNCIONARIO (v_matricula in funcionario.matricula%type, v_nome in funcionario.nome%type);

end pkg_funcionario;
/

create or replace package body pkg_funcionario as

PROCEDURE SP_LOG_ERRO (
      V_DS_REFER_OBJ IN LOG_ERRO_APLIC.ds_refer_obj%TYPE,
      V_TX_TEXTO_ERRO IN LOG_ERRO_APLIC.tx_texto_erro%TYPE,
      V_CD_ERRO IN LOG_ERRO_APLIC.cd_erro%TYPE,
      V_DS_APLIC IN LOG_ERRO_APLIC.ds_aplic%TYPE
      )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
  V_TX_TEXTO_ERRO_W LOG_ERRO_APLIC.tx_texto_erro%TYPE;
BEGIN
  IF LENGTH(V_TX_TEXTO_ERRO) > 256 THEN
    V_TX_TEXTO_ERRO_W := SUBSTR(V_TX_TEXTO_ERRO,1,256);
  ELSE
    V_TX_TEXTO_ERRO_W := V_TX_TEXTO_ERRO;
  END IF;
  INSERT INTO LOG_ERRO_APLIC
   (DS_REFER_OBJ,CD_ERRO,TX_TEXTO_ERRO,TX_LOGIN_OPERAD,DS_APLIC,NM_ESTAC)
   VALUES(V_DS_REFER_OBJ,V_CD_ERRO,V_TX_TEXTO_ERRO_W,SYS_CONTEXT('USERENV','SESSION_USER'),V_DS_APLIC ,SYS_CONTEXT('USERENV','TERMINAL'));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END SP_LOG_ERRO;


procedure SP_INSERT_FUNCIONARIO (v_matricula in funcionario.matricula%type, v_nome in funcionario.nome%type) as
-- VARIÁVEIS PADRÕES
  V_MINHA_EXCECAO EXCEPTION;
  V_PROCNAME CONSTANT VARCHAR(30) := 'SP_INSERT_FUNCIONARIO';
  V_MSG_ERRO_APLIC VARCHAR2(255) :=  'Erro de aplicação';
  V_CD_ERRO_APLIC BINARY_INTEGER := -20000; 
begin
  if v_matricula  is null then
    V_CD_ERRO_APLIC:= -20001;
    V_MSG_ERRO_APLIC:= 'Matrícula do funcionário é obrigatória'; 
    RAISE V_MINHA_EXCECAO;
  end if;	

  if v_nome is null then
    V_CD_ERRO_APLIC:= -20002;
    V_MSG_ERRO_APLIC:= 'Nome do funcionário é obrigatório'; 
    RAISE V_MINHA_EXCECAO;
  end if;	
  
  insert into funcionario (nome, matricula) values (v_nome, v_matricula);


EXCEPTION
  WHEN V_MINHA_EXCECAO THEN
    SP_LOG_ERRO (V_PROCNAME,V_MSG_ERRO_APLIC,V_CD_ERRO_APLIC,NULL);
    RAISE_APPLICATION_ERROR (V_CD_ERRO_APLIC,V_PROCNAME || ' - ' || V_MSG_ERRO_APLIC,true);
  WHEN PROGRAM_ERROR THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN TOO_MANY_ROWS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN DUP_VAL_ON_INDEX THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN OTHERS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
END SP_INSERT_FUNCIONARIO;

procedure SP_Select_Func_ordenado_exc  (V_Cursor out sys_refcursor, ordem in number)
AS
  query varchar2(100);
  ordernador_invalido exception;
  PRAGMA EXCEPTION_INIT (ordernador_invalido,-1785);
  V_MINHA_EXCECAO EXCEPTION;
  V_PROCNAME CONSTANT VARCHAR(30) := 'SP_Select_Func_ordenado_exc';
  V_MSG_ERRO_APLIC VARCHAR2(255) :=  'Erro de aplicação';
  V_CD_ERRO_APLIC BINARY_INTEGER := -20000; 

BEGIN
  begin	 
    query := 'select * from funcionario order by ' || to_char(ordem);
    open V_Cursor for query;
  exception
    when ordernador_invalido then
	    dbms_output.put_line ('Foi retirada a ordenação');
	    query := 'select * from funcionario'; -- sem ordenação 
        open V_Cursor for query;
    when others then
	    raise v_minha_excecao;
  end;		
  
exception
  WHEN V_MINHA_EXCECAO THEN
    SP_LOG_ERRO (V_PROCNAME,V_MSG_ERRO_APLIC,V_CD_ERRO_APLIC,NULL);
    RAISE_APPLICATION_ERROR (V_CD_ERRO_APLIC,V_PROCNAME || ' - ' || V_MSG_ERRO_APLIC,true);
  WHEN PROGRAM_ERROR THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN TOO_MANY_ROWS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN DUP_VAL_ON_INDEX THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;
  WHEN OTHERS THEN
    SP_LOG_ERRO (V_PROCNAME,SQLERRM,SQLCODE,NULL);
    RAISE;

end SP_Select_Func_ordenado_exc;

end pkg_funcionario;




exec pkg_funcionario.SP_INSERT_FUNCIONARIO (v_matricula => 84747494, v_nome => 'Funcionario Package');
commit;


set serveroutput on
declare
  V_CURSOR sys_refcursor;
  reg_func funcionario%rowtype; 
BEGIN
  dbms_output.put_line ('inicio select func por matricula');
  plsqldemo.pkg_funcionario.SP_Select_Func_ordenado_exc (V_CURSOR,1); 
  loop
    fetch v_cursor into  reg_func;
    exit when v_cursor%notfound;
    dbms_output.put_line ('Matricula = ' || to_char(reg_func.matricula) || ', nome = ' || reg_func.nome);
  end loop;
    dbms_output.put_line ('fim');
END;
/

-- Resposta
inicio select func por matricula
Matricula = 987639, nome = José das Couves
Matricula = 4840392, nome = Luizinho
Matricula = 4944944, nome = Huginho
Matricula = 6948575, nome = NOME COM LETRAS MINÚSCULAS
Matricula = 8490030, nome = Zezinho
Matricula = 84747494, nome = FUNCIONARIO PACKAGE
fim
PL/SQL procedure successfully completed.



-- Cursor "Normal" 

set serveroutput on 

declare
  cursor V_CURSOR (Ts_Name IN varchar) is select file_name from dba_data_files where tablespace_name = Ts_Name; 
  datafile_name varchar(512);
BEGIN
  dbms_output.put_line ('inicio');
  open V_CURSOR ('TOOLS');
  loop
    fetch v_cursor into  datafile_name; 
    exit when v_cursor%notfound;
    dbms_output.put_line (datafile_name); 
  end loop;
    dbms_output.put_line ('fim');
END;
/
alter session set current_schema=scott;

create package emp_pkg as 
procedure raise_salary (empid in emp.empno%type, amount in emp.SAL%type); 
end emp_pkg;
/

create or replace package body emp_pkg as 
procedure raise_salary (empid in emp.empno%type, amount in emp.SAL%type) as 
begin
  update emp set sal = sal + amount where empno = empid;
end raise_salary; 
end emp_pkg;
/


drop table bonus;

DECLARE
sql_stmt VARCHAR2(200);
plsql_block VARCHAR2(500);
emp_id NUMBER(4) := 7566;
salary NUMBER(7,2);
dept_id NUMBER(2) := 60;
dept_name VARCHAR2(14) := 'IT';
location VARCHAR2(13) := 'MIAMI';
emp_rec emp%ROWTYPE;
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE bonus (id NUMBER, amt NUMBER)';

  sql_stmt := 'INSERT INTO dept VALUES (:1, :2, :3)';
  EXECUTE IMMEDIATE sql_stmt USING dept_id, dept_name, location;


  sql_stmt := 'SELECT * FROM emp WHERE empno = :id';
  EXECUTE IMMEDIATE sql_stmt INTO emp_rec USING emp_id;

  
  plsql_block := 'BEGIN scott.emp_pkg.raise_salary(:id, :amt); END;';
  EXECUTE IMMEDIATE plsql_block USING 7788, 500;
  

  sql_stmt := 'UPDATE emp SET sal = 2000 WHERE empno = :1 RETURNING sal INTO :2';
  EXECUTE IMMEDIATE sql_stmt USING emp_id RETURNING INTO salary;
  EXECUTE IMMEDIATE 'DELETE FROM dept WHERE deptno = :num' USING dept_id;
  EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';

END;
/

-- Comando FOR
set serveroutput on

declare
  cursor c1 is select * from emp;
begin
  for r1 in c1 loop
    dbms_output.put_line (to_char (r1.empno) || ' - '  || r1.ename);
  end loop;
end;
/     
   
Resposta:
7839 - KING
7698 - BLAKE
7782 - CLARK
7566 - JONES
7654 - MARTIN
7499 - ALLEN
7844 - TURNER
7900 - JAMES
7521 - WARD
7902 - FORD
7369 - SMITH
7788 - SCOTT
7876 - ADAMS
7934 - MILLER
PL/SQL procedure successfully completed.


create table temp (C1 number, c2 number, c3 varchar2(20));

DECLARE
  x NUMBER := 0;
  counter NUMBER := 0;
BEGIN
  FOR i IN 1..4 LOOP
    x := x + 1000;
    counter := counter + 1;
    INSERT INTO temp VALUES (x, counter, 'in OUTER loop');
    /* start an inner block */
    DECLARE
      x NUMBER := 0; -- this is a local version of x
    BEGIN
      FOR i IN 1..4 LOOP
        x := x + 1; -- this increments the local x
        counter := counter + 1;
        INSERT INTO temp VALUES (x, counter, 'inner loop');
      END LOOP;
    END;
  END LOOP;
  COMMIT;
END;
/

select * from temp;
Resposta:

        C1         C2 C3                  
---------- ---------- --------------------
      1000          1 in OUTER loop       
         1          2 inner loop          
         2          3 inner loop          
         3          4 inner loop          
         4          5 inner loop          
      2000          6 in OUTER loop       
         1          7 inner loop          
         2          8 inner loop          
         3          9 inner loop          
         4         10 inner loop          
      3000         11 in OUTER loop       
         1         12 inner loop          
         2         13 inner loop          
         3         14 inner loop          
         4         15 inner loop          
      4000         16 in OUTER loop       
         1         17 inner loop          
         2         18 inner loop          
         3         19 inner loop          
         4         20 inner loop          

20 rows selected.

drop table temp;

--LOOP com EXIT

LOOP
  ...
  IF credit_rating < 3 THEN
  ...
  EXIT; -- exit loop immediately
  END IF;
END LOOP;
/

-- LOOP com EXIT WHEN
LOOP
  FETCH c1 INTO ...
  EXIT WHEN c1%NOTFOUND; -- exit loop if condition is true  
  ...
END LOOP;
CLOSE c1;

-- Loop Nomeado

<<outer>>
LOOP
  ...
  LOOP
  ...
    EXIT outer WHEN ... -- exit both loops
  END LOOP;
...
END LOOP outer;

-- While LOOP

WHILE total <= 25000 LOOP
  ...
  SELECT sal INTO salary FROM emp WHERE ...
  total := total + salary;
END LOOP;

-- GOTO

BEGIN
  ...
   GOTO insert_row;
  ...
  <<insert_row>>
  INSERT INTO emp VALUES ...
END;
/

-- Comando NULL
BEGIN
.....

EXCEPTION
  WHEN ZERO_DIVIDE THEN
    ROLLBACK;
  WHEN VALUE_ERROR THEN
    INSERT INTO errors VALUES ...
    COMMIT;
  WHEN OTHERS THEN
    NULL; -- Não é aceita um comando vazio, por isto usamos NULL
END;
/


-- FORALL - melhor peroformance

BEGIN
...

 FORALL i IN 1..5000 
   INSERT INTO parts VALUES (pnums(i), pnames(i));

 END;
..

END;
/


