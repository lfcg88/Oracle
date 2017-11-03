######################################
Servidor - Cronos / Instancia - DBPTN
######################################

################
Script de backup
################

/backup/rman/DBPTN/scripts/backup_dbptn.sh

###################
Diretório de backup
###################

/backup/rman/DBPTN

#################################################
Servidor - srv-oracle-desenv / Instancia - DBPTN
#################################################

#####################
Váriaveis de ambiente
#####################

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1/
export ORACLE_SID=DBPTN
export PATH=/u01/app/oracle/product/11.2.0/db_1/bin:/etc:/usr/local/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/oracle/bin


###################
Diretório de backup
###################

/backup/rman/DBPTN

########################
Diretório dos datafiles
########################

/u02/oracle/oradata/DBPTN/datafile/

########################
Diretório onlinelog
########################
/u02/app/oracle/DBPTN/onlinelog1/
/u02/app/oracle/DBPTN/onlinelog2/

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
################

DBPTN.__db_cache_size=1275068416
DBPTN.__java_pool_size=16777216
DBPTN.__large_pool_size=33554432
DBPTN.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
DBPTN.__pga_aggregate_target=1879048192
DBPTN.__sga_target=3489660928
DBPTN.__shared_io_pool_size=33554432
DBPTN.__shared_pool_size=2063597568
DBPTN.__streams_pool_size=16777216
*.audit_file_dest='/u01/app/oracle/admin/DBPTN/adump'
*.audit_trail='db'
*.compatible='11.2.0.0.0'
*.control_files='/u02/app/oracle/DBPTN/onlinelog1/controlfile1.ctl','/u02/app/oracle/DBPTN/onlinelog2/controlfile2.ctl'
*.db_block_size=8192
*.db_domain='INPI.GOV.BR'
*.db_name='DBPTN'
*.db_recovery_file_dest='/u02/app/oracle/flash_recovery/'
*.db_recovery_file_dest_size=53687091200
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(protocol=TCP)(disp=3)'
*.job_queue_processes=1000
*.LOG_ARCHIVE_DEST_1='location=/u02/app/oracle/flash_recovery/DBPTN MANDATORY'
*.LOG_ARCHIVE_FORMAT='log_DBPTN_%t_%s_%r.arc'
*.max_dispatchers=5
*.max_shared_servers=10
*.memory_max_target=6442450944
*.memory_target=5368709120
*.open_cursors=300
*.processes=1500
*.remote_login_passwordfile='EXCLUSIVE'
*.sessions=2274
*.shared_servers=5
*.smtp_out_server='mail.inpi.gov.br:80'
*.statistics_level='TYPICAL'
*.timed_os_statistics=60
*.transactions=2502
*.undo_tablespace='UNDOTBS1'

###################################################################################################################################

######################################################
Iniciando o procedimento de restore e recover do banco
######################################################

rman target / 

startup nomount pfile=/u01/app/oracle/product/11.2.0/db_1/dbs/initDBPTN.ora

## Atenção o arquivo de control file deve ser o ultimo que estiver disponível ##

restore controlfile from '/backup/rman/DBPTN/rman_DBPTN_.../snapcf_DBPTN.f';

ALTER DATABASE MOUNT;

run {
crosscheck backup;
delete noprompt expired backup; 
crosscheck archivelog all;
delete noprompt expired archivelog all;
}

list backup;

catalog start with '/backup/rman/DBPTN/rman_DBPTN_.../';

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

