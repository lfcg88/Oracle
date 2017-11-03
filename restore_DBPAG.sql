######################################
Servidor - Cronos / Instancia - DBPAG
######################################

################
Script de backup
################

/backup/rman/DBPTN/scripts/backup_dbpag.sh

###################
Diretório de backup
###################

/backup/rman/DBPAG

#################################################
Servidor - srv-oracle-desenv / Instancia - DBPAG
#################################################

#####################
Váriaveis de ambiente
#####################

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1/
export ORACLE_SID=DBPAG
export PATH=/u01/app/oracle/product/11.2.0/db_1/bin:/etc:/usr/local/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/oracle/bin


###################
Diretório de backup
###################

/backup/rman/DBPAG

########################
Diretório dos datafiles
########################

/u02/oracle/oradata/DBPAG/datafile/

########################
Diretório onlinelog
########################
/u02/app/oracle/DBPAG/onlinelog1/
/u02/app/oracle/DBPAG/onlinelog2/

######################
Diretório de archives
######################
/u02/app/oracle/flash_recovery/DBPTN/

##################
Diretório do init
##################

/u01/app/oracle/product/11.2.0/db_1/dbs/initDBPTN.ora

################
Conteudo do init 
create pfile from spfile;
################

DBPAG.__db_cache_size=637534208
DBPAG.__java_pool_size=16777216
DBPAG.__large_pool_size=335544320
DBPAG.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
DBPAG.__pga_aggregate_target=553648128
DBPAG.__sga_target=2147483648
DBPAG.__shared_io_pool_size=0
DBPAG.__shared_pool_size=1090519040
DBPAG.__streams_pool_size=33554432
*._shared_io_pool_size=0
*.audit_file_dest='/u01/app/oracle/admin/DBPAG/adump'
*.audit_trail='db'
*.compatible='11.2.0.0.0'
*.control_files='/u02/app/oracle/DBPAG/onlinelog1/controlfile1.ctl','/u02/app/oracle/DBPAG/onlinelog2/controlfile2.ctl'
*.db_block_size=8192
*.db_cache_size=0
*.db_domain='INPI.GOV.BR'
*.db_name='DBPAG'
*.db_recovery_file_dest='/u02/app/oracle/flash_recovery/'
*.db_recovery_file_dest_size=53687091200
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(protocol=TCP)(disp=3)'
*.java_pool_size=16777216
*.job_queue_processes=1000
*.large_pool_size=335544320
*.local_listener='(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=cronos.inpi.gov.br)(PORT=1521))))'
*.LOG_ARCHIVE_DEST_1='location=/u02/app/oracle/flash_recovery/DBPTN MANDATORY'
*.log_archive_dest_2=''
*.LOG_ARCHIVE_FORMAT='log_DBPAG_%t_%S_%R.arc'
*.max_dispatchers=5
*.max_shared_servers=10
*.memory_target=2701131776
*.open_cursors=300
*.pga_aggregate_target=0
*.processes=1500
*.remote_login_passwordfile='EXCLUSIVE'
*.sessions=2274
*.sga_target=0
*.shared_pool_size=838860800
*.shared_servers=5
*.smtp_out_server='172.19.0.70:80'
*.streams_pool_size=33554432
*.transactions=2502
*.undo_tablespace='UNDOTBS1'


###################################################################################################################################

######################################################
Iniciando o procedimento de restore e recover do banco
######################################################

rman target / 

startup nomount pfile=/u01/app/oracle/product/11.2.0/db_1/dbs/initDBPTN.ora

## Atenção o arquivo de control file deve ser o ultimo que estiver disponível ##

restore controlfile from '/backup/rman/DBPAG/rman_DBPAG_.../snapcf_DBPAG.f';

ALTER DATABASE MOUNT;

run {
crosscheck backup;
delete noprompt expired backup; 
crosscheck archivelog all;
delete noprompt expired archivelog all;
}

list backup;

catalog start with '/backup/rman/DBPAG/rman_DBPAG_.../';

list backup of database;

list backup of archivelog all;

