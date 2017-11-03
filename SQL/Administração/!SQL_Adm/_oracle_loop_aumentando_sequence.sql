DECLARE
 x NUMBER;
 y  NUMBER := 3128;

BEGIN
  SELECT ecmarketplace.seq_comentario.currval into x from dual; 
  WHILE x < y LOOP
    SELECT ecmarketplace.seq_comentario.nextval into x from dual;
  END LOOP;
END;
