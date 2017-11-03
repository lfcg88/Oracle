#/bin/sh
echo "
CONNECT TARGET sys/dontknow; 
CONNECT CATALOG rman/rman@rcvcat;

# Novo bloco para realizar o restore do pfile

#coloca inst�ncia em nomount com dummy PFILE que aponta para dummy SPFILE
startup force nomount PFILE=/oracle/product/9.2/dbs/pfile_GRPLAN.ora

# restaura �ltimo spfile com nome padr�o

run
{
  allocate channel ch1 type disk;
  restore spfile to '/oracle/product/9.2/dbs/spfileGRPLAN.ora';
  release channel ch1;
}

startup force nomount;

run
{
SET UNTIL SEQUENCE $1 thread 1;
allocate channel ch1 type DISK;
restore controlfile;
restore database;
alter database mount;
recover database;
# � utilizado SQL para que o rman n�o crie uma nova incarnation no catalogo 
sql 'alter database open resetlogs';
release channel ch1;
}
SQL \"ALTER TABLESPACE TEMP ADD TEMPFILE ''/oracle/oradata/GRPLAN/temp01.dbf'' size 70m REUSE\";
" > restore_database.rman