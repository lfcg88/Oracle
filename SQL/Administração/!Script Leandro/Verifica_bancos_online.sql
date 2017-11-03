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
select count(1) from v$session;
select * from v$session;

prompt ##############################################################################################
Prompt Consulta banco MIA2
Prompt ===================
conn system/&senha@MIA2
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD20
Prompt ===================
conn system/&senha@RJD20
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco BHD1
Prompt ===================
conn system/&senha@BHD1
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco DFTPUX01
Prompt =======================
conn system/&senha@DFTPUX01
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco FZD0
Prompt ===================
conn system/&senha@FZD0
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD12
Prompt ===================
conn system/&senha@RJD12
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD19
Prompt ===================
conn system/&senha@RJD19
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD6
Prompt ===================
conn system/&senha@RJD6
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco FLD0
Prompt ===================
conn system/&senha@FLD0
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco PED0
Prompt ===================
conn system/&senha@PED0
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD10
Prompt ===================
conn system/&senha@RJD10
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD11
Prompt ===================
conn system/&senha@RJD11
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco 
Prompt ===================
conn system/&senha@BOD0
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RSD0
Prompt ===================
conn system/&senha@RSD0
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD5
Prompt ===================
conn system/&senha@RJD5
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD9
Prompt ===================
conn system/&senha@RJD9
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco DFD0
Prompt ===================
conn system/&senha@DFD0
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD3
Prompt ===================
conn system/&senha@RJD3
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco SPD1
Prompt ===================
conn system/&senha@SPD1
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD21
Prompt ===================
conn system/&senha@RJD21
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD14
Prompt ===================
conn system/&senha@RJD14
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco BAD0
Prompt ===================
conn system/&senha@BAD0
@onde
select count(1) from v$session;


prompt ##############################################################################################
prompt #                                                                                            #
prompt #                    VERIFICAÇÃO DOS BANCOS DE DESENVOLVIMENTO                               #
prompt #                                                                                            #
prompt ##############################################################################################
ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM em Desenvolvimento:' HIDE

prompt ##############################################################################################
Prompt Consulta banco RJADUX01
Prompt ===================
conn system/&senha@RJADUX01
@onde
select count(1) from v$session;



prompt ##############################################################################################
Prompt Consulta banco RJD8
Prompt ===================
conn system/&senha@RJD8
@onde
select count(1) from v$session;



prompt ##############################################################################################
Prompt Consulta banco FLD0DSV
Prompt ===================
conn system/&senha@FLD0DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco PUX01DSV
Prompt ===================
conn system/&senha@PUX01DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco MIA0DSV
Prompt ===================
conn system/&senha@MIA0DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco MIA2DSV
Prompt ===================
conn system/&senha@MIA2DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD10DSV
Prompt ===================
conn system/&senha@RJD10DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD14DSV
Prompt ===================
conn system/&senha@RJD14DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD19DSV
Prompt ===================
conn system/&senha@RJD19DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD3DSV
Prompt ===================
conn system/&senha@RJD3DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD6DSV
Prompt ===================
conn system/&senha@RJD6DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco BHD1DSV
Prompt ===================
conn system/&senha@BHD1DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco FZD0DSV
Prompt ===================
conn system/&senha@FZD0DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco PED0DSV
Prompt ===================
conn system/&senha@PED0DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD11DSV
Prompt ===================
conn system/&senha@RJD11DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD12DSV
Prompt ===================
conn system/&senha@RJD12DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD5DSV
Prompt ===================
conn system/&senha@RJD5DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD9DSV
Prompt ===================
conn system/&senha@RJD9DSV
@onde
select count(1) from v$session;



prompt ##############################################################################################
Prompt Consulta banco RSD0DSV
Prompt ===================
conn system/&senha@RSD0DSV
@onde
select count(1) from v$session;



prompt ##############################################################################################
Prompt Consulta banco SPD1DSV
Prompt ===================
conn system/&senha@SPD1DSV
@onde
select count(1) from v$session;


prompt ##############################################################################################
Prompt Consulta banco RJD21DSV
Prompt =======================
conn system/&senha@RJD21DSV
@onde
select count(1) from v$session;
