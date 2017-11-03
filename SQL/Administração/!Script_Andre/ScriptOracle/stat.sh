#!/usr/bin/ksh
#---------------------------------------------------------------------------    
#
# Shell.....:  Captura estatisticas de CPU, memoria, I/O e usuarios.
#
# Doc.......:  TS0044RUS?????
#
# Sintaxe...:  /ger/shell/stat.sh (lancado pela crontab do ger)
#
# Opcoes....:  Nao ha
#
# Parametros:  Nao ha
#
# Requisitos:  Diretorio /ger/mes/dia para guardar saida do shell
#              Comandos prtdiag, swap, sar, vmstat e iostat
#
# Atributos.:  dono:       = adm54
#              permissoes  = rwxrwx---
#
# Autor.....:  Rudolfo Schulze
#
# Data......: 28/Julho/2003
# Alteracao.: 
#
#
# Descricao.:
# Script para gerar estatiscticas de CPU, memoria e de I/O. O lancamento eh
# feito pela crontab do usuario ger e a cada rodada, coleta uma linha de 
# estatistica, colocando o horario na primeira coluna.
#
#--------------------------------------------------------------------------

dd=`date +"%d"` 
mmn=`date +"%m"`
aa=`date +"%Y"`

SERV=`hostname`
DIR=/ger
DIR_SCR=/ger/shell
ARQ_OUT_VMSTAT=$DIR/${mmn}/${dd}/${SERV}_vmstat_${dd}${mmn}${aa}
ARQ_OUT_SAR=$DIR/${mmn}/${dd}/${SERV}_sar_${dd}${mmn}${aa}
ARQ_OUT_IOSTAT=$DIR/${mmn}/${dd}/${SERV}_iostat_${dd}${mmn}${aa}
ARQ_OUT_LAVSTAT=$DIR/${mmn}/${dd}/${SERV}_lavstat_${dd}${mmn}${aa}
ARQ_TMP_IOSTAT=$DIR/tmp/iostat.tmp

if [ ! -d $DIR/$mmn/$dd ] ; then
   $DIR_SCR/mndir.sh 
   if [ $? -ne 0 ] ; then
	  exit 1
   fi
fi

if [ ! -d $DIR/tmp ] ; then 
   exit 1
fi

#--------------------------------------------------------------------------

# TOT_MEM=`/usr/platform/sun4u/sbin/prtdiag | nawk '{
TOT_MEM=`/usr/sbin/prtconf | grep Mem | nawk '{
			if ($1 == "Memory" && $2 == "size:") print ($3*1024)}'`
TOT_SWAP=`/usr/sbin/swap -l | nawk 'BEGIN{ total=0 } {
			               if ($0 !~ "swapfile") total=total+$4 }
                                     END{ print total }'`
FREE_SWAP=`/usr/sbin/swap -l | nawk 'BEGIN{ total=0 } {
			if ($0 !~ "swapfile") total=total+$5 }
                                     END{ print total }'`
USED_SWAP=`expr $TOT_SWAP - $FREE_SWAP`

PERC_USED_SWAP=`bc << FIM
scale=0
((100 * $USED_SWAP) / $TOT_SWAP)
FIM`
#--------------------------------------------------------------------------

# Inicializacao de arquivos

if [ ! -f  $ARQ_OUT_VMSTAT ] ; then
   vmstat | head -1 | nawk '{ print "        ",$0 }' > $ARQ_OUT_VMSTAT
   HD_VMSTAT2=`vmstat | head -2 | nawk '{if ( $0 ~ "swap" ) print $0 }'`
   echo "hora:min %swap %memoria $HD_VMSTAT2" > $ARQ_OUT_VMSTAT
fi

if [ ! -f $ARQ_OUT_SAR ] ; then
   sar 1 1 | nawk '{if ($0 ~ "%usr") print "hora:min",$2,$3,$4,$5,"%busy"}' > \
   $ARQ_OUT_SAR
fi

if [ ! -f  $ARQ_OUT_IOSTAT ] ; then
   HD_IOSTAT=`iostat -xn | head -2 | nawk '{ if ( $0 ~ "r/s") print $0 }'`
   echo "hora:min $HD_IOSTAT" > $ARQ_OUT_IOSTAT
fi

if [ ! -f  $ARQ_OUT_LAVSTAT ] ; then
   echo "$SERV dia mes ano hora min   diaup horaup minup la1 la5 la15" > $ARQ_OUT_LAVSTAT
fi

#--------------------------------------------------------------------------

# Captura de estatisticas de memoria   

A=`date +"%H":"%M"`
B=`vmstat 1 2 | tail -1`
FREE_MEM=`echo $B | nawk '{ print $5 }'`
USED_MEM=`expr $TOT_MEM - $FREE_MEM`

PERC_USED_MEM=`bc << FIM
scale=0
((100 * $USED_MEM) / $TOT_MEM)
FIM`

echo "$A $PERC_USED_SWAP $PERC_USED_MEM $B" >> $ARQ_OUT_VMSTAT

#--------------------------------------------------------------------------

# Captura de estatisticas de CPU

C=`date +"%H":"%M"`
D=`sar 1 2 | nawk '{ if ( $0 !~ "SunOS"  &&  $0 !~ "usr"  &&  $0 !~ "Average" ) print $0 }' | sed  '/^[ \t]*$/d' |tail -1| nawk '{ print $2,$3,$4,$5,100-$5 }'`
echo "$C $D" >> $ARQ_OUT_SAR
#--------------------------------------------------------------------------

# Captura de estatisticas de I/O

E=`date +"%H":"%M"`
NB_DEV=`iostat -xn | wc -l`
iostat -xn 1 2 | tail -`echo $NB_DEV` > $ARQ_TMP_IOSTAT
A=`date +"%H":"%M"`
nawk '{ if ( $1 != "extended"  &&  $1 != "r/s" )
		   print "'$E'",$0 }' $ARQ_TMP_IOSTAT >> $ARQ_OUT_IOSTAT

#--------------------------------------------------------------------------

# Captura de estatistica de load average
HH=`date +"%H"`
MM=`date +"%M"`
# exemplo com 10 campos
# 3:01pm  up 3 min(s),  1 user,  load average: 0.09, 0.08, 0.04
# exemplo com 13 campos
# 3:00pm  up 1 day(s), 3 min(s),  2 users,  load average: 0.09, 0.12, 0.13

/usr/bin/uptime | nawk '{ if ( NF == 10 ) 
           print "'$SERV'","'$dd'","'$mmn'","'$aa'","'$HH'","'$MM'"," ","0",$3,$8,$9,$10
        if ( NF == 11 && $0 ~ "min" )
           print  "'$SERV'","'$dd'","'$mmn'","'$aa'","'$HH'","'$MM'"," ","0","0:"$3,$9,$10,$11
        if ( NF == 12 && $0 ~ "day" )
           print "'$SERV'","'$dd'","'$mmn'","'$aa'","'$HH'","'$MM'"," ",$3,$5,$10,$11,$12
        if ( NF == 13 && $0 ~ "min" && $0 ~ "day" )
           print "'$SERV'","'$dd'","'$mmn'","'$aa'","'$HH'","'$MM'"," ",$3,"0:"$5,$11,$12,$13 }'|sed 's/,//g'|sed 's/:/ /g'|sed 's/\./,/g' >> ${ARQ_OUT_LAVSTAT}
#--------------------------------------------------------------------------

if [ -f $ARQ_TMP_IOSTAT ] ; then
   rm $ARQ_TMP_IOSTAT
fi

exit 0

