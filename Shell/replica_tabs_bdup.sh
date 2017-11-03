#!/usr/bin/ksh
###!/bin/ksh
#########################################################
##------------------------------------------------     ##
## Arquivo:		replica_tabs_bdup.sh	              ##
##------------------------------------------------     ##
## Função:		Testar connexão com instância     ##
##          		oracle prod Bdup/Anp              ##
##                   Executa a replicação das          ##
##                   View Materializadas p/ Bd Bdep    ##
## Ambiente: 		LINUX			              ##
##------------------------------------------------     ##
##						              ##
## Criado por:	Leonel do Bomfim Filho             ##
## Data:  		17/03/2008		              ##
## Empresa: 		Bdep 			              ##
## Ambiente Oracle 9.2.0.8 Produção		       ##
##						              ##
#########################################################

## -----------------------------------------------------------------------
## Testa Conexão e replica views materializadas


DATAS=`date +%d_%m_%Y`
TESTE=`tnsping prod 2 | tail -n1`
TESTE=`eval echo \${TESTE%${TESTE#??}}`

### Verifica se a conexão com o servidor de Banco de dados da ANP esta ok

  if [ $TESTE != 'OK' ] ; then
   echo
    echo " Sem conexão com a BD Oracle de produção da ANP (CONN BDEP-ANP PARADA !!) Data_$DATAS " | tee  /pub/bkp_oracle/replica_view_mat/Canc_replicacao_view_mat_$DATAS.log
    echo  
      else
    echo "Conexao com sucesso (CONN BDEP-ANP ok !!) Data_$DATAS" >> /pub/bkp_oracle/replica_view_mat/exec_replicacao_view_mat_$DATAS.log
    echo "Executa a replicação de tabelas da base de dados oracle de produção Bdup/Anp para base de dados oracle do bdep/BDEP"
    sh -x /pub/bkp_oracle/script/kill_users_replica_bdup.sh 1>/pub/bkp_oracle/replica_view_mat/exec_replicacao_view_mat_$DATAS.log1 2>/pub/bkp_oracle/replica_view_mat/exec_replicacao_view_mat_$DATAS.log2

  fi

exit 
## -----------------------------------------------------------------------



