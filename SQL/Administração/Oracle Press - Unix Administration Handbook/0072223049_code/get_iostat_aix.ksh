#!/bin/ksh

while true
do
   iostat 300 1 | awk  '{ printf("%s ,%s ,%s\n", $1, $5, $6) }' |\
   while read    HDISK VMSTAT_IO_R VMSTAT_IO_W
   do
   if (echo $HDISK|grep -cq hdisk );then

      sqlplus -s / <<EOF
      insert into iostat values 
      (SYSDATE, 5, '$HDISK', $VMSTAT_IO_R,$VMSTAT_IO_W); 
      EXIT
      EOF
   fi
   done
done
