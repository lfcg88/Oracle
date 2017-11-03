spool nomount.log

conn /@miafisnb as sysdba
startup force nomount pfile=c:\oracle\admin\miafisnb\pfile\initmiafisnb.ora
spool off
exit;