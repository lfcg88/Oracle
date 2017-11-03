rem     DROPOBJ.SQL 
rem        Delete all objects in the schema 
rem         
rem     Start the script:  Echoes how many objects will be dropped  
rem     by type.  Type "enter" to continue or "CTRL+C" to abort the  
rem     script.  This script produce a text file mydel.sql which is  
rem        deleted (OS dependent) at the end.  
 
set feedback off 
 
select object_type, count(object_type) "Count" from obj 
group by object_type 
/ 
set head off 
 
select ' delete '||count(*)||' objects from '||user|| 
' !' "WARNING" from obj 
/ 
prompt Ctrl-C to stop.....return to go 
pause 
set term off  
prompt Working ....  
spool mydel.sql 
select 'spool mydel.log' from dual 
/ 
select 'alter table '||table_name||' drop constraint '|| 
       constraint_name||' cascade ;' from user_constraints; 
/ 
select 'truncate cluster '||cluster_name||' including tables cascade  
       constraints;' from user_clusters 
/ 
select 'truncate table '||table_name||';' from user_tables where  
       cluster_name is null 
 
/ 
select 'drop '||object_type||' '||object_name||';' from user_objects 
       where object_type not in ('INDEX') 
/ 
select 'spool off' from dual 
/ 
spool off 
@mydel.sql 
set term on  
select chr(7)||decode (count(*) ,0,'Well done !','Incomplete')  
       "Statut" from obj 
/ 
set head on 
-- UNIX only : 
-- !rm mydel.sql 
