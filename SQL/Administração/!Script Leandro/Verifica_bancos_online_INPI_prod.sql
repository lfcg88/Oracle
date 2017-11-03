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
Prompt Consulta banco DBPAG
Prompt ===================
conn system/&senha@DBPAG
select count(1) from v$session;
SELECT SUBSTR(GLOBAL_NAME,1,25) ONDE, SUBSTR(USER,1,25)     QUEM
  FROM GLOBAL_NAME;


prompt ##############################################################################################
Prompt Consulta banco DBPTN
Prompt ===================
conn system/&senha@DBPTN
SELECT SUBSTR(GLOBAL_NAME,1,25) ONDE, SUBSTR(USER,1,25)     QUEM
  FROM GLOBAL_NAME;
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco DBPTN
Prompt ===================
conn system/inpiBR01@KERIGMA
SELECT SUBSTR(GLOBAL_NAME,1,25) ONDE, SUBSTR(USER,1,25)     QUEM
  FROM GLOBAL_NAME;
select count(1) from v$session;






