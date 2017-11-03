SET VERI OFF
DECLARE
  pid NUMBER := &1; 
  max_pid NUMBER := &2; 
  v_pass_id NUMBER := 0;
  pass_max NUMBER := 100;
  v_index_id NUMBER := 0;
  index_max NUMBER := &3;
  v_start_val NUMBER :=0;
  retval NUMBER := 0; 

  v_sid NUMBER :=0;
  v_serial# NUMBER :=0;
  v_sleep_time NUMBER :=0;
  cnt NUMBER :=0;


BEGIN
  SELECT sid, serial#
    INTO v_sid, v_serial#
    FROM v$session
    WHERE sid = (SELECT sid 
                   FROM v$mystat 
                   WHERE rownum=1);
  -- retval:= dbms_pipe.create_pipe ('BG_pipe'||sid, 65536, TRUE)

  dbms_random.initialize ((938+v_serial#)*v_sid);

  v_start_val := (pid-1)*pass_max*index_max;
  FOR v_pass_id IN 0 .. (pass_max-1) LOOP
    FOR v_index_id IN 0 .. (index_max-1) LOOP
      -- attempt to read from pipe, which will be empty and will exit after timeout
      -- wait time is considered as an idle event
      -- sleep time will be between 2 and 3 seconds,
      -- and then loop will repeat
     v_sleep_time := MOD(ABS(dbms_random.random()),2)+2;
     retval := dbms_pipe.receive_message ('BG_pipe'||v_sid, v_sleep_time);
 
      -- mark start of transaction for current pool
      INSERT INTO transactions
        (sid, serial#, 
         pass_id, txn_start)
        VALUES (v_sid, v_serial#, 
                (v_start_val+(index_max*(v_pass_id))+v_index_id), SYSDATE);
     
      -- issue several selects as to perform some background activity
      select count(*) into cnt from (
      select PROMO_CATEGORY, sum(PROMO_COST)
      from promotions
      where PROMO_NAME <> 'NO PROMOTION'
      group by PROMO_CATEGORY) ;

      select  count(co.country_name) into cnt
      from countries co, customers cu
      where co.country_id=cu.country_id
        and cu.cust_credit_limit = (SELECT max(cust_credit_limit)
                                    FROM customers
                                    where CUST_YEAR_OF_BIRTH = '1990')
        and cu.CUST_YEAR_OF_BIRTH = '1990';

      -- indicate end of transaction
      UPDATE transactions
        SET txn_end = SYSDATE
        WHERE sid = v_sid AND
              serial# = v_serial# AND
              pass_id = (v_start_val+(index_max*(v_pass_id))+v_index_id);
      COMMIT;
    END LOOP;
  END LOOP;

  dbms_pipe.pack_message(pid);
  retval := dbms_pipe.send_message('BG_noise');

END;
/

EXIT
