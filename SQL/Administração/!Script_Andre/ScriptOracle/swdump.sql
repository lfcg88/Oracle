EM
REM
REM Veja: a documentação LIBRARY_CACHE_LOCK.html
REM       e library_cache_pin_wait ajuda a encontrar o problema utilizando os backup abaixo:
REM


 -- While an operation is hanging, open a new session and launch the following  statement   

  	ALTER SESSION SET MAX_DUMP_FILE_SIZE = UNLIMITED;

  	ALTER SESSION SET EVENTS 'IMMEDIATE TRACE NAME SYSTEMSTATE LEVEL 8';   

  Na versão 8.1.7 pode ser usado:

	
  

 -- para um melhor entendimento veja: LIBRARY_CACHE_LOCK.htm


 -- FACA O BACKUP DE ALGUAMS TABELAS

 CREATE TABLE agent.LOCK_2306      as     SELECT * FROM SYS.V_$LOCK;

 CREATE TABLE agent.SESSION_2306    as    SELECT * FROM SYS.V_$SESSION;

 CREATE TABLE agent.SESSION_WAIT_2306   as  SELECT * FROM SYS.V_$SESSION_WAIT;

 CREATE TABLE agent.PROCESS_2306         AS  SELECT * FROM SYS.V_$PROCESS;

 CREATE TABLE agent.latch_2306           as SELECT * FROM SYS.V_$latch;

 CREATE TABLE agent.sqlarea_2306           as SELECT * FROM SYS.V_$sqlarea;

 CREATE TABLE agent.access_2306           as SELECT * FROM SYS.V_$access;

 create table DBA_DDL_LOCKS_07042003  as select * from   DBA_DDL_LOCKS  ;

 create table session_event_2306  as select * from v$session_event

--- BACKUP SOMENTE CONNECTADO COMO INTERNAL

CREATE TABLE agent.X$KGLLK_2306           as SELECT * FROM SYS.X$KGLLK;

create table agent.x$kglob_2306           as select * from sys.x$kglob;

create TABLE agent.x$kglpn_2306           as select * from sys.x$kglpn;





