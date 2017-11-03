SET ECHO off 
REM -------------------------------------------------------------------------- 
REM REQUIREMENTS: 
REM    None -- checks only the USER_ views 
REM -------------------------------------------------------------------------- 
REM    This file checks the current users Foreign Keys to make sure of the  
REM    following: 
REM 
REM    1) All the FK columns are have indexes to prevent a possible locking 
REM       problem that can slow down the database. 
REM 
REM    2) Checks the ORDER OF THE INDEXED COLUMNS. To prevent the locking 
REM       problem the columns MUST be index in the same order as the FK is 
REM       defined. 
REM    
REM    3) If the script finds and miss match the script reports the correct  
REM       order of columns that need to be added to prevent the locking 
REM       problem. 
REM 
REM  
REM     
REM ------------------------------------------------------------------------- 
REM Main text of script follows: 
undefine p_owner
ACCEPT p_owner CHAR prompt 'Digite owner a ser analisado : ';
 
Declare 
  t_CONSTRAINT_TYPE            ALL_CONSTRAINTS.CONSTRAINT_TYPE%type; 
  t_CONSTRAINT_NAME            ALL_CONSTRAINTS.CONSTRAINT_NAME%type; 
  t_TABLE_NAME                 ALL_CONSTRAINTS.TABLE_NAME%type; 
  t_R_CONSTRAINT_NAME          ALL_CONSTRAINTS.R_CONSTRAINT_NAME%type; 
  tt_CONSTRAINT_NAME           ALL_CONS_COLUMNS.CONSTRAINT_NAME%type; 
  tt_TABLE_NAME                ALL_CONS_COLUMNS.TABLE_NAME%type; 
  tt_COLUMN_NAME               ALL_CONS_COLUMNS.COLUMN_NAME%type; 
  tt_POSITION                  ALL_CONS_COLUMNS.POSITION%type; 
  Err_TABLE_NAME               ALL_CONSTRAINTS.TABLE_NAME%type; 
  Err_COLUMN_NAME              ALL_CONS_COLUMNS.COLUMN_NAME%type; 
  Err_POSITION                 ALL_CONS_COLUMNS.POSITION%type; 
  ot_R_CONSTRAINT_NAME         ALL_CONSTRAINTS.OWNER%type; 
  wrk_owner                    ALL_CONSTRAINTS.OWNER%type; 
  tt_Dummy                     number; 
  tt_dummyChar                 varchar2(2000); 
  l_Cons_Found_Flag            VarChar2(1); 
  tLineNum                     number;
  DebugLevel                   number := 99; -- >> 99 = dump all info` 
  DebugFlag                    varchar(1) := 'N'; -- Turn Debugging on 
  t_Error_Found                varchar(1); 
--
  Cursor UserTabs is
     Select owner
          , table_name
       From all_tables
      Where owner = upper('&p_owner')
      Order By table_name;
--
  Cursor TableCons is
     Select CONSTRAINT_TYPE
          , CONSTRAINT_NAME
          , R_CONSTRAINT_NAME
          , R_OWNER
       From all_constraints 
      Where OWNER = USER
        And table_name = t_Table_Name 
        And CONSTRAINT_TYPE  = 'R' 
      Order By TABLE_NAME
          , CONSTRAINT_NAME;
--
  Cursor ConColumns is 
     select CONSTRAINT_NAME
          , TABLE_NAME
          , COLUMN_NAME
          , POSITION
       From all_cons_columns 
      Where OWNER = USER
        And CONSTRAINT_NAME = t_CONSTRAINT_NAME 
      Order by POSITION;
--
  Cursor IndexColumns is
     Select TABLE_NAME
          , COLUMN_NAME
          , POSITION 
       From all_cons_columns 
      Where OWNER = USER 
        And CONSTRAINT_NAME = t_CONSTRAINT_NAME 
      Order By POSITION; 
--
Begin 
--
  tLineNum := 1000; 
  Open UserTabs; 
  Loop 
  Fetch UserTabs 
   Into wrk_owner
      , t_TABLE_NAME; 
  t_Error_Found := 'N'; 
  Exit When UserTabs%NOTFOUND; 
--
  -- Log current table 
    tLineNum := tLineNum + 1; 
    Begin
      Insert Into ck_log 
             ( owner
             , LineNum
             , LineMsg ) 
      Values ( wrk_owner
             , tLineNum
             , NULL ); 
    Exception
      When Others Then
        dbms_output.put_line('Erro 01: '||Sqlerrm);
    End;
-- 
    tLineNum := tLineNum + 1; 
--
    Begin
      Insert Into ck_log 
             ( owner
             , LineNum
             , LineMsg ) 
      Values ( wrk_owner
             , tLineNum
             , 'Checking Table '||wrk_owner||'.'||t_Table_Name); 
    Exception
      When Others Then
        dbms_output.put_line('Erro 02: '||Sqlerrm);
    End;
--
    l_Cons_Found_Flag := 'N'; 
    Open TableCons; 
    Loop
    Fetch TableCons 
     Into t_CONSTRAINT_TYPE
        , t_CONSTRAINT_NAME
        , t_R_CONSTRAINT_NAME
        , ot_R_CONSTRAINT_NAME; 
     Exit When TableCons%NOTFOUND; 
--
      If ( DebugFlag = 'Y' And DebugLevel >= 99 ) Then 
        Begin 
          tLineNum := tLineNum + 1; 
          Insert Into ck_log 
                 ( owner
                 , LineNum
                 , LineMsg ) 
          Values ( wrk_owner
                 , tLineNum
                 , 'Found CONSTRAINT_NAME = '|| t_CONSTRAINT_NAME); 
--
          tLineNum := tLineNum + 1; 
--
          Insert Into ck_log 
                 ( owner
                 , LineNum
                 , LineMsg ) 
          Values ( wrk_owner
                 , tLineNum
                 , 'Found CONSTRAINT_TYPE = '|| t_CONSTRAINT_TYPE); 
--
          tLineNum := tLineNum + 1; 
          Insert Into ck_log 
                 ( owner
                 , LineNum
                 , LineMsg ) 
          Values ( wrk_owner
                 , tLineNum
                 , 'Found R_CONSTRAINT_NAME = '|| t_R_CONSTRAINT_NAME); 
--
          commit; 
--
        Exception
          When Others Then
            dbms_output.put_line('Erro 03: '||Sqlerrm);
        End; 
      End If; 
--
      Open ConColumns; 
      Loop
      Fetch ConColumns 
       Into tt_CONSTRAINT_NAME
          , tt_TABLE_NAME
          , tt_COLUMN_NAME
          , tt_POSITION;
      Exit When ConColumns%NOTFOUND; 
--
        If ( DebugFlag = 'Y' and DebugLevel >= 99 ) Then 
          Begin 
            tLineNum := tLineNum + 1; 
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values (wrk_owner
                   , tLineNum
                   , NULL ); 
 --
            tLineNum := tLineNum + 1; 
--
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values ( wrk_owner
                   , tLineNum
                   , 'Found CONSTRAINT_NAME = '|| tt_CONSTRAINT_NAME); 
--
            tLineNum := tLineNum + 1; 
--
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values ( wrk_owner
                   , tLineNum
                   , 'Found TABLE_NAME = '|| tt_TABLE_NAME); 
--
            tLineNum := tLineNum + 1; 
--
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values ( wrk_owner
                   , tLineNum
                   , 'Found COLUMN_NAME = '|| tt_COLUMN_NAME); 
--
            tLineNum := tLineNum + 1; 
--
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values ( wrk_owner
                   , tLineNum
                   , 'Found POSITION = '|| tt_POSITION); 
--
          Commit; 
--
          Exception
            When Others Then
              dbms_output.put_line('Erro 04: '||Sqlerrm);
          End; 
      End If; 
--
      Begin 
        Select 1 
          Into tt_Dummy 
          From all_ind_columns 
         Where TABLE_OWNER = wrk_owner
           And TABLE_NAME  =  tt_TABLE_NAME 
           And COLUMN_NAME = tt_COLUMN_NAME 
           And COLUMN_POSITION = tt_POSITION; 
        If ( DebugFlag = 'Y' and DebugLevel >= 99 ) Then 
          Begin 
            tLineNum := tLineNum + 1; 
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values ( wrk_owner
                   , tLineNum
                   , 'Row Has matching Index' ); 
          Exception
            When Others Then
              dbms_output.put_line('Erro 05: '||Sqlerrm);
          End; 
        End If;
      Exception 
        When Too_Many_Rows Then 
          If ( DebugFlag = 'Y' and DebugLevel >= 99 ) Then 
            Begin 
              tLineNum := tLineNum + 1; 
              Insert Into ck_log 
                     ( owner
                     , LineNum
                     , LineMsg ) 
              Values ( wrk_owner
                     , tLineNum
                     , 'Row Has matching Index' ); 
            Exception
              When Others Then
                dbms_output.put_line('Erro 06: '||Sqlerrm);
            End; 
          End If; 
        When no_data_found Then 
          If ( DebugFlag = 'Y' and DebugLevel >= 99 ) Then 
            Begin 
              tLineNum := tLineNum + 1; 
              Insert Into ck_log 
                     ( owner
                     , LineNum
                     , LineMsg ) 
              Values ( wrk_owner
                     , tLineNum
                     , 'NO MATCH FOUND' ); 
              Commit; 
            Exception
              When Others Then
                dbms_output.put_line('Erro 07: '||Sqlerrm);
            End; 
          End If; 
          t_Error_Found := 'Y'; 
          Begin
            Select Distinct TABLE_NAME 
              Into tt_dummyChar 
              From dba_cons_columns
             Where OWNER = ot_R_CONSTRAINT_NAME
               And CONSTRAINT_NAME = t_R_CONSTRAINT_NAME; 
            tLineNum := tLineNum + 1;
          Exception
            When Others Then
              dbms_output.put_line('Erro 08: '||Sqlerrm);
          End; 
          Begin
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values ( wrk_owner
                   , tLineNum
                   , 'Changing data in table '||ot_R_CONSTRAINT_NAME||'.'||tt_dummyChar
                      ||' will lock table ' ||tt_TABLE_NAME);
          Exception
            When Others Then
              dbms_output.put_line('Erro 09: '||Sqlerrm);
          End; 
          commit; 
            tLineNum := tLineNum + 1; 
          Begin
            Insert Into ck_log 
                   ( owner
                   , LineNum
                   , LineMsg ) 
            Values ( wrk_owner
                   , tLineNum
                   , 'Create an index on table '||tt_TABLE_NAME
                     ||' with the following columns to remove lock problem');
          Exception
            When Others Then
              dbms_output.put_line('Erro 10: '||Sqlerrm);
          End; 
          Open IndexColumns ; 
          Loop 
          Fetch IndexColumns 
          Into Err_TABLE_NAME, 
               Err_COLUMN_NAME, 
               Err_POSITION; 
          Exit When IndexColumns%NotFound; 
          tLineNum := tLineNum + 1; 
            Begin
              Insert Into ck_log 
                     ( owner
                     , LineNum
                     , LineMsg ) 
              Values ( wrk_owner
                     , tLineNum
                     ,'Column = '||Err_COLUMN_NAME||' ('||Err_POSITION||')'); 
            Exception
              When Others Then
                dbms_output.put_line('Erro 07: '||Sqlerrm);
            End;
          End Loop; 
          Close IndexColumns; 
      End;
    End Loop; 
    Commit; 
  Close ConColumns; 
  End Loop; 
  If ( t_Error_Found = 'N' ) Then 
    Begin 
      tLineNum := tLineNum + 1; 
      Insert Into repadmin.ck_log 
              ( owner
              , LineNum
              , LineMsg ) 
       values ( wrk_owner
              , tLineNum
              , 'No foreign key errors found'); 
    Exception
      When Others Then
        dbms_output.put_line('Erro 08: '||Sqlerrm);
    End; 
  End If; 
--
  Commit; 
  Close TableCons; 
End Loop; 
Commit; 
End; 


/* 
select LineMsg
from ck_log
where LineMsg NOT LIKE 'Checking%' AND
      LineMsg NOT LIKE 'No foreign key%'
order by LineNum

COL OWNER FORMAT A20
COL QTD FORMAT 999999999
SELECT OWNER
     , COUNT(1)  QTD
  FROM REPADMIN.ck_log
GROUP BY OWNER

*/
/
