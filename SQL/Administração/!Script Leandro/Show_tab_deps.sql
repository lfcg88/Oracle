CREATE OR REPLACE procedure Show_tab_deps( p_owner varchar2
                                         , p_table varchar2
                                         , p_level number :=0 ) as
Begin
  Declare

    Cursor c_constr( par_owner varchar2
                   , par_table varchar2) is
      Select owner
           , constraint_name
           , constraint_type
           , table_name
           , r_owner
           , r_constraint_name
           , status
        from all_constraints
       where owner = upper(par_owner)
         and table_name = upper(par_table)
         and constraint_type = 'R';

    Cursor c_col( par_owner varchar2
                , par_table varchar2
                , par_constraint_name varchar2) is
     Select column_name
       from all_cons_columns
      where owner = par_owner
        and table_name = par_table
        and constraint_name = par_constraint_name;      

    wrk_owner        varchar2(100);
    wrk_table_name   varchar2(100);
    wrk_column_name  varchar2(1000);
    wrk_count        number(10) :=0;

  Begin
    dbms_output.enable(9999999999);

    For r_constr in c_constr(p_owner,p_table) Loop

        select cons.owner
             , cons.table_name 
          into wrk_owner
             , wrk_table_name
          from all_constraints   cons
         where owner = r_constr.r_owner
           and constraint_name = r_constr.r_constraint_name;

        For r_col in c_col ( r_constr.r_owner,wrk_table_name,r_constr.r_constraint_name )Loop

          If wrk_count = 0 then
            wrk_column_name := r_col.column_name;

          Else
            wrk_column_name := wrk_column_name ||', '||r_col.column_name;

          End If;
          wrk_count := wrk_count + 1;

        End Loop;
    
        dbms_output.put_line(rpad('-',(p_level+1)*3,' ')||to_char(p_level+1)||' - '||
                              wrk_owner||'.'||wrk_table_name
                              ||' :  '||r_constr.r_constraint_name||' ( '
                              || wrk_column_name||' )');



        Show_tab_deps(wrk_owner,wrk_table_name, p_level + 1);

        wrk_count  := 0;

    End loop;

  End;
End;
/

show errors

Grant execute on Show_tab_deps to public;

create public synonym Show_tab_deps for manager.Show_tab_deps;


