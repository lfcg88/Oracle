SET SERVEROUTPUT ON
SET TERMOUT OFF

DECLARE
  retval NUMBER := 0;
  max_sessions NUMBER := &&1;
  cursor_id INTEGER :=0;
  num_recs NUMBER :=0;
  stmt VARCHAR2(300);
BEGIN
  IF dbms_pipe.create_pipe ('BG_noise', 65536, TRUE) = 0 THEN
    dbms_output.put_line('initialized pipe');
  ELSE
    dbms_output.put_line('failed to initialize pipe');
  END IF;

  SELECT COUNT(*)
    INTO num_recs
    FROM user_tables
    WHERE table_name = 'TRANSACTIONS';

  IF num_recs > 0 THEN  
    -- table exists, then truncate the table
    cursor_id := dbms_sql.open_cursor();
    stmt := 'TRUNCATE TABLE transactions';
    dbms_output.put_line(stmt);
    dbms_sql.parse(cursor_id, stmt, 1);
    retval := dbms_sql.execute(cursor_id);
  
  ELSE
    cursor_id := dbms_sql.open_cursor();
    stmt := 'CREATE TABLE transactions' ||
            ' (sid  NUMBER, ' ||
            '  serial#  NUMBER, ' ||
            '  pass_id  NUMBER, ' ||
            '  txn_start DATE , ' ||
            '  txn_end DATE ) ' ||
            '  INITRANS '||max_sessions ||
            ' TABLESPACE sysaux';
    dbms_output.put_line(stmt);
    dbms_sql.parse(cursor_id, stmt, 1);
    retval := dbms_sql.execute(cursor_id);
  
    stmt := 'CREATE INDEX transactions_i ON '||
            '  transactions(sid, serial#) '||
            '  TABLESPACE sysaux';
    dbms_output.put_line(stmt);
    dbms_sql.parse(cursor_id, stmt, 1);
    retval := dbms_sql.execute(cursor_id);
  
    dbms_sql.close_cursor(cursor_id);
  END IF;
END;
/

SET SERVEROUTPUT OFF

EXIT

