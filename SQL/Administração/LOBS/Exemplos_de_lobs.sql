-- cria tabela exemplo

 create table t1 (
 c1 number(5) default 1 not null,
 c2 clob null)
 lob (c2) store as (disable storage in row);
 
 
 insert into t1 values (1,null);
 insert into t1 values (2,null);
 
 commit;

-- lê tamanho do lob
declare
   Lob_loc     clob;
   Length      INTEGER;
BEGIN
   /* Select the LOB: */
   SELECT c2 INTO Lob_loc FROM t1
       WHERE c1 = 3;
   /* Opening the LOB is optional: */
   DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READONLY);
   /* Get the length of the LOB: */
   length := DBMS_LOB.GETLENGTH(Lob_loc);
   IF length IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('LOB is null.');
   ELSE
       DBMS_OUTPUT.PUT_LINE('The length is '|| length);
   END IF;
   /* Closing the LOB is mandatory if you have opened it: */
   DBMS_LOB.CLOSE (Lob_loc);
END;

-- grava um lob a partir de uma string < 32.767

declare
   lob_loc  CLOB;
   buf varchar2(30);
   an_offset INTEGER := 1;
   an_amount BINARY_INTEGER := 30;
begin
   select c2 into lob_loc from t1
        where c1 = 1 for update;
   buf:= '123456789012345678901234567890';
   dbms_lob.write(lob_loc, an_amount, an_offset,buf);
   commit;
end;

-- grava lob a partir de várias strings quando o tamanho total é > 32767
declare
    Lob_loc        cLOB;
    Buffer         VARCHAR2(32767);
    Amount         BINARY_INTEGER := 32766;
    Position       INTEGER := 1;
    i              INTEGER;
BEGIN
    /* Select the LOB: */
    buffer := substr(lpad(' ',amount,'1234567890'),1,amount);
    SELECT c2  INTO Lob_loc
        FROM t1 where c1=1 FOR UPDATE;
    /* Opening the LOB is optional: */
    DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READWRITE);
    FOR i IN 1..100 LOOP
        /* Fill the Buffer with data to be written. */
        /* Write data: */
        DBMS_LOB.WRITE (Lob_loc, Amount, Position, Buffer);
        Position := Position + Amount;
    END LOOP;
    /* Closing the LOB is mandatory if you have opened it: */
    DBMS_LOB.CLOSE (Lob_loc);
    commit;

EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Operation failed');
END;

-- copia um lob para outro
declare 
   Dest_loc     cLOB;
   Src_loc      cLOB;
   Amount       NUMBER;
   Dest_pos     NUMBER;
   Src_pos      NUMBER;
BEGIN
   /* lob de destino */
   SELECT c2 INTO Dest_loc FROM t1
      WHERE c1 = 2 FOR UPDATE;
   /* Select the LOB: */
   SELECT c2 INTO Src_loc FROM t1
      WHERE c1 = 1;
   /* Opening the LOBs is optional: */
   DBMS_LOB.OPEN(Dest_loc, DBMS_LOB.LOB_READWRITE);
   DBMS_LOB.OPEN(Src_loc, DBMS_LOB.LOB_READONLY);
   /* Copies the LOB from the source position to the destination position: */
   amount:= DBMS_LOB.GETLENGTH(src_loc);
   dest_pos:= 1;
   src_pos:= 1;
   if amount is not null then
     DBMS_LOB.COPY(Dest_loc, Src_loc, Amount, Dest_pos, Src_pos);
   else
     dbms_output.put_line('Lob é null');
   end if;
   /* Closing LOBs is mandatory if you have opened them: */
   DBMS_LOB.CLOSE(Dest_loc);
   DBMS_LOB.CLOSE(Src_loc);
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Operation failed');
END;

-- append de um lob em outro
declare 
   Dest_loc     cLOB;
   Src_loc      cLOB;
BEGIN
   /* lob de destino */
   SELECT c2 INTO Dest_loc FROM t1
      WHERE c1 = 2 FOR UPDATE;
   /* Select the LOB: */
   SELECT c2 INTO Src_loc FROM t1
      WHERE c1 = 1;
   /* Opening the LOBs is optional: */
   DBMS_LOB.OPEN(Dest_loc, DBMS_LOB.LOB_READWRITE);
   DBMS_LOB.OPEN(Src_loc, DBMS_LOB.LOB_READONLY);

   DBMS_LOB.APPEND(Dest_loc, Src_loc);

   /* Closing LOBs is mandatory if you have opened them: */
   DBMS_LOB.CLOSE(Dest_loc);
   DBMS_LOB.CLOSE(Src_loc);
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Operation failed');
END;

-- cria lob temporário e faz insert através dele
declare
    Lob_loc        cLOB;
    Buffer         VARCHAR2(32767);
    Amount         BINARY_INTEGER := 32766;
    Position       INTEGER := 1;
    i              INTEGER;
BEGIN
    /* Select the LOB: */
    buffer := substr(lpad(' ',amount,'1234567890'),1,amount);
    DBMS_LOB.CREATETEMPORARY (lob_loc => lob_loc, cache => true, dur => dbms_lob.session);

    /* Opening the LOB is optional: */
    DBMS_LOB.OPEN (Lob_loc, DBMS_LOB.LOB_READWRITE);
    FOR i IN 1..100 LOOP
        /* Fill the Buffer with data to be written. */
        /* Write data: */
        DBMS_LOB.WRITE (Lob_loc, Amount, Position, Buffer);
        Position := Position + Amount;
    END LOOP;
    /* Closing the LOB is mandatory if you have opened it: */
    DBMS_LOB.CLOSE (Lob_loc);
    
    insert into t1 (c1,c2) values (3,lob_loc);
    commit;

EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Operation failed');
END;