select 'SET NEWNAME FOR DATAFILE ' || file_id || ' TO ''/u02/app/oracle/oradata/DBPTN/' || substr(file_name,23,20) || ''';'
from dba_data_files
where file_name like '+DATA%'
order by file_id;

SET NEWNAME FOR DATAFILE 1 TO '/u02/app/oracle/oradata/DBPTN/system.260.749735509';
SET NEWNAME FOR DATAFILE 2 TO '/u02/app/oracle/oradata/DBPTN/sysaux.261.749735527';
SET NEWNAME FOR DATAFILE 4 TO '/u02/app/oracle/oradata/DBPTN/users.264.749735553';
SET NEWNAME FOR DATAFILE 5 TO '/u02/app/oracle/oradata/DBPTN/dbptn_dat101.dbf';
SET NEWNAME FOR DATAFILE 8 TO '/u02/app/oracle/oradata/DBPTN/monitor_dat1.dbf';
SET NEWNAME FOR DATAFILE 9 TO '/u02/app/oracle/oradata/DBPTN/grifo_dat_01.dbf';
SET NEWNAME FOR DATAFILE 11 TO '/u02/app/oracle/oradata/DBPTN/siginpi_tab_02.dbf';
SET NEWNAME FOR DATAFILE 13 TO '/u02/app/oracle/oradata/DBPTN/siginpi_tab_01.dbf';
SET NEWNAME FOR DATAFILE 15 TO '/u02/app/oracle/oradata/DBPTN/siguser_tab_tmp_01.d';
SET NEWNAME FOR DATAFILE 17 TO '/u02/app/oracle/oradata/DBPTN/linkdata_tab_01.dbf';
SET NEWNAME FOR DATAFILE 19 TO '/u02/app/oracle/oradata/DBPTN/badepi_tab_01.dbf';
SET NEWNAME FOR DATAFILE 21 TO '/u02/app/oracle/oradata/DBPTN/geradoc_data01.dbf';

select 'SET NEWNAME FOR DATAFILE ' || file_id || ' TO ''/u02/app/oracle/oradata/DBPTN/' || substr(file_name,24,20) || ''';'
from dba_data_files
where file_name like '+INDEX%'
order by file_id;

SET NEWNAME FOR DATAFILE 6 TO '/u02/app/oracle/oradata/DBPTN/dbptn_ind101.dbf';
SET NEWNAME FOR DATAFILE 7 TO '/u02/app/oracle/oradata/DBPTN/dbptn_lob101.dbf';
SET NEWNAME FOR DATAFILE 10 TO '/u02/app/oracle/oradata/DBPTN/grifo_ind_01.dbf';
SET NEWNAME FOR DATAFILE 12 TO '/u02/app/oracle/oradata/DBPTN/geradoc_index01.dbf';
SET NEWNAME FOR DATAFILE 14 TO '/u02/app/oracle/oradata/DBPTN/siginpi_ind_01.dbf';
SET NEWNAME FOR DATAFILE 16 TO '/u02/app/oracle/oradata/DBPTN/siguser_ind_tmp_01.d';
SET NEWNAME FOR DATAFILE 18 TO '/u02/app/oracle/oradata/DBPTN/linkdata_ind_01.dbf';
SET NEWNAME FOR DATAFILE 20 TO '/u02/app/oracle/oradata/DBPTN/badepi_ind_01.dbf';

select 'SET NEWNAME FOR DATAFILE ' || file_id || ' TO ''/u02/app/oracle/oradata/DBPTN/' || substr(file_name,22,20) || ''';'
from dba_data_files
where file_name like '+AUX%'
order by file_id;

SET NEWNAME FOR DATAFILE 3 TO '/u02/app/oracle/oradata/DBPTN/undotbs1.258.7501775';

select 'SET NEWNAME FOR TEMPFILE ' || file_id || ' TO ''/u02/app/oracle/oradata/DBPTN/' || substr(file_name,22,20) || ''';'
from dba_temp_files
order by file_id;


run
{
allocate channel c1 device type disk;
allocate channel c12 device type disk;
allocate channel c3 device type disk;
SET NEWNAME FOR DATAFILE 1 TO '/u02/app/oracle/oradata/DBPTN/system.260.749735509';
SET NEWNAME FOR DATAFILE 2 TO '/u02/app/oracle/oradata/DBPTN/sysaux.261.749735527';
SET NEWNAME FOR DATAFILE 4 TO '/u02/app/oracle/oradata/DBPTN/users.264.749735553';
SET NEWNAME FOR DATAFILE 5 TO '/u02/app/oracle/oradata/DBPTN/dbptn_dat101.dbf';
SET NEWNAME FOR DATAFILE 8 TO '/u02/app/oracle/oradata/DBPTN/monitor_dat1.dbf';
SET NEWNAME FOR DATAFILE 9 TO '/u02/app/oracle/oradata/DBPTN/grifo_dat_01.dbf';
SET NEWNAME FOR DATAFILE 11 TO '/u02/app/oracle/oradata/DBPTN/siginpi_tab_02.dbf';
SET NEWNAME FOR DATAFILE 13 TO '/u02/app/oracle/oradata/DBPTN/siginpi_tab_01.dbf';
SET NEWNAME FOR DATAFILE 15 TO '/u02/app/oracle/oradata/DBPTN/siguser_tab_tmp_01.d';
SET NEWNAME FOR DATAFILE 17 TO '/u02/app/oracle/oradata/DBPTN/linkdata_tab_01.dbf';
SET NEWNAME FOR DATAFILE 19 TO '/u02/app/oracle/oradata/DBPTN/badepi_tab_01.dbf';
SET NEWNAME FOR DATAFILE 21 TO '/u02/app/oracle/oradata/DBPTN/geradoc_data01.dbf';
SET NEWNAME FOR DATAFILE 6 TO '/u02/app/oracle/oradata/DBPTN/dbptn_ind101.dbf';
SET NEWNAME FOR DATAFILE 7 TO '/u02/app/oracle/oradata/DBPTN/dbptn_lob101.dbf';
SET NEWNAME FOR DATAFILE 10 TO '/u02/app/oracle/oradata/DBPTN/grifo_ind_01.dbf';
SET NEWNAME FOR DATAFILE 12 TO '/u02/app/oracle/oradata/DBPTN/geradoc_index01.dbf';
SET NEWNAME FOR DATAFILE 14 TO '/u02/app/oracle/oradata/DBPTN/siginpi_ind_01.dbf';
SET NEWNAME FOR DATAFILE 16 TO '/u02/app/oracle/oradata/DBPTN/siguser_ind_tmp_01.d';
SET NEWNAME FOR DATAFILE 18 TO '/u02/app/oracle/oradata/DBPTN/linkdata_ind_01.dbf';
SET NEWNAME FOR DATAFILE 20 TO '/u02/app/oracle/oradata/DBPTN/badepi_ind_01.dbf';
SET NEWNAME FOR DATAFILE 3 TO '/u02/app/oracle/oradata/DBPTN/undotbs1.258.7501775';
SET NEWNAME FOR TEMPFILE 1 TO '/u02/app/oracle/oradata/DBPTN/temp1.dbf';
SET NEWNAME FOR TEMPFILE 2 TO '/u02/app/oracle/oradata/DBPTN/temp_badepi_01.dbf';
SET NEWNAME FOR TEMPFILE 3 TO '/u02/app/oracle/oradata/DBPTN/temp1.ora';
SQL "alter database rename file ''+DATA1/dbptn/onlinelog/group_1.257.749735503'' to ''/u02/app/oracle/DBPTN/onlinelog1/redo1A.log''";
SQL "alter database rename file ''+FRA/dbptn/onlinelog/group_1.257.749735505'' to ''/u02/app/oracle/DBPTN/onlinelog2/redo1B.log''";
SQL "alter database rename file ''+DATA1/dbptn/onlinelog/group_2.258.749735505'' to ''/u02/app/oracle/DBPTN/onlinelog1/redo2A.log''";
SQL "alter database rename file ''+FRA/dbptn/onlinelog/group_2.258.749735505'' to ''/u02/app/oracle/DBPTN/onlinelog2/redo2B.log''";
SQL "alter database rename file ''+DATA1/dbptn/onlinelog/group_3.259.749735505'' to ''/u02/app/oracle/DBPTN/onlinelog1/redo3A.log''";
SQL "alter database rename file ''+FRA/dbptn/onlinelog/group_3.259.749735507'' to ''/u02/app/oracle/DBPTN/onlinelog2/redo3B.log''";
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
