#!/usr/bin/ksh

#########################################################
##------------------------------------------------     ##
## Arquivo:		replica_tabs_bdup.sh	              ##
##------------------------------------------------     ##
## Fun��o:		Executa Backup Offline das        ##
##          		tablespace da inst�ncia oracle    ##
##                   de desenvolvimento "orcl"         ##
##                   do servidor Linux Rhel4 arsenio   ##
##                   copiando os arquivos *.dbf       	##
##                   para o file system abaixo       	##
##                   /pub/bkp_oracle/backup_online    	##
## Ambiente: 		LINUX			       	##
##------------------------------------------------     ##
##						       	##
## Criado por:	Leonel do Bomfim Filho            ##
## Data:  		17/03/2008		      	       ##
## Empresa: 		Bdep 					##
## Ambiente Oracle 9.2.0.8 Desenvolvimento	       ##
##						             	##
#########################################################

## -----------------------------------------------------------------------
## COPIA DE SEGURAN�A DAS TABLESPACES DA INST�NCIA ORCL (DESENVOLVIMENTO)


DATAS=`date +%d_%m_%Y`

### Verifica se a conex�o com o servidor de Banco de dados da ANP esta ok

  echo "Execu��o do Backuo Offline (DESENV BDEP-ANP ok !) Data_$DATAS " >>/pub/bkp_oracle/replica_view_mat/exec_replicacao_view_mat_$DATAS.log
  ### Executa as etapas para backup com seguran�a das tablespace
  sh -x /pub/bkp_oracle/script/bkp_ol.sh 1>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log1 2>/pub/bkp_oracle/backup_online/begin_backup_orcl_desenv_$DATAS.log2
  
## -----------------------------------------------------------------------