#################################################################################################################################################
Caso não consiga recuperar a tablespace system, verificar a incarnação do banco de dados e retorna-la para a mesma de produção, nosso caso a "1"
#################################################################################################################################################

list incarnation;

reset database to incarnation 1;

##########################################################
Mostra informações dos arquivos necessários para o restore
##########################################################

restore database preview;


######################################################################
Renomeia os datafiles, executa o restore e o recover do banco de dados
######################################################################

select 'SET NEWNAME FOR DATAFILE ' || file_id || ' TO ''/u02/app/oracle/oradata/DBPAG/' || substr(file_name,23,20) || ''';'
from dba_data_files
where file_name like '+DATA%'
order by file_id;

SET NEWNAME FOR DATAFILE 1 TO '/u02/app/oracle/oradata/DBPAG/system.281.750670831';
SET NEWNAME FOR DATAFILE 2 TO '/u02/app/oracle/oradata/DBPAG/sysaux.282.750670843';
SET NEWNAME FOR DATAFILE 3 TO '/u02/app/oracle/oradata/DBPAG/undotbs1.283.7506708';
SET NEWNAME FOR DATAFILE 4 TO '/u02/app/oracle/oradata/DBPAG/users.285.750670869';
SET NEWNAME FOR DATAFILE 5 TO '/u02/app/oracle/oradata/DBPAG/icaro_dat01.dbf';
SET NEWNAME FOR DATAFILE 7 TO '/u02/app/oracle/oradata/DBPAG/monitor_dat1.dbf';
SET NEWNAME FOR DATAFILE 8 TO '/u02/app/oracle/oradata/DBPAG/emarcas_dat101.dbf';
SET NEWNAME FOR DATAFILE 11 TO '/u02/app/oracle/oradata/DBPAG/econtrato_dat1.ora';
SET NEWNAME FOR DATAFILE 13 TO '/u02/app/oracle/oradata/DBPAG/eform_dat1.ora';


select 'SET NEWNAME FOR DATAFILE ' || file_id || ' TO ''/u02/app/oracle/oradata/DBPAG/' || substr(file_name,24,20) || ''';'
from dba_data_files
where file_name like '+INDEX%'
order by file_id;

SET NEWNAME FOR DATAFILE 6 TO '/u02/app/oracle/oradata/DBPAG/icaro_ind101.dbf';
SET NEWNAME FOR DATAFILE 9 TO '/u02/app/oracle/oradata/DBPAG/emarcas_ind101.dbf';
SET NEWNAME FOR DATAFILE 10 TO '/u02/app/oracle/oradata/DBPAG/emarcas_lob101.dbf';
SET NEWNAME FOR DATAFILE 12 TO '/u02/app/oracle/oradata/DBPAG/econtrato_ind1.ora';
SET NEWNAME FOR DATAFILE 14 TO '/u02/app/oracle/oradata/DBPAG/eform_ind1.ora';


