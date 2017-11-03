Prompt ###############################################
Prompt #                                           			  #
Prompt #                   CONSULTAS              		   #
Prompt #               EM TODAS AS BASES      		       #
Prompt #                                        			     #
Prompt ###############################################

prompt ##############################################################################################
prompt #                                                                                            #
prompt #                    VERIFICAÇÃO DOS BANCOS DE PRODUÇÃO                                      #
prompt #                                                                                            #
prompt ##############################################################################################
ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM em Produção:' HIDE
SET LINESIZE 900
SET PAGESIZE 1000

prompt ##############################################################################################
Prompt Consulta banco DBPAG_HOM
Prompt ===================
conn system/&senha@DBPAG_HOM
select count(1) from v$session;
SELECT SUBSTR(GLOBAL_NAME,1,25) ONDE, SUBSTR(USER,1,25)     QUEM
  FROM GLOBAL_NAME;


prompt ##############################################################################################
Prompt Consulta banco orcl
Prompt ===================
conn system/&senha@orcl
SELECT SUBSTR(GLOBAL_NAME,1,25) ONDE, SUBSTR(USER,1,25)     QUEM
  FROM GLOBAL_NAME;
select count(1) from v$session;



prompt ##############################################################################################
Prompt Consulta banco orcl2
Prompt ===================
conn system/&senha@orcl2
SELECT SUBSTR(GLOBAL_NAME,1,25) ONDE, SUBSTR(USER,1,25)     QUEM
  FROM GLOBAL_NAME;
select count(1) from v$session;



prompt ##############################################################################################
Prompt Consulta banco dsv01
Prompt ===================
conn system/&senha@dsv01
SELECT SUBSTR(GLOBAL_NAME,1,25) ONDE, SUBSTR(USER,1,25)     QUEM
  FROM GLOBAL_NAME;
select count(1) from v$session;




