############################################################################
PROCEDIMENTOS PARA SUBIR O BANCO APÓS A PERDA DOS ARQUIVOS DE REDOLOG
############################################################################

1- identificar e apagar todos os arquivos de logfile.

SQL> select MEMBER from v$logfile;

MEMBER
--------------------------------------------------------------------------------
/u01/app/oracle/oradata/DB11G/redo04.log
/u01/app/oracle/oradata/DB11G/redo03.log
/u01/app/oracle/oradata/DB11G/redo01.log
/u01/app/oracle/oradata/DB11G/redo02.log

rm /u01/app/oracle/oradata/DB11G/redo*

SQL> startup 
ORACLE instance started.

Total System Global Area  422670336 bytes
Fixed Size                  1336960 bytes
Variable Size             335546752 bytes
Database Buffers           79691776 bytes
Redo Buffers                6094848 bytes
Database mounted.
ORA-03113: end-of-file on communication channel
Process ID: 3081
Session ID: 1 Serial number: 5

### Verificar o alert.log em busca de erros ###

ORA-00313: open failed for members of log group 1 of thread 1
ORA-00312: online log 1 thread 1: '/u01/app/oracle/oradata/DB11G/redo01.log'
ORA-27037: unable to obtain file status
Linux Error: 2: No such file or directory
Additional information: 3

2 - Criar um grupo novo de arquivos de redolog.

SQL> startup mount;

## Usando OMF e Multiplexando arquivos de redolog ##
SQL> alter system set db_create_online_log_dest_1='/u01/app/oracle/oradata/DB11G';

System altered.

SQL> alter system set db_create_online_log_dest_2='/u01/app/oracle/flash_recovery_area/DB11G/onlinelog';

System altered.

## Adicionando os grupos 5 e 6 de arquivos de redolog, pois o banco deve ter no mínimo dois grupos ##

SQL> ALTER database ADD logfile GROUP 5 SIZE 50M;
SQL> ALTER database ADD logfile GROUP 6 SIZE 50M;

## Verificando os grupos e seus membros existentes ##

SQL> select GROUP#, MEMBER from v$logfile order by 1;

    GROUP# MEMBER
---------- ----------------------------------------------------------------------------------------------------
         1 /u01/app/oracle/oradata/DB11G/redo01.log
         2 /u01/app/oracle/oradata/DB11G/redo02.log
         3 /u01/app/oracle/oradata/DB11G/redo03.log
         4 /u01/app/oracle/oradata/DB11G/redo04.log
         5 /u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_5_9bymkth9_.log
         5 /u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_5_9bymktm6_.log
         6 /u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_6_9bynsocb_.log
         6 /u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_6_9bynso4q_.log

8 rows selected.

3- Recriar o controlfile apagando as referências aos arquivos de redologque foram apagados

## Criando um backup do controlfile no formato de texto para ser executado posteriormente ##

SQL> alter database backup controlfile to trace as '/u01/backup/controlfile.trace';

Database altered.

## Editar o arquivo e apagar a referência - no sistema operacional ## 

$vi /u01/backup/controlfile.trace

CREATE CONTROLFILE REUSE DATABASE "DB11G" /*substituir NORESETLOGS por RESETLOGS*/ RESETLOGS  NOARCHIVELOG
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  /*GROUP 1 '/u01/app/oracle/oradata/DB11G/redo01.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 2 '/u01/app/oracle/oradata/DB11G/redo02.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 3 '/u01/app/oracle/oradata/DB11G/redo03.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 4 '/u01/app/oracle/oradata/DB11G/redo04.log'  SIZE 50M BLOCKSIZE 512,*/
  GROUP 5 ('/u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_5_9bymkth9_.log',
		   '/u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_5_9bymktm6_.log') SIZE 50M BLOCKSIZE 512,
  GROUP 6 ('/u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_6_9bynso4q_.log',
           '/u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_6_9bynsocb_.log') SIZE 50M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/u01/app/oracle/oradata/DB11G/system01.dbf',
  '/u01/app/oracle/oradata/DB11G/sysaux01.dbf',
  '/u01/app/oracle/oradata/DB11G/undotbs01.dbf',
  '/u01/app/oracle/oradata/DB11G/users01.dbf',
  '/u01/app/oracle/oradata/DB11G/example01.dbf',
  '/u01/app/oracle/oradata/DB11G/aplicacao.dbf'
CHARACTER SET WE8MSWIN1252;


SQL> shutdown immediate;
ORA-01109: database not open
Database dismounted.
ORACLE instance shut down.

SQL> startup nomount;
ORACLE instance started.

Total System Global Area  422670336 bytes
Fixed Size                  1336960 bytes
Variable Size             335546752 bytes
Database Buffers           79691776 bytes
Redo Buffers                6094848 bytes

## Executar as linhas do arquivo controfile.trace conforme editado anteriormente ##

SQL> CREATE CONTROLFILE REUSE DATABASE "DB11G" RESETLOGS  NOARCHIVELOG
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 100
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  /*GROUP 1 '/u01/app/oracle/oradata/DB11G/redo01.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 2 '/u01/app/oracle/oradata/DB11G/redo02.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 3 '/u01/app/oracle/oradata/DB11G/redo03.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 4 '/u01/app/oracle/oradata/DB11G/redo04.log'  SIZE 50M BLOCKSIZE 512,*/
  GROUP 5 ('/u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_5_9bymkth9_.log',
                   '/u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_5_9bymktm6_.log') SIZE 50M BLOCKSIZE 512,
  GROUP 6 ('/u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_6_9bynso4q_.log',
           '/u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_6_9bynsocb_.log') SIZE 50M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/u01/app/oracle/oradata/DB11G/system01.dbf',
  '/u01/app/oracle/oradata/DB11G/sysaux01.dbf',
  '/u01/app/oracle/oradata/DB11G/undotbs01.dbf',
  '/u01/app/oracle/oradata/DB11G/users01.dbf',
  '/u01/app/oracle/oradata/DB11G/example01.dbf',
  '/u01/app/oracle/oradata/DB11G/aplicacao.dbf'
CHARACTER SET WE8MSWIN1252;

Control file created.

## Verificar os grupos  seus membros existentes após a alteração ##

SQL> select GROUP#, MEMBER from v$logfile order by 1;

    GROUP# MEMBER
---------- ----------------------------------------------------------------------------------------------------
         5 /u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_5_9bymkth9_.log
         5 /u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_5_9bymktm6_.log
         6 /u01/app/oracle/oradata/DB11G/DB11G/onlinelog/o1_mf_6_9bynso4q_.log
         6 /u01/app/oracle/flash_recovery_area/DB11G/onlinelog/DB11G/onlinelog/o1_mf_6_9bynsocb_.log


## Abrir o Banco ##

SQL> alter database open resetlogs;

## Verificar o funcionamento dos arquivos de redo ##

SQL> select GROUP#,  STATUS  from  v$log;

    GROUP# STATUS
---------- ----------------
         5 CURRENT
         6 UNUSED

SQL> alter system switch logfile;

System altered.

SQL> select GROUP#,  STATUS  from  v$log;

    GROUP# STATUS
---------- ----------------
         5 ACTIVE
         6 CURRENT

## FIM ##