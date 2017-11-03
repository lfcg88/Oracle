Prompt #############################################################
Prompt #                                                           #
Prompt #             Lista o script do Índice                      #
Prompt #                                                           #
Prompt #############################################################

set serveroutput on 
set feedback off 
set verify off 
set pages 0 
set lines 100 
set trims on
Accept wrk_nome_obj Prompt 'Digite o Owner dos índices : '
declare

     /* Indexes */
     cursor cind is
     select owner, table_owner, table_name, index_name, ini_trans, max_trans,
            tablespace_name, initial_extent/1024 initial_extent, 
            next_extent/1024 next_extent, min_extents, max_extents, 
            pct_increase, decode(uniqueness,'UNIQUE','UNIQUE') unq
     from dba_indexes
     where table_owner ='&wrk_nome_obj'
       And index_name not like '%$%';
     /* Index columns */
     cursor ccol (o in varchar2, t in varchar2, i in varchar2) is
     select decode(column_position,1,'(',',')||
               rpad(column_name,40) cl
     from dba_ind_columns
     where table_name = upper(t) and
           index_name = upper(i) and
           index_owner = upper(o)
     order by column_position;
     wcount number := 0;
begin
  dbms_output.enable(100000);
  for rind in cind loop
     wcount := wcount + 1;
       dbms_output.put_line('------------------ '||wcount||'º INDICE  -------------------');
       dbms_output.put_line('Create '||rind.unq||' index '|| rind.owner || '.' || rind.index_name);
       dbms_output.put_line(' on  '||rind.table_owner||'.'|| rind.table_name);
       for rcol in ccol (rind.owner, rind.table_name, rind.index_name) loop
         dbms_output.put_line(rcol.cl);
       end loop;
       dbms_output.put_line(')');
       dbms_output.put_line(' initrans ' || rind.ini_trans );
       dbms_output.put_line(' maxtrans ' || rind.max_trans);
       dbms_output.put_line('tablespace ' || rind.tablespace_name);
       dbms_output.put_line('storage (');
       dbms_output.put_line('initial ' || rind.initial_extent || 'K ');
       dbms_output.put_line('next ' || rind.next_extent || 'K ');
       dbms_output.put_line('pctincrease ' || rind.pct_increase);
       dbms_output.put_line('minextents ' || rind.min_extents );
       dbms_output.put_line('maxextents '|| rind.max_extents || ' )');
       dbms_output.put_line('/');
     end loop;
     if wcount =0 then
       dbms_output.put_line('******************************************************');
       dbms_output.put_line('*                                                    *');
       dbms_output.put_line('* Plese Verify Input Parameters... No Matches Found! *');
       dbms_output.put_line('*                                                    *');
       dbms_output.put_line('******************************************************');
     end if;
   end;
/
set serveroutput off feedback on verify on pages 999


