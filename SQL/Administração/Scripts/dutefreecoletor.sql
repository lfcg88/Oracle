ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE
SET LINESIZE 900
SET PAGESIZE 1000
COLUMN WHAT FORMAT a100
COLUMN NLS_ENV FORMAT a250
COLUMN INTERVAL FORMAT a50
COLUMN MISC_ENV FORMAT a20
COLUMN LOG_USER FORMAT a10                      
COLUMN PRIV_USER FORMAT a10
COLUMN SCHEMA_USER FORMAT a10







conn system/&senha@bhd1
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@dftpux01
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@fzd0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 


conn system/&senha@fld0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@ped0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 


conn system/&senha@rjd11
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 


prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 



conn system/&senha@bod0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor




conn system/&senha@rsd0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@dfd0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

Prompt ============================================ coletor======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@bad0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

spool off

conn system/&senha@RND0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@coletor

spool off





