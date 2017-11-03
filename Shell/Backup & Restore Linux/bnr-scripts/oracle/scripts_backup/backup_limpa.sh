#!/bin/sh
bkpdir="/oracle/backup/diario/"
 
for i in `ls $bkpdir*.tar.gz $bkpdir*.tar.bz2`; do
        arqdat=`echo $i | tr -s " " | cut -d " " -f 9 | cut -d "-" -f 2 | cut -d "." -f 1 | sort -n | tail -n 3`;
 
        diasem=`date +%w -d "$arqdat"`;
 
        if [[ "$diasem" == "0" || "$diasem" == "6" ]]; then
                maxdat=`date +%Y%m%d -d "-3 week"`;
                if [[ "$arqdat" < "$maxdat" ]]; then
                        rm -f $i;
                fi
        else
                maxdat=`date +%Y%m%d -d "-3 days"`;
                if [[ "$arqdat" < "$maxdat" ]]; then
                        rm -f $i;
                fi
        fi
done;
