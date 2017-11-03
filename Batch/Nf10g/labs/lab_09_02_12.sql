DECLARE
  sess_count   NUMBER;
  back_count   NUMBER;
BEGIN
 SELECT COUNT(*) INTO sess_count FROM V$SESSION;
 SELECT COUNT(*) INTO back_count
   FROM V$SESSION
   WHERE type = ''BACKGROUND'';
 INSERT INTO session_history VALUES (systimestamp, sess_count, back_count);
COMMIT;
END;

