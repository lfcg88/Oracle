/*TRABALHANDO CURSOR EXPLICITO
OBS: USA-SE CURSOR QUANDO A QUERY RETORNA 
MAIS DE UMA LINHA DA TABELA */
DECLARE
	L_COD_DPTO1 	DEPARTMENTS.DEPARTMENT_ID%TYPE := &COD1;
	L_COD_DPTO2 	DEPARTMENTS.DEPARTMENT_ID%TYPE := &COD2;
	CURSOR CUR_DPTO 
	IS ( SELECT DEPARTMENT_NAME
		   FROM DEPARTMENTS
		  WHERE DEPARTMENT_ID = G_COD_DPTO1 
		     OR DEPARTMENT_ID = G_COD_DPTO2 );
	--DECLARANDO UM REGISTRO CUJA AS VARIAVEIS S�O DO MESMO TIPO DAS COLUNAS RETORNADAS NA CONSULTA
	--EX: REG_C_DPTO.DEPARTMENT.NAME, NESSE CASO SO RETORNA O NOME DO DPTO
	--SENDO ASSIM O REGISTRO SO CONTEM UM TIPO
	REG_C_DPTO	C_DPTO%ROWTYPE;
BEGIN
	OPEN C_DPTO;
	FETCH C_DPTO INTO REG_C_DPTO;
	--%FOUND TESTA A EXIST�NCIA DE LINHAS NO CURSOR
	WHILE C_DPTO%FOUND 
	LOOP
		:MSG := :MSG ||REG_C_DPTO.DEPARTMENT_NAME||'-';
		--PULA PARA PROXIMA LINHA DO REGISTRO
		FETCH C_DPTO INTO REG_C_DPTO;
	END LOOP;
	CLOSE C_DPTO;
	--NO CASO DE CURSOR N�O SE TESTA EXCESS�O NO_DATA_FOUND
	--POIS EST� SENDO TESTADO NO COMANDO %FOUND ACIMA	
END;

/*MESMO EXEMPLO ANTERIOR COM CURSOR IMPLICITO*/
DECLARE
	--COMO N�O SE TESTA EXCESS�ES NO_DATA_FOUND COM CURSORES, POIS CURSORES S�O USADOS
	--PARA QUERYS QUE RETORNAM MAIS DE  UM VALOR, UMA FORMA DE CONTROLAR
	--SE PASSOU NO LOOP OU N�O,EM CASO DE CURSORES IMPLICITOS, SERIA COM UM BOOLEAN
	--PARA ISSO FOI DECLARADA A VARIAVEL ABAIXO
	L_FLAG BOOLEAN := FALSE;
	G_COD_DPTO1 DEPARTMENTS.DEPARTMENT_ID%TYPE := &COD1;
	G_COD_DPTO2 DEPARTMENTS.DEPARTMENT_ID%TYPE := &COD2;
	CURSOR C_DPTO 
	IS ( SELECT DEPARTMENT_NAME
		   FROM DEPARTMENTS
		  WHERE DEPARTMENT_ID = G_COD_DPTO1 
		    AND DEPARTMENT_ID = &COD2 );
--OBS N�O SE DECLARA O REGISTRO CONFORME NO EXEMPLO ACIMA--
BEGIN
	FOR REG_C_DPTO IN C_DPTO LOOP
		:MSG := :MSG ||REG_C_DPTO.DEPARTMENT_NAME||'-';
		L_FLAG := TRUE;
	END LOOP;
	IF ( L_FLAG = FALSE )
	THEN
		:MSG := 'N�O HA DADOS NA TABELA';
	END IF;	
END;
		  
/*MONTANDO UM BLOCO PL/SQL PARA MONTAR UMA TABELA COM OS MAIORES SALARIOS
DOS FUNCIONARIOS ONDE O NUMERO DE MAIORES SALARIOS SER� DIGITADO PELO USUARIO*/
 