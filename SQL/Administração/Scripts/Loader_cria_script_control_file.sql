set linesize 1000;
set serveroutput on
DECLARE
  V_NOME_TABELA           VARCHAR2(50):=UPPER('&NOME_TABELA');
  V_NUM_COLUNA            NUMBER(3);
  V_POSICAO               VARCHAR2(10) := null;
  V_TIPO_PRONTO           VARCHAR2(100);

  CURSOR C_TABELA (W_NOME_TABELA  IN VARCHAR2)
     IS 
     SELECT SUBSTR(TAB.NAME,1,30)               TABELA
         , SUBSTR(COL.EL_NAME,1,40)             COLUNA
         , SUBSTR(COL.EL_COMMENT,1,50)          DESCRICAO
         , SUBSTR(COL1.DATATYPE,1,10)           TIPO
         , COL1.MAXIMUM_LENGTH                  TAMANHO
         , COL1.DECIMAL_PLACES                  DEC
         , SUBSTR(AT1.LOW_VALUE,1,5)            CK_LOW
         , SUBSTR(AT1.HIGH_VALUE,1,5)           CK_HIGH
         , SUBSTR(AT1.MEANING,1,50)             COMENTARIO
      FROM CI_DOMAINS               AT2
         , CI_COLUMNS               COL1
         , CI_ATTRIBUTE_VALUES      AT1
         , SDD_ELEMENTS             COL
         , CI_APPLICATION_SYSTEMS   APP
         , CI_TABLE_DEFINITIONS     TAB
    WHERE AT2.ID(+)   = COL1.DOMAIN_REFERENCE
      AND AT1.DOMAIN_REFERENCE(+) = AT2.ID
      AND COL1.ID  = COL.EL_ID
      AND APP.ID   = TAB.APPLICATION_SYSTEM_OWNED_BY
      AND TAB.ID   = COL1.TABLE_REFERENCE
      AND APP.NAME = 'MTD'
      AND TAB.NAME =  W_NOME_TABELA
    ORDER BY TAB.NAME
        , COL.EL_NAME
        , AT1.LOW_VALUE;


BEGIN
dbms_output.enable;

  V_NUM_COLUNA := 1;
  FOR R1 IN C_TABELA (V_NOME_TABELA) LOOP

    IF C_TABELA%NOTFOUND THEN
      EXIT;
    END IF;
    IF V_POSICAO IS NULL THEN
      dbms_output.put_line('LOAD DATA');
      dbms_output.put_line('INFILE '||'''E:\Dba\Scripts\LOADER\'||V_NOME_TABELA||'.ldr''');
      dbms_output.put_line('BADFILE '||'''E:\Dba\Scripts\LOADER\'||V_NOME_TABELA||'.bad''');
      dbms_output.put_line('DISCARDFILE '||'''E:\Dba\Scripts\LOADER\'||V_NOME_TABELA||'.dsc''');
      dbms_output.new_line;
      dbms_output.put_line('INTO TABLE "'||V_NOME_TABELA||'"');
      dbms_output.put_line('INSERT');
      dbms_output.put_line('(');
    END IF;

--  V_POSICAO := 'posic';
--  V_TIPO_PRONTO  := 'tip';

  IF R1.TIPO = 'DATE' THEN
    V_TIPO_PRONTO := 'DATE "DDMMYYYY"';
  ELSIF R1.TIPO = 'VARCHAR2' THEN
    V_TIPO_PRONTO := 'CHAR';
  ELSIF R1.TIPO = 'NUMBER' THEN
    IF R1.DEC > 0 THEN
      V_TIPO_PRONTO := 'DECIMAL EXTERNAL';
    ELSE
      V_TIPO_PRONTO := 'INTERGER EXTERNAL';
    END IF;
  ELSE
    V_TIPO_PRONTO := 'TIPO NAO IDENTIFICADO';
  END IF;



-- Montar o tamanho do campo

  IF R1.TIPO <> 'DATE' AND R1.TAMANHO IS NULL THEN
    V_POSICAO :=  '('
               || TO_CHAR(V_NUM_COLUNA)
               || ':'
               || TO_CHAR(V_NUM_COLUNA + 31)
               || ')';

dbms_output.put_line('************** NUMBER/ VARCHAR NULO *************');

    V_NUM_COLUNA := (V_NUM_COLUNA + 32);

  ELSIF R1.TIPO <> 'DATE' THEN
    V_POSICAO :=  '('
               || TO_CHAR(V_NUM_COLUNA)
               || ':'
               || TO_CHAR((V_NUM_COLUNA + R1.TAMANHO) - 1)
               || ')';
    V_NUM_COLUNA := (V_NUM_COLUNA + R1.TAMANHO);


  ELSE
    V_POSICAO :=  '('
               || TO_CHAR(V_NUM_COLUNA)
               || ':'
               || TO_CHAR(V_NUM_COLUNA + 7)
               || ')';
    V_NUM_COLUNA := (V_NUM_COLUNA + 8);
  END IF;  


-- Montar o tipo  da coluna
    
dbms_output.put_line(RPAD(R1.COLUNA,40,' ')||' POSITION'||RPAD(V_POSICAO,15,' ')||RPAD(V_TIPO_PRONTO,25,' ')||',');

  END LOOP;

  IF V_POSICAO IS NOT NULL THEN
    dbms_output.put_line(')');
  END IF;

END;
/


