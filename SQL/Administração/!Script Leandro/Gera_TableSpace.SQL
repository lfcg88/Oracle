DECLARE
	v_TSpace		VARCHAR2(320);
	v_CreateTspace   	VARCHAR2(320);
	v_DFDados		VARCHAR2(512);
	v_FileHandle 	UTL_FILE.FILE_TYPE;
	v_NomeArq		VARCHAR2(120);
	v_Outros		VARCHAR2(320);
	v_DataBase		VARCHAR2(30);

	CURSOR c_tspace IS
	SELECT tablespace_name, 'CREATE TABLESPACE '||tablespace_name
	FROM dba_tablespaces
	WHERE tablespace_name <> 'TEMP';

	CURSOR c_dfdados IS
	SELECT 'DATAFILE  '''||file_name||''' SIZE '||bytes/1024/1024||'M AUTOEXTEND OFF'
	FROM dba_data_files
	WHERE tablespace_name = v_TSpace;	
	
		
BEGIN
	
	v_NomeArq := 'CriaTableSpace.SQL';
	v_FileHandle := UTL_FILE.FOPEN ('DIR_GERA_SCRIPT',v_NomeArq,'w');

	OPEN c_tspace;
	LOOP
		FETCH c_tspace INTO v_TSpace, v_CreateTspace;
		EXIT	WHEN 	c_tspace%NOTFOUND;

		UTL_FILE.PUT_LINE (v_FileHandle,v_CreateTspace);

		OPEN c_dfdados;
		LOOP
			FETCH c_dfdados INTO V_DFDados;
			EXIT	WHEN 	c_dfdados%NOTFOUND;
			UTL_FILE.PUT_LINE (v_FileHandle,V_DFDados);
		END LOOP;
		CLOSE c_dfdados;

		v_Outros := 'EXTENT MANAGEMENT LOCAL UNIFORM SIZE 128K SEGMENT SPACE MANAGEMENT MANUAL;';
		UTL_FILE.PUT_LINE (v_FileHandle,v_Outros);
		UTL_FILE.PUT_LINE (v_FileHandle,'');
	
	END LOOP;
	CLOSE c_tspace;

END;
/
