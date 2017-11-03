Prompt ###############################################
Prompt #                                             #
Prompt #            TABLESPACE ESPACO BANCOS         #
Prompt #               EM TODAS AS BASES             #
Prompt #                                             #
Prompt ###############################################


ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE
SET LINESIZE 300


conn system/&senha@mia0
@onde
@tablespace_espaco_critico

conn system/&senha@mia2
@onde
@tablespace_espaco_critico

conn system/&senha@mia1
@onde
@tablespace_espaco_critico

conn system/&senha@rjd20
@onde
@tablespace_espaco_critico

conn system/&senha@bhd1
@onde
@tablespace_espaco_critico

conn system/&senha@dftpux01
@onde
@tablespace_espaco_critico

conn system/&senha@fzd0
@onde
@tablespace_espaco_critico

conn system/&senha@rjd12
@onde
@tablespace_espaco_critico

conn system/&senha@rjd19
@onde
@tablespace_espaco_critico

conn system/&senha@rjd6
@onde
@tablespace_espaco_critico

conn system/&senha@fld0
@onde
@tablespace_espaco_critico

conn system/&senha@ped0
@onde
@tablespace_espaco_critico

conn system/&senha@rjd10
@onde
@tablespace_espaco_critico

conn system/&senha@rjd11
@onde
@tablespace_espaco_critico

conn system/&senha@rjd14
@onde
@tablespace_espaco_critico

conn system/&senha@bod0
@onde
@tablespace_espaco_critico

conn system/&senha@rsd0
@onde
@tablespace_espaco_critico

conn system/&senha@rjd5
@onde
@tablespace_espaco_critico

conn system/&senha@rjd9
@onde
@tablespace_espaco_critico

conn system/&senha@dfd0
@onde
@tablespace_espaco_critico

conn system/&senha@rjd3
@onde
@tablespace_espaco_critico

conn system/&senha@spd1
@onde
@tablespace_espaco_critico

conn system/&senha@bad0
@onde
@tablespace_espaco_critico






