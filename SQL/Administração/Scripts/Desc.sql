/*********************************************/
/****   Criado por :  Sérgio Rodrigues   *****/
/****         Data :  Julho/2004         *****/
/*********************************************/
SET serverout ON
SET verify OFF
SET feedback OFF
SET lines 1000
DECLARE
  wrk_nome_obj           VARCHAR2(35) := upper('&1');
  wrk_tot_col            NUMBER(5)    := 0;
  wrk_constraint_type    VARCHAR2(20);
  wrk_tabela_fk          VARCHAR2(35);
  
  CURSOR col_tab IS 
    SELECT owner
         , table_name
         , column_name
         , decode(nullable,'N','NOT NULL','Y',' ',nullable) nullable
         , data_type
         , rpad(
           decode(data_type,'DATE'    ,' '
                           ,'LONG'    ,' '
                           ,'LONG RAW',' '
                           ,'RAW'     ,decode(data_length,null,null
                                                   ,'('||data_length||')')
                           ,'CHAR'    ,decode(data_length,null,null
                                                   ,'('||data_length||')')
                           ,'VARCHAR' ,decode(data_length,null,null
                                                   ,'('||data_length||')')
                           ,'VARCHAR2',decode(data_length,null,null
                                                   ,'('||data_length||')')
                           ,'NUMBER'  ,decode(data_precision,null,'   '
                                                   ,'('||data_precision||
                                                    decode(data_scale,null,null,','||data_scale)||')')
                           ,'unknown'),8,' ') tamanho
         , data_default
      FROM all_tab_columns
     WHERE owner      = substr(wrk_nome_obj,1,instr(wrk_nome_obj,'.',1,1)-1) 
       AND table_name = substr(wrk_nome_obj,instr(wrk_nome_obj,'.',1,1)+1)
     ORDER BY column_id;

     CURSOR cons_col( par_owner       VARCHAR2
                    , par_table_name  VARCHAR2
                    , par_column_name VARCHAR2) IS
       SELECT cons.r_constraint_name
            , constraint_type
            , decode(cons.constraint_type, 'C', ' '
                                         , 'P', 'PK : '||col.position
                                         , 'R', 'FGK: '||col.position
                                         , 'U', 'UK   '
                                         , cons.constraint_type) tipo_constraint
         FROM all_cons_columns col
            , all_constraints  cons
        WHERE cons.owner           = col.owner
          AND cons.table_name      = col.table_name
          AND cons.constraint_name = col.constraint_name
          AND cons.constraint_type <> 'C'
          AND cons.owner           = par_owner 
          AND cons.table_name      = par_table_name
          AND col.column_name      = par_column_name
        ORDER BY constraint_type DESC;
          
     CURSOR cons_fk( par_owner             VARCHAR2
                   , par_table_name        VARCHAR2
                   , par_r_constraint_name VARCHAR2) IS
          SELECT b.table_name
            FROM all_constraints b
           WHERE (owner,constraint_name) in (SELECT r_owner,r_constraint_name 
                                               FROM all_constraints
                                              WHERE owner             = par_owner
                                                AND table_name        = par_table_name
                                                AND r_constraint_name = par_r_constraint_name
                                                AND ROWNUM < 2);
          
BEGIN
  dbms_output.enable(100000000);
  dbms_output.put_line( rpad('Coluna'    ,31,' ')  ||' '||
                        rpad('Null?'     , 8,' ')  ||' '||
                        rpad('Tipo'      ,14,' ')  ||' '||
                        rpad('Default'   , 8,' ')  ||' '||
                        rpad('Constraint',15,' ')  ||' '||
                        rpad('Tab. referenciada na FK',35,' '));

  dbms_output.put_line( rpad('-',31,'-')  ||' '||
                        rpad('-', 8,'-')  ||' '||
                        rpad('-',14,'-')  ||' '||
                        rpad('-', 8,'-')  ||' '||
                        rpad('-',15,'-')  ||' '||
                        rpad('-',35,'-'));
  
  FOR r1 IN col_tab LOOP
    wrk_tot_col := wrk_tot_col + 1;
    
    FOR r2 IN cons_col( r1.owner
                      , r1.table_name
                      , r1.column_name) LOOP

      wrk_constraint_type := r2.tipo_constraint||' '||wrk_constraint_type;
      
      IF r2.constraint_type = 'R' THEN
      
        FOR r3 IN cons_fk( r1.owner
                         , r1.table_name
                         , r2.r_constraint_name) LOOP
        
          wrk_tabela_fk := r3.table_name;
        
        END LOOP;

      END IF;
      
    END LOOP;

    dbms_output.put_line( rpad(r1.column_name,31,' ')            ||' '||
                          rpad(r1.nullable,8,' ')                ||' '||
                          rpad(r1.data_type||r1.tamanho,14,' ')  ||' '||
                          rpad(substr(nvl(r1.data_default,' '),1,8),8,' ')||' '||
                          rpad(wrk_constraint_type,15,' ')       ||' '||
                          rpad(wrk_tabela_fk,35,' '));
  
    wrk_constraint_type := NULL;
    wrk_tabela_fk       := NULL;
  END LOOP;
  dbms_output.put_line('Total de colunas : '||wrk_tot_col);
  dbms_output.put_line('. ');
END;
/
undefine 1
undefine 2
SET verify ON
SET serverout OFF
SET feedback ON
