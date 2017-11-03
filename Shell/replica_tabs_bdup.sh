#!/usr/bin/ksh
###!/bin/ksh
#########################################################
##------------------------------------------------     ##
## Arquivo:		replica_tabs_bdup.sh	              ##
##------------------------------------------------     ##
## Fun��o:		Testar connex�o com inst�ncia     ##
##          		oracle prod Bdup/Anp              ##
##                   Executa a replica��o das          ##
##                   View Materializadas p/ Bd Bdep    ##
## Ambiente: 		LINUX			              ##
##------------------------------------------------     ##
##						              ##
## Criado por:	Leonel do Bomfim Filho             ##
## Data:  		17/03/2008		              ##
## Empresa: 		Bdep 			              ##
## Ambiente Oracle 9.2.0.8 Produ��o		       ##
##						              ##
#########################################################

## -----------------------------------------------------------------------
## Testa Conex�o e replica views materializadas


DATAS=`date +%d_%m_%Y`
TESTE=`tnsping prod 2 | tail -n1`
TESTE=`eval echo \${TESTE%${TESTE#??}}`

### Verifica se a conex�o com o servidor de Banco de dados da ANP esta ok

  if [ $TESTE != 'OK' ] ; then
   echo
    echo " Sem conex�o com a BD Oracle de produ��o da ANP (CONN BDEP-ANP PARADA !!) Data_$DATAS " | tee  /pub/bkp_oracle/replica_view_mat/Canc_replicacao_view_mat_$DATAS.log
    echo  
      else
    echo "Conexao com sucesso (CONN BDEP-ANP ok !!) Data_$DATAS" >> /pub/bkp_oracle/replica_view_mat/exec_replicacao_view_mat_$DATAS.log
    echo "Executa a replica��o de tabelas da base de dados oracle de produ��o Bdup/Anp para base de dados oracle do bdep/BDEP"
    sh -x /pub/bkp_oracle/script/kill_users_replica_bdup.sh 1>/pub/bkp_oracle/replica_view_mat/exec_replicacao_view_mat_$DATAS.log1 2>/pub/bkp_oracle/replica_view_mat/exec_replicacao_view_mat_$DATAS.log2

  fi

exit 
## -----------------------------------------------------------------------



