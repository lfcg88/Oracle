PL/SQL Developer Test script 3.0
76
Declare 
--
  Cursor c1 is
    SELECT a.table_owner||'.'||a.table_name   Nm_tabela
         , a.index_owner||'.'|| a.index_name  Nm_Indice
         , A.column_name
         , column_position
         , low_value
         , high_value
         , num_nulls
         , num_distinct
      FROM DBA_IND_COLUMNS       a
         , system.stats_columns  b
     where b.owner = a.table_owner
       And b.table_name = a.table_name
       And b.column_name = a.column_name
and rownum < 100
      order by a.table_owner||'.'||a.table_name, a.index_owner||'.'||a.index_name, column_position;
--
  Cursor c2(p_indice varchar2) is
    SELECT a.index_owner
         , a.index_name  
         , a.table_owner
         , a.table_name  
         , A.column_name
         , column_position
         , low_value
         , high_value
         , num_nulls
         , num_distinct
      FROM DBA_IND_COLUMNS       a
         , system.stats_columns  b
     where b.owner = a.table_owner
       And b.table_name = a.table_name
       And b.column_name = a.column_name
       and a.index_name = substr(p_indice,instr(p_indice,'.')+1)
       and a.index_owner = substr(p_indice,1,instr(p_indice,'.')-1)
     Order by num_distinct desc;
--
  wrk_nm_col_atual   varchar2(1000);
  wrk_nm_col_correta varchar2(1000);
  wrk_indice         varchar2(1000) := null;
  wrk_owner          varchar2(1000) := null;
  wrk_tabela         varchar2(1000) := null;
--
Begin
--
  For r1 in c1 Loop
--
    For r2 in c2 (wrk_indice) Loop
      wrk_nm_col_correta := r2.column_name||' , '||wrk_nm_col_correta;
--
    End Loop;
  
    If wrk_indice <> r1.nm_indice Then

      If wrk_nm_col_atual <> wrk_nm_col_correta Then
        dbms_output.put_line('Tabela  : '||wrk_tabela);
        dbms_output.put_line('Indice  : '||wrk_indice);
        dbms_output.put_line('Colunas Atuais   : '||wrk_nm_col_atual);
        dbms_output.put_line('Colunas Sugeridas: '||wrk_nm_col_correta);
        dbms_output.put_line('/**********************************************/');
      End If;
--
      wrk_nm_col_atual   := null;
      wrk_nm_col_correta := null;
--
    End If;
    wrk_nm_col_atual := r1.column_name||' , '||wrk_nm_col_atual;
    wrk_indice       := r1.Nm_Indice;
    wrk_tabela       := r1.Nm_tabela;
    wrk_nm_col_correta := null;
--
  End Loop;
--
End;
0
0
