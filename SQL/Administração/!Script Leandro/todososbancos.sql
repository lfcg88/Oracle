                                                

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


spool oracle_operacao.log
conn system/&senha@mia0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 


prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@mia2
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd20
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@bhd1
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@dftpux01
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@fzd0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd12
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd19
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd6
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@fld0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@ped0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd10
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd11
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 


prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd14
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@bod0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 


prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rsd0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd5
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd9
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@dfd0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@rjd3
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@spd1
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

Prompt ============================================ nconectados======================================
 

prompt ##############################################################################################
prompt 
prompt 
prompt 
prompt 

conn system/&senha@bad0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql



conn system/&senha@RND0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql


conn system/&senha@CBD0
SET SERVEROUTPUT ON
prompt ##############################################################################################
@onde
@senhaoperacao.sql

spool off





