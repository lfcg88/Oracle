Declare
-- Variaveis
  wrk_comando      Varchar2(32000);
  wrk_colunas      Varchar2(32000);
  wrk_tab_ref      Varchar2(32000);
  wrk_colunas_ref  Varchar2(32000);
--
-- Cursores
  Cursor c_constraint  Is
    Select a.*
         , decode(a.status,'DISABLED','DISABLE','') Desabilita
      From DBA_constraints a
     where owner not in ('OLAPSYS','CTXSYS','WKSYS','ODM','HR','OE','CPLADMIN','PM','SH','SYS','SYSTEM','WMSYS','PERFSTAT','MANAGER','REPADMIN','ORDSYS','RMAN','SCOTT','MDSYS')
       And Constraint_Type = 'R'
       And deferrable = 'NOT DEFERRABLE';
--
  Cursor c_con_columns ( par_owner           Varchar2
                       , par_constraint_name Varchar2)  Is
    Select owner
         , table_name
         , decode( position,1, column_name,','||column_name) colunas
      From DBA_cons_columns
     where owner = par_owner
       And constraint_name = par_constraint_name
     Order by position;
--
Begin
  dbms_output.enable(9999999999999999);
  For r_constraint in c_constraint Loop
--
    wrk_comando := 'ALTER TABLE '||r_constraint.owner||'.'||r_constraint.table_name||CHR(10)||
                   ' DROP CONSTRAINT '||r_constraint.constraint_name||';';
dbms_output.put_line(wrk_comando);
    wrk_comando := 'ALTER TABLE '||r_constraint.owner||'.'||r_constraint.table_name||' ADD ('||chr(10)||
                   ' CONSTRAINT '||r_constraint.constraint_name||' FOREIGN KEY (';
--dbms_output.put_line(wrk_comando);
    For r_con_columns1 in c_con_columns( r_constraint.owner
                                       , r_constraint.constraint_name) Loop
      wrk_colunas := wrk_colunas||r_con_columns1.colunas;
--
    End Loop;
    wrk_comando := wrk_comando||wrk_colunas||')';
dbms_output.put_line(wrk_comando);
--
    For r_con_columns2 in c_con_columns( r_constraint.owner
                                       , r_constraint.r_constraint_name) Loop
      wrk_tab_ref     := r_con_columns2.owner||'.'||r_con_columns2.table_name;
      wrk_colunas_ref := wrk_colunas_ref||r_con_columns2.colunas;
--
    End Loop;

    wrk_comando := ' REFERENCES '||wrk_tab_ref||' ( '||wrk_colunas_ref||')'||chr(10)||
                   ' DEFERRABLE INITIALLY IMMEDIATE '||r_constraint.Desabilita||');';    
dbms_output.put_line(wrk_comando);
dbms_output.put_line('@./man/compila_todos_invalidos');
dbms_output.put_line('-------------------------------------------------');
    wrk_comando      := Null;
    wrk_colunas      := Null;
    wrk_tab_ref      := Null;
    wrk_colunas_ref  := Null;

--
  End Loop;
dbms_output.put_line(wrk_comando);
--
End;
/
