cd /oracle/backup/diario
tar -jcvf backup2_diario.tar.bz2 db_GRPLAN_* al_GRPLAN_*
scp backup2_diario.tar.bz2 10.2.0.2:/oracle/backup/diario
