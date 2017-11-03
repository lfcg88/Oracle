Prompt ###############################################
Prompt #                                             #
Prompt #            TABLESPACE ESPACO BANCOS         #
Prompt #               EM TODAS AS BASES             #
Prompt #                                             #
Prompt ###############################################


ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE
SET LINESIZE 300


conn system/&senha@dsvcgmi11
@onde
@tablespace_espaco_critico

