Prompt ###############################################
Prompt #                                             #
Prompt #                   CONSULTAS                 #
Prompt #               EM TODAS AS BASES             #
Prompt #                                             #
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
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco DBPTN
Prompt ===================
conn system/&senha@DBPTN
@onde
 
@lista_invalidos


