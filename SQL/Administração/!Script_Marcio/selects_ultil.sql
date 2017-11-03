--Listar DIRETÓRIOS 
select * 
  from dba_directories;

--Listar TABELAS 
select table_name 
  from dba_tables 
 where owner='POUSADA';

--Listar  TABLESPACES
select tablespace_name 
  from dba_tablespaces;
  
--Listar INDICES 
 select index_name 
   from dba_indexes 
  where owner='POUSADA';
  
--Listar VIEWS
select view_name
  from dba_views
 where owner='POUSADA';

--Listar SINONIMOS
select synonym_name
  from dba_synonyms
 where owner='POUSADA';

--Listar USUARIOS
select username
  from dba_users;

--Listar ROLES
select *
  from dba_role_privs
 where grantee='POUSADA';
 
--Listar PROCEDURES 
select procedure_name 
  from dba_procedures
 where owner='POUSADA';
 
--Listar LOGFILES ONLINE
select member 
  from v$logfile
 where type = 'ONLINE'
 
--Listar LOGFILES OFFLINE
select member 
  from v$logfile
 where type = 'OFFLINE'
 
--Listar DATAFILE
select name
  from dba_data_files;

--Listar CONTROLFILES
select name 
  from v$controlfile;  
  
--Listar ARCHIVES
select name 
  from v$archived_log
 where name is not null 
   and thread# = 1 
   and first_time >= trunc(sysdate) - 7; 

--Listar tamanho, espaço usado, numero de arquivos da area de archive
select * 
  from  v$recovery_file_dest
  
--Listar ESQUEMAS
select name 
  from dba_users;
  
--Listar JOBS 
select *
  from dba_scheduler_jobs

--Listar a versão do ORACLE
select * 
  from v$version;
  
--Listar o tamanho de um ou mais esquemas
select tablespace_name, owner, sum(bytes)/1024/1024 MegaBytes
  from dba_segments
 where owner in ('POUSADA')
 group by tablespace_name, owner;
 
--Lista privilégios de um ou mais usuarios 
select *
  from dba_sys_privs
 where privilege = 'UNLIMITED TABLESPACE'
	   grantee = 'POUSADA';
	   
--Listar quotas de usuarios
select username, tablespace_name,
	   bytes/1024/1024 usado_MB,
	   max_bytes/1024/1024 quota_Mb
  from dba_ts_quotas
 order by username;

 --listar privilégios de um objeto
 select *
  from dba_tab_privs
 where table_name = 'nome_objeto';
