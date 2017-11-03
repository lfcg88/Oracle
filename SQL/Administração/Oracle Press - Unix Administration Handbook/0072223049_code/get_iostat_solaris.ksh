#!/bin/ksh

while true
do
   iostat -x  300 1|\
      sed 1,2d|\
      awk  '{ printf("%s %s %s\n", $1, $4, $5) }' |\
   while read HDISK VMSTAT_IO_R VMSTAT_IO_W
   do

      echo $HDISK
      echo $VMSTAT_IO_R
      echo $VMSTAT_IO_W

      sqlplus -s / <<!
      insert into 
         perfstat.stats\$iostat
      values 
         (SYSDATE, 300, '$HDISK', $VMSTAT_IO_R,$VMSTAT_IO_W); 
      exit
!

   done
   sleep 300

done
