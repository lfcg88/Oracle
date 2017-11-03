DECLARE
  sess_count   NUMBER;
BEGIN
 SELECT COUNT(*) INTO sess_count FROM V$SESSION;
 INSERT INTO session_history VALUES (systimestamp, sess_count);
COMMIT;
END;

