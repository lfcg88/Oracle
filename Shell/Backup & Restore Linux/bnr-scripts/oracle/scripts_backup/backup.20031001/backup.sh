cd $ORACLE_HOME/bin
./rman cmdfile=/oracle/scripts_backup/backup.rman log=/oracle/scripts_backup/backup.log
#./exp rman/rman@metdb01 owner=rman file=/oracle/backup/semanal/export_catalogo.dmp log=/oracle/scripts_backup/export_catalogo.log consistent=yes
