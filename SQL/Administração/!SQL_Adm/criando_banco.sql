--todos os passos para criar um banco de dados manualmente--

1 --configurar a variavel de ambiente ORACLE_SID com o nome da minha instancia--
export ORACLE_SID=mynewdb

2 --cria-se o arquivo de senhas para essa instancia
--obs: passa o caminho todo de onde vai se localizar o arquivo--
orapwd file=$ORACLE_HOME/dbs/orapwmynewdb.ora password=marcio entries=50

3 --configura a variavel do arquivo de senha como exclusive para que se possa add
--usuarios no arquivo de senha
remote_login_passwordfile=exclusive(default)

4 --entrar no diretorio do oracle dbs para copiar o init.ora
cd /u01/app/oracle/product/10.2.0/db_1/dbs
 
5 --criando o arquivo de parametro de inicialização 
--copia-se o arquivo init.ora para um arquivo init<SID>.ora 
--EX: initmynewdb.ora
cp init.ora initmynewdb.ora

6 --se conectar no sqlplus a instancia que foi criada 
--com a senha criada no arquivo de senhas
sqlplus sys/marcio as sysdba
 
7 --cria o servidor de parametros a partir do arquivo de parametro criado na etapa "5"
cd $ORACLE_HOME/dbs --entra na pasta para criar o arquivo
    create spfile from pfile

8 --reinicia-se o banco	
shutdown immediate
	  
9 -- passo 6 novamente

10 -- abrir a instancia
startup nomount

11 --comando sql para criação do banco
 create database mynewdb
   user sys identified by m1
   user system identified by m2
   logfile group 1 ('/u01/app/oracle/oradata/mynewdb/redo01.log') size 100m,
		   group 2 ('/u01/app/oracle/oradata/mynewdb/redo02.log') size 100m,
           group 3 ('/u01/app/oracle/oradata/mynewdb/redo03.log') size 100m
      maxlogfiles 5
      maxlogmembers 5
      maxinstances 1
	  maxloghistory 1
	  maxdatafiles 50
   character set us7ascii
   national character set al16utf16
   datafile'/u01/app/oracle/oradata/mynewdb/system01.dbf'
      size 325m reuse extent management local
   sysaux datafile'/u01/app/oracle/oradata/mynewdb/sysaux01.dbf' size 325m reuse
   default tablespace tbs_1
      datafile'/u01/app/oracle/oradata/mynewdb/tbs01.dbf' size 325m reuse
   default temporary tablespace temptbs1
      tempfile'/u01/app/oracle/oradata/mynewdb/temptbs01.dbf' size 20m reuse
   undo tablespace undotbs
      datafile'/u01/app/oracle/oradata/mynewdb/undotbs.dbf'
      size 200m autoextend on maxsize unlimited

12 --executar os scripts
/u01/app/oracle/product/10.2.0/db_1/rdbms/admin/catalog.sql
/u01/app/oracle/product/10.2.0/db_1/rdbms/admin/catproc.sql


