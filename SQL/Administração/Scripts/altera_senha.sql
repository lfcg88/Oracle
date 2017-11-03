Prompt ###############################################
Prompt #                                             #
Prompt #            ALTERA SENHA NOs BANCOS          #
Prompt #               EM TODAS AS BASES             #
Prompt #                                             #
Prompt ###############################################


ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE
ACCEPT USUARIO CHAR PROMPT 'Digite o nome do usuário no banco :' 
ACCEPT SENHANOVA CHAR PROMPT 'Digite a senha Nova do usuário:' HIDE
SET LINESIZE 300


conn system/&senha@mia0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@mia2
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@mia1
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd20
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@bhd1
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@dftpux01
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@fzd0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd12
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd19
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd6
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@fld0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@ped0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd10
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd14
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@bod0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@dif02
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@dif01
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rsd0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd5
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd9
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@dfd0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd18
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/

conn system/&senha@rjd3
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/
conn system/&senha@spd1
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/
conn system/&senha@bad0
@onde
ALTER USER upper(&usuario)
  IDENTIFIED BY &senhanova
/






