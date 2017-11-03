SET SERVEROUTPUT ON
SET LINESIZE 1000
SET PAGESIZE 1000
/*
Neste script deve ser configurado um diretorio para gravação da saida.
Ele usa UTL_FILE.
*/
DECLARE
ptname  varchar2(100) := '&TABELA';
ptowner varchar2(100) := '&OWNER';

  wmaxcolid  number (4);
  wcursor    integer;
  wignore    integer;
  wdatfile   varchar2 (34);
  wdatftype  utl_file.file_type;
  wfetchrows number;
  wsqlstmt   varchar2 (2000);
  wdata      varchar2 (2000);
  wreturn    INTEGER;


  wtabldrfile  VARCHAR2 (34);
  wtabldrftype utl_file.file_type;
  wheadstr     VARCHAR2 (1000);

  CURSOR cldrcol (owner in varchar2, tabname in varchar2) is SELECT
       (DECODE(rownum,1,'   ',' , ')||RPAD(column_name,33,' ') ||
       DECODE(data_type, 'VARCHAR2','CHAR NULLIF('|| column_name ||'=BLANKS)',
       'FLOAT',   'DECIMAL EXTERNAL NULLIF('||column_name||'=BLANKS)', 'NUMBER',
       DECODE(data_precision, 0, 'INTEGER EXTERNAL NULLIF ('||column_name
       ||'=BLANKS)', DECODE(data_scale,0, 'INTEGER EXTERNAL NULLIF
       ('||column_name ||'=BLANKS)', 'DECIMAL EXTERNAL NULLIF
       ('||column_name ||'=BLANKS)')),'DATE','DATE "YYYYMMDD:HH24:MI:SS" NULLIF ('
       ||column_name ||'=BLANKS)',NULL)) colstr
       FROM dba_tab_columns
       WHERE TABLE_NAME = UPPER(tabname)
       AND   OWNER = UPPER(owner)
       ORDER BY COLUMN_ID;

BEGIN
DBMS_OUTPUT.ENABLE;

  SELECT
       ('LOAD DATA'||chr(10)
       ||'INFILE '''||lower(ptname)||'.dat'' '||chr(10)
       ||'INTO TABLE '||ptowner ||'.'|| ptname ||chr(10)
       ||'FIELDS TERMINATED BY '';'' '||chr(10)
       ||'TRAILING NULLCOLS'||chr(10)
       ||'(') wheadstr
  INTO wheadstr
  FROM dual;
    DBMS_OUTPUT.PUT_LINE('###############################################');
    DBMS_OUTPUT.PUT_LINE('### ARQUIVO DE CONTROL FILE PARA A TABELA:  ###');
    DBMS_OUTPUT.PUT_LINE('### '||LPAD(RPAD(PTNAME,25),39)|| ' ###');
    DBMS_OUTPUT.PUT_LINE('###             COPIE A PARTIR DAQUI        ###');
    DBMS_OUTPUT.PUT_LINE('###############################################');
    DBMS_OUTPUT.PUT_LINE(wheadstr);

  FOR r1 IN cldrcol (ptowner, ptname) LOOP

    DBMS_OUTPUT.PUT_LINE(r1.colstr);
  END LOOP;

    DBMS_OUTPUT.PUT_LINE(')');


END;
/