select 'SET NEWNAME FOR TEMPFILE ' || file_id || ' TO ''/u02/app/oracle/oradata/DBPAG/' || substr(file_name,22,20) || ''';'
from dba_temp_files
order by file_id;
SET NEWNAME FOR TEMPFILE 2 TO '/u02/app/oracle/oradata/DBPAG/temp2.ora';


run
{
allocate channel c1 device type disk;
allocate channel c12 device type disk;
allocate channel c3 device type disk;
SET NEWNAME FOR DATAFILE 1 TO '/u02/app/oracle/oradata/DBPAG/system.281.750670831';
SET NEWNAME FOR DATAFILE 2 TO '/u02/app/oracle/oradata/DBPAG/sysaux.282.750670843';
SET NEWNAME FOR DATAFILE 3 TO '/u02/app/oracle/oradata/DBPAG/undotbs1.283.7506708';
SET NEWNAME FOR DATAFILE 4 TO '/u02/app/oracle/oradata/DBPAG/users.285.750670869';
SET NEWNAME FOR DATAFILE 5 TO '/u02/app/oracle/oradata/DBPAG/icaro_dat01.dbf';
SET NEWNAME FOR DATAFILE 7 TO '/u02/app/oracle/oradata/DBPAG/monitor_dat1.dbf';
SET NEWNAME FOR DATAFILE 8 TO '/u02/app/oracle/oradata/DBPAG/emarcas_dat101.dbf';
SET NEWNAME FOR DATAFILE 11 TO '/u02/app/oracle/oradata/DBPAG/econtrato_dat1.ora';
SET NEWNAME FOR DATAFILE 13 TO '/u02/app/oracle/oradata/DBPAG/eform_dat1.ora';
SET NEWNAME FOR DATAFILE 6 TO '/u02/app/oracle/oradata/DBPAG/icaro_ind101.dbf';
SET NEWNAME FOR DATAFILE 9 TO '/u02/app/oracle/oradata/DBPAG/emarcas_ind101.dbf';
SET NEWNAME FOR DATAFILE 10 TO '/u02/app/oracle/oradata/DBPAG/emarcas_lob101.dbf';
SET NEWNAME FOR DATAFILE 12 TO '/u02/app/oracle/oradata/DBPAG/econtrato_ind1.ora';
SET NEWNAME FOR DATAFILE 14 TO '/u02/app/oracle/oradata/DBPAG/eform_ind1.ora';
SET NEWNAME FOR TEMPFILE 2 TO '/u02/app/oracle/oradata/DBPAG/temp2.ora';
SQL "alter database rename file ''+DATA1/dbpag/onlinelog/group_1.257.749735503'' to ''/u02/app/oracle/DBPAG/onlinelog1/redo1A.log''";
SQL "alter database rename file ''+FRA/dbpag/onlinelog/group_1.257.749735505'' to ''/u02/app/oracle/DBPAG/onlinelog2/redo1B.log''";
SQL "alter database rename file ''+DATA1/dbpag/onlinelog/group_2.258.749735505'' to ''/u02/app/oracle/DBPAG/onlinelog1/redo2A.log''";
SQL "alter database rename file ''+FRA/dbpag/onlinelog/group_2.258.749735505'' to ''/u02/app/oracle/DBPAG/onlinelog2/redo2B.log''";
SQL "alter database rename file ''+DATA1/dbpag/onlinelog/group_3.259.749735505'' to ''/u02/app/oracle/DBPAG/onlinelog1/redo3A.log''";
SQL "alter database rename file ''+FRA/dbpag/onlinelog/group_3.259.749735507'' to ''/u02/app/oracle/DBPAG/onlinelog2/redo3B.log''";
--set until scn 204448149; ### ATENÇÃO - Caso não consiga obter todos os archives de produção, configurar o valor do scn para o ultimo valor adquirido através do comando "list backup of archivelog all;"
RESTORE DATABASE;
SWITCH DATAFILE ALL;
}

##########################################################
Mostra informações dos arquivos necessários para o recover
##########################################################

recover database preview;

run{
--set until scn 204448149; ### ATENÇÃO - Caso não consiga obter todos os archives de produção, configurar o valor do scn para o ultimo valor adquirido através do comando "list backup of archivelog all;"
RECOVER DATABASE;
}

#################################################
Abrir o banco resetando os logs, caso não seja uma recuperação completa,  e criar o spfile
#################################################

alter database open resetlogs; ou alter database open;

create spfile from pfile;

SHUTDOWN IMMEDIATE;

####################################
Recriar o catalogo do banco de dados
Obs: usando o sqlplus
####################################

STARTUP UPGRADE

@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/catupgrd.sql

SHUTDOWN IMMEDIATE

STARTUP

#############################################################################
Verificar se existem objetos invalidos e os registros na tabela dba_registry
#############################################################################

select comp_id, comp_name, status 
from dba_registry;

select count(*) 
  from dba_objects
 where status = 'INVALID';

####################################################################
Caso exista, recompilar os objetos inválidos e validar os registros
####################################################################

@/u01/oracle/product/11.2.0/rdbms/admin/utlrp.sql

select count(*) 
  from dba_objects
 where status = 'INVALID';

###############################################
FIM - Executar um backup full do banco de dados
###############################################
