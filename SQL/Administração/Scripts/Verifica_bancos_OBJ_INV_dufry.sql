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
Prompt Consulta banco MIA0
Prompt ===================
conn system/&senha@MIA0
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco MIA2
Prompt ===================
conn system/&senha@MIA2
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD20
Prompt ===================
conn system/&senha@RJD20
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco BHD1
Prompt ===================
conn system/&senha@BHD1
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco DFTPUX01
Prompt =======================
conn system/&senha@DFTPUX01
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco FZD0
Prompt ===================
conn system/&senha@FZD0
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD12
Prompt ===================
conn system/&senha@RJD12
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD19
Prompt ===================
conn system/&senha@RJD19
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD6
Prompt ===================
conn system/&senha@RJD6
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco FLD0
Prompt ===================
conn system/&senha@FLD0
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco PED0
Prompt ===================
conn system/&senha@PED0
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD10
Prompt ===================
conn system/&senha@RJD10
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD11
Prompt ===================
conn system/&senha@RJD11
@onde
 
@lista_invalidos



prompt ##############################################################################################
Prompt Consulta banco 
Prompt ===================
conn system/&senha@BOD0
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RSD0
Prompt ===================
conn system/&senha@RSD0
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD5
Prompt ===================
conn system/&senha@RJD5
@onde
 
@lista_invalidos



prompt ##############################################################################################
Prompt Consulta banco RJD9
Prompt ===================
conn system/&senha@RJD9
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco DFD0
Prompt ===================
conn system/&senha@DFD0
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD3
Prompt ===================
conn system/&senha@RJD3
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco SPD1
Prompt ===================
conn system/&senha@SPD1
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD21
Prompt ===================
conn system/&senha@RJD21
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco RJD14
Prompt ===================
conn system/&senha@RJD14
@onde
 
@lista_invalidos


prompt ##############################################################################################
Prompt Consulta banco BAD0
Prompt ===================
conn system/&senha@BAD0
@onde
 
@lista_invalidos




prompt ##############################################################################################
Prompt Consulta banco RND0
Prompt ===================
conn system/&senha@RND0
@onde
 
@lista_invalidos

