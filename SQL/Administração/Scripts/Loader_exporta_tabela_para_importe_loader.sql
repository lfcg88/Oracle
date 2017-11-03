/*
Neste script deve ser configurado um diretorio para gravação da saida.
Ele usa UTL_FILE.
*/
DECLARE

ptname  varchar2(100) := '&TABELA';
ptowner varchar2(100) := '&OWNER';
psindex varchar2(100) := '&INDICE_OU_NULL';



  CURSOR ccolname (maxcolid in number)  IS SELECT
         (DECODE(column_id, maxcolid, column_name || '||''|''',
                column_name|| '||''|''||' ) ) colstr
         FROM  all_tab_columns
         WHERE table_name     = upper(ptname)
         AND   owner = upper(ptowner)
         ORDER BY column_id;

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
       ('||column_name ||'=BLANKS)')),'DATE','DATE "YYYYMMDD:HH24MISS" NULLIF ('
       ||column_name ||'=BLANKS)',NULL)) colstr
       FROM dba_tab_columns
       WHERE TABLE_NAME = UPPER(tabname)
       AND   OWNER = UPPER(owner)
       ORDER BY COLUMN_ID;

BEGIN
DBMS_OUTPUT.ENABLE;
  wdatfile := lower(ptname) || '.dat';
  wdatftype := utl_file.fopen('UTL_DIR', wdatfile, 'w');

  dbms_session.set_nls('nls_date_format','''YYYYMMDD:HH24MISS''');

  SELECT MAX(column_id) INTO wmaxcolid
  FROM   dba_tab_columns
  WHERE  table_name = upper(ptname)
  AND    owner = upper(ptowner);

  wsqlstmt := 'SELECT /*+ INDEX (A '|| psindex ||' ) */ ';
  FOR rcolname IN ccolname (wmaxcolid) LOOP
    wsqlstmt := wsqlstmt || rcolname.colstr;
  END LOOP;

  wsqlstmt := wsqlstmt || ' valuestr FROM ' || ptowner || '.' || ptname ||' A';

  wcursor := dbms_sql.open_cursor;
  dbms_sql.parse (wcursor, wsqlstmt, dbms_sql.v7);
  DBMS_SQL.DEFINE_COLUMN (wcursor, 1, wdata, 2000);
  wreturn := DBMS_SQL.execute (wcursor);

  WHILE dbms_sql.fetch_rows (wcursor) > 0 LOOP

    dbms_sql.column_value (wcursor, 1, wdata);
    utl_file.put_line (wdatftype, wdata);

  END LOOP;

  dbms_sql.close_cursor (wcursor);

  -- DBMS_OUTPUT.PUT_LINE ('Data File ' || wdatfile || ' Created');

  SELECT
       ('LOAD DATA'||chr(10)
       ||'INFILE '''||lower(ptname)||'.dat'' '||chr(10)
       ||'INTO TABLE '||ptowner ||'.'|| ptname ||chr(10)
       ||'FIELDS TERMINATED BY ''|'' '||chr(10)
       ||'TRAILING NULLCOLS'||chr(10)
       ||'(') wheadstr
  INTO wheadstr
  FROM dual;

  wtabldrfile  := lower(ptname) || '.ctl';
  wtabldrftype := utl_file.fopen('UTL_DIR', wtabldrfile, 'w');

  utl_file.put_line(wtabldrftype, wheadstr);

  FOR r1 IN cldrcol (ptowner, ptname) LOOP
     utl_file.put_line(wtabldrftype, r1.colstr);
  END LOOP;

  utl_file.put_line(wtabldrftype, ')');
  utl_file.fclose(wtabldrftype);

  -- DBMS_OUTPUT.PUT_LINE ('Control File ' || wtabldrfile || ' Created');

END;
/
