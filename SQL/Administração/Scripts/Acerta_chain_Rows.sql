REM -------------------------------------------------------------------------- 
REM REQUIREMENTS: 
REM    CREATE TABLE, INSERT/SELECT/DELETE on the chained table 
REM    The following script was adapted from a demo script which created a 
REM    table with chained rows, then showed how to eliminate the chaining. 
REM    As modified, this script performs the following actions: 
REM 
REM     1.  Accepts a table name (which has chained rows) 
REM     2.  ANALYZEs the table and store the rows in CHAINED_ROWS 
REM     3.  CREATEs AS SELECT a temporary table with the chained rows 
REM     4.  DELETEs the rows from the original table 
REM     5.  INSERTs the rows from the temp table back into the original 
REM 
REM    This script will NOT work if the rows of the table are actually  
REM    too large to fit in a single block. 
REM -------------------------------------------------------------------------- 
REM Main text of script follows: 
 
set ECHO off  
  
REM  **********************************************  
REM  **********************************************  
Prompt  ANALYZE table to locate chained rows  
  
analyze table &1..&2 list chained rows into chained_rows;
  
REM  **********************************************  
REM  **********************************************  
Prompt  CREATE Temporary table with the chained rows  
  
create table REPADMIN.T_&2 as
Select *
  From &1..&2
 Where rowid in ( Select head_rowid
                    From REPADMIN.chained_rows);
Commit;

REM  **********************************************  
REM  **********************************************  
Prompt  DELETE the chained rows from the original table  
  
delete from &1..&2
where rowid in (select head_rowid  
                  from chained_rows); 
  
REM  **********************************************  
REM  **********************************************  
Prompt  INSERT the formerly chained rows back into table  
  
Insert into &1..&2
Select *  
  From REPADMIN.T_&2; 

 
REM  **********************************************  
REM  **********************************************  
Prompt  Identifica registros filhos

SELECT 'alter table '||OWNER||'.'||TABLE_NAME||' disable constraint '||CONSTRAINT_NAME||';' DESABILITA
  FROM DBA_CONSTRAINTS
 WHERE R_CONSTRAINT_NAME LIKE '%GRUPO_FAT%'
/

SELECT 'alter table '||OWNER||'.'||TABLE_NAME||' enable constraint '||CONSTRAINT_NAME||';' HABILITA
  FROM DBA_CONSTRAINTS
 WHERE R_CONSTRAINT_NAME LIKE '%GRUPO_FAT%'
/


DELETE FROM REPADMIN.chained_rows;

