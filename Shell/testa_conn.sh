#!/bin/ksh
#########################################################
##------------------------------------------------     ##
## Arquivo:		testa_conn.sh		      		##
##------------------------------------------------     ##
## Fun��o:		Faz o Backup Online do Banco  	##
##                   (BEGIN BACKUP)              	##
## Ambiente: 		LINUX			       	##
##------------------------------------------------     ##
##						       	##
## Criado por:	Leonel do Bomfim Filho            ##
## Data:  		17/03/2008		      	       ##
## Empresa: 		Bdep 					##
## Ambiente Oracle 9.2.0.8 Produ��o		       ##
##						             	##
#########################################################

## -----------------------------------------------------------------------
## Testa Conex�o com servidor de Banco de Dados da Anp


DATAS=`date +%d_%m_%Y`
### Verifica se a conex�o com o servidor de Banco de dados da ANP esta ok"

### if ! ping -c 2 172.16.4.100 ; then
if ! tnsping prod 2 ; then
  echo
  echo "Sem conex�o a base de dados ANP (CONN BDEP-ANP PARADA !) Data_$DATAS "|| tee  /pub/bkp_oracle/replica_view_mat/Canc_replica��o_view_mat_$DATAS.log
  echo
else
  echo
  #echo "Conex�o com sucesso (CONN BDEP-ANP ok !) Data_$DATAS " | tee /pub/bkp_oracle/replica_view_mat/Conexao_sucesso_Bdup_Anp.log
  echo "Conex�o com sucesso (ok !) Data_$DATAS " >>/pub/bkp_oracle/replica_view_mat/exec_replica��o_view_mat_$DATAS.log
  #sh kill_users_replica_bdup.sh 2>/pub/bkp_oracle/replica_view_mat/exec_replica��o_view_mat_$DATAS.log
  #sh kill_users_replica_bdup.sh >>/pub/bkp_oracle/replica_view_mat/exec_replica��o_view_mat_$DATAS.log
  
fi

exit 
## -----------------------------------------------------------------------
#
## -----------------------------------------------------------------------


