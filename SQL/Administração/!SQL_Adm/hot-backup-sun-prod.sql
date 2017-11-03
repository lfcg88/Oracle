-- By Gerson
-- Revisão 2008-10-24 (Anderson - voltou a copiar os arquivos de discos locais para o NAS) 

-- set charwidth 2000;
-- select 'alter tablespace '||tablespace_name||' begin backup;'||chr(13)||chr(10)||'host ocopy '||file_name||' '||'r:\hotbackup\datafile'||chr(13)||chr(10)||'alter tablespace '||tablespace_name||' end backup;' from dba_data_files;

spool /opt/oracle/executa_hotbackup.log;

connect / as sysdba;

-- Backup dos Data Files de cada Tablespace

-- set charwidth 2000;
--  select 'alter tablespace '||tablespace_name||' begin backup;'||chr(13)||chr(10)||
--  'host cp '||file_name||' /nas1/oracle_backup/datafile/'||file_name||chr(13)||chr(10)||
--  'alter tablespace '||tablespace_name||' end backup;'
--  'host rcp -rp '||file_name||' s5700bd07:'||file_name||chr(13)||chr(10)||
--  'host rcp -rp '||file_name||' s5700bd07:'||file_name||chr(13)||chr(10)||
--  from dba_data_files order by tablespace_name;

--------------------------------------------------------------------------------------------
alter tablespace IDOC_ATTRIBUTE begin backup;
host cp /oradata1/datafile/idoc_attribute01.dbs /oradata2/datafile/idoc_attribute01.dbs
host cp /oradata1/datafile/idoc_attribute02.dbs /oradata2/datafile/idoc_attribute02.dbs
host cp /oradata1/datafile/idoc_attribute03.dbs /oradata2/datafile/idoc_attribute03.dbs
host cp /oradata1/datafile/idoc_attribute04.dbs /oradata2/datafile/idoc_attribute04.dbs
alter tablespace IDOC_ATTRIBUTE end backup; 

alter tablespace IDOC_ATTRIBUTE_IDX begin backup;
host cp /oradata1/datafile/idoc_attribute_idx01.dbs /oradata2/datafile/idoc_attribute_idx01.dbs
host cp /oradata1/datafile/idoc_attribute_idx02.dbs /oradata2/datafile/idoc_attribute_idx02.dbs
alter tablespace IDOC_ATTRIBUTE_IDX end backup; 

alter tablespace IDOC_CBR begin backup;
host cp /oradata1/datafile/idoc_cbr01.dbs /oradata2/datafile/idoc_cbr01.dbs
host cp /oradata1/datafile/idoc_cbr02.dbs /oradata2/datafile/idoc_cbr02.dbs
alter tablespace IDOC_CBR end backup; 

alter tablespace IDOC_CBR_IDX begin backup;
host cp /oradata1/datafile/idoc_cbr_idx01.dbs /oradata2/datafile/idoc_cbr_idx01.dbs
host cp /oradata1/datafile/idoc_cbr_idx02.dbs /oradata2/datafile/idoc_cbr_idx02.dbs
host cp /oradata1/datafile/idoc_cbr_idx03.dbs /oradata2/datafile/idoc_cbr_idx03.dbs
host cp /oradata1/datafile/idoc_cbr_idx04.dbs /oradata2/datafile/idoc_cbr_idx04.dbs
alter tablespace IDOC_CBR_IDX end backup;

alter tablespace IDOC_DOCUMENT begin backup;
host cp /oradata1/datafile/idoc_document01.dbs /oradata2/datafile/idoc_document01.dbs
alter tablespace IDOC_DOCUMENT end backup; 

alter tablespace IDOC_DOCUMENT_IDX begin backup;
host cp /oradata1/datafile/idoc_document_idx01.dbs /oradata2/datafile/idoc_document_idx01.dbs
alter tablespace IDOC_DOCUMENT_IDX end backup; 

alter tablespace IDOC_FILE begin backup;
host cp /oradata1/datafile/idoc_file01.dbs /oradata2/datafile/idoc_file01.dbs
alter tablespace IDOC_FILE end backup; 

alter tablespace IDOC_FILE_IDX begin backup;
host cp /oradata1/datafile/idoc_file_idx01.dbs /oradata2/datafile/idoc_file_idx01.dbs
host cp /oradata1/datafile/idoc_file_idx02.dbs /oradata2/datafile/idoc_file_idx02.dbs
alter tablespace IDOC_FILE_IDX end backup; 

alter tablespace IDOC_FOLDER begin backup;
host cp /oradata1/datafile/idoc_folder01.dbs /oradata2/datafile/idoc_folder01.dbs
alter tablespace IDOC_FOLDER end backup; 

alter tablespace IDOC_FOLDER_IDX begin backup;
host cp /oradata1/datafile/idoc_folder_idx01.dbs /oradata2/datafile/idoc_folder_idx01.dbs
host cp /oradata1/datafile/idoc_folder_idx02.dbs /oradata2/datafile/idoc_folder_idx02.dbs
alter tablespace IDOC_FOLDER_IDX end backup; 

alter tablespace IDOC_HISTORY begin backup;
host cp /oradata1/datafile/idoc_history01.dbs /oradata2/datafile/idoc_history01.dbs
host cp /oradata1/datafile/idoc_history02.dbs /oradata2/datafile/idoc_history02.dbs
host cp /oradata1/datafile/idoc_history03.dbs /oradata2/datafile/idoc_history03.dbs
alter tablespace IDOC_HISTORY end backup; 

alter tablespace IDOC_HISTORY_IDX begin backup;
host cp /oradata1/datafile/idoc_history_idx01.dbs /oradata2/datafile/idoc_history_idx01.dbs
host cp /oradata1/datafile/idoc_history_idx02.dbs /oradata2/datafile/idoc_history_idx02.dbs
host cp /oradata1/datafile/idoc_history_idx03.dbs /oradata2/datafile/idoc_history_idx03.dbs
alter tablespace IDOC_HISTORY_IDX end backup; 

alter tablespace IDOC_WORKFLOW begin backup;
host cp /oradata1/datafile/idoc_workflow01.dbs /oradata2/datafile/idoc_workflow01.dbs
host cp /oradata1/datafile/idoc_workflow02.dbs /oradata2/datafile/idoc_workflow02.dbs
host cp /oradata1/datafile/idoc_workflow03.dbs /oradata2/datafile/idoc_workflow03.dbs
host cp /oradata1/datafile/idoc_workflow04.dbs /oradata2/datafile/idoc_workflow04.dbs
host cp /oradata1/datafile/idoc_workflow05.dbs /oradata2/datafile/idoc_workflow05.dbs
host cp /oradata1/datafile/idoc_workflow06.dbs /oradata2/datafile/idoc_workflow06.dbs
host cp /oradata1/datafile/idoc_workflow07.dbs /oradata2/datafile/idoc_workflow07.dbs
host cp /oradata1/datafile/idoc_workflow08.dbs /oradata2/datafile/idoc_workflow08.dbs
alter tablespace IDOC_WORKFLOW end backup; 

alter tablespace IDOC_WORKFLOW_IDX begin backup;
host cp /oradata1/datafile/idoc_workflow_idx01.dbs /oradata2/datafile/idoc_workflow_idx01.dbs
host cp /oradata1/datafile/idoc_workflow_idx02.dbs /oradata2/datafile/idoc_workflow_idx02.dbs
host cp /oradata1/datafile/idoc_workflow_idx03.dbs /oradata2/datafile/idoc_workflow_idx03.dbs
host cp /oradata1/datafile/idoc_workflow_idx04.dbs /oradata2/datafile/idoc_workflow_idx04.dbs
host cp /oradata1/datafile/idoc_workflow_idx05.dbs /oradata2/datafile/idoc_workflow_idx05.dbs
host cp /oradata1/datafile/idoc_workflow_idx06.dbs /oradata2/datafile/idoc_workflow_idx06.dbs
host cp /oradata1/datafile/idoc_workflow_idx07.dbs /oradata2/datafile/idoc_workflow_idx07.dbs
host cp /oradata1/datafile/idoc_workflow_idx08.dbs /oradata2/datafile/idoc_workflow_idx08.dbs
host cp /oradata1/datafile/idoc_workflow_idx09.dbs /oradata2/datafile/idoc_workflow_idx09.dbs
host cp /oradata1/datafile/idoc_workflow_idx10.dbs /oradata2/datafile/idoc_workflow_idx10.dbs
host cp /oradata1/datafile/idoc_workflow_idx11.dbs /oradata2/datafile/idoc_workflow_idx11.dbs
alter tablespace IDOC_WORKFLOW_IDX end backup;

alter tablespace IDOC_SECURITY begin backup;
host cp /oradata1/datafile/idoc_security01.dbs /oradata2/datafile/idoc_security01.dbs
host cp /oradata1/datafile/idoc_security02.dbs /oradata2/datafile/idoc_security02.dbs
host cp /oradata1/datafile/idoc_security03.dbs /oradata2/datafile/idoc_security03.dbs
alter tablespace IDOC_SECURITY end backup; 

alter tablespace IDOC_SECURITY_IDX begin backup;
host cp /oradata1/datafile/idoc_security_idx01.dbs /oradata2/datafile/idoc_security_idx01.dbs
host cp /oradata1/datafile/idoc_security_idx02.dbs /oradata2/datafile/idoc_security_idx02.dbs
host cp /oradata1/datafile/idoc_security_idx03.dbs /oradata2/datafile/idoc_security_idx03.dbs
host cp /oradata1/datafile/idoc_security_idx04.dbs /oradata2/datafile/idoc_security_idx04.dbs
host cp /oradata1/datafile/idoc_security_idx05.dbs /oradata2/datafile/idoc_security_idx05.dbs
host cp /oradata1/datafile/idoc_security_idx06.dbs /oradata2/datafile/idoc_security_idx06.dbs
host cp /oradata1/datafile/idoc_security_idx07.dbs /oradata2/datafile/idoc_security_idx07.dbs
host cp /oradata1/datafile/idoc_security_idx08.dbs /oradata2/datafile/idoc_security_idx08.dbs
host cp /oradata1/datafile/idoc_security_idx09.dbs /oradata2/datafile/idoc_security_idx09.dbs
alter tablespace IDOC_SECURITY_IDX end backup; 


alter tablespace PERFSTAT begin backup;
host cp /oradata1/datafile/perfstat.dbs /oradata2/datafile/perfstat.dbs
alter tablespace PERFSTAT end backup; 

alter tablespace IDOC_SYSTEM begin backup;
host cp /oradata1/datafile/idoc_system01.dbs /oradata2/datafile/idoc_system01.dbs
alter tablespace IDOC_SYSTEM end backup; 

alter tablespace IDOC_SYSTEM_IDX begin backup;
host cp /oradata1/datafile/idoc_system_idx01.dbs /oradata2/datafile/idoc_system_idx01.dbs
alter tablespace IDOC_SYSTEM_IDX end backup; 

alter tablespace IDOC_MESSAGE begin backup;
host cp /oradata1/datafile/idoc_message01.dbs /oradata2/datafile/idoc_message01.dbs
host cp /oradata1/datafile/idoc_message02.dbs /oradata2/datafile/idoc_message02.dbs
host cp /oradata1/datafile/idoc_message03.dbs /oradata2/datafile/idoc_message03.dbs
host cp /oradata1/datafile/idoc_message04.dbs /oradata2/datafile/idoc_message04.dbs
host cp /oradata1/datafile/idoc_message05.dbs /oradata2/datafile/idoc_message05.dbs
host cp /oradata1/datafile/idoc_message06.dbs /oradata2/datafile/idoc_message06.dbs
host cp /oradata1/datafile/idoc_message07.dbs /oradata2/datafile/idoc_message07.dbs
alter tablespace IDOC_MESSAGE end backup; 

alter tablespace IDOC_MESSAGE_IDX begin backup;
host cp /oradata1/datafile/idoc_message_idx01.dbs /oradata2/datafile/idoc_message_idx01.dbs
host cp /oradata1/datafile/idoc_message_idx02.dbs /oradata2/datafile/idoc_message_idx02.dbs
host cp /oradata1/datafile/idoc_message_idx03.dbs /oradata2/datafile/idoc_message_idx03.dbs
host cp /oradata1/datafile/idoc_message_idx04.dbs /oradata2/datafile/idoc_message_idx04.dbs
host cp /oradata1/datafile/idoc_message_idx05.dbs /oradata2/datafile/idoc_message_idx05.dbs
alter tablespace IDOC_MESSAGE_IDX end backup; 

alter tablespace IDOC_HIERARCHY begin backup;
host cp /oradata1/datafile/idoc_hierarchy01.dbs /oradata2/datafile/idoc_hierarchy01.dbs
host cp /oradata1/datafile/idoc_hierarchy02.dbs /oradata2/datafile/idoc_hierarchy02.dbs
host cp /oradata1/datafile/idoc_hierarchy03.dbs /oradata2/datafile/idoc_hierarchy03.dbs
host cp /oradata1/datafile/idoc_hierarchy04.dbs /oradata2/datafile/idoc_hierarchy04.dbs
alter tablespace IDOC_HIERARCHY end backup; 

alter tablespace IDOC_HIERARCHY_IDX begin backup;
host cp /oradata1/datafile/idoc_hierarchy_idx01.dbs /oradata2/datafile/idoc_hierarchy_idx01.dbs
host cp /oradata1/datafile/idoc_hierarchy_idx02.dbs /oradata2/datafile/idoc_hierarchy_idx02.dbs
host cp /oradata1/datafile/idoc_hierarchy_idx03.dbs /oradata2/datafile/idoc_hierarchy_idx03.dbs
host cp /oradata1/datafile/idoc_hierarchy_idx04.dbs /oradata2/datafile/idoc_hierarchy_idx04.dbs
host cp /oradata1/datafile/idoc_hierarchy_idx05.dbs /oradata2/datafile/idoc_hierarchy_idx05.dbs
alter tablespace IDOC_HIERARCHY_IDX end backup; 

alter tablespace IDOC_MEASUREMENT begin backup;
host cp /oradata1/datafile/idoc_measurement01.dbs /oradata2/datafile/idoc_measurement01.dbs
host cp /oradata1/datafile/idoc_measurement02.dbs /oradata2/datafile/idoc_measurement02.dbs
host cp /oradata1/datafile/idoc_measurement03.dbs /oradata2/datafile/idoc_measurement03.dbs
alter tablespace IDOC_MEASUREMENT end backup; 

alter tablespace IDOC_MEASUREMENT_IDX begin backup;
host cp /oradata1/datafile/idoc_measurement_idx01.dbs /oradata2/datafile/idoc_measurement_idx01.dbs
host cp /oradata1/datafile/idoc_measurement_idx02.dbs /oradata2/datafile/idoc_measurement_idx02.dbs
host cp /oradata1/datafile/idoc_measurement_idx03.dbs /oradata2/datafile/idoc_measurement_idx03.dbs
alter tablespace IDOC_MEASUREMENT_IDX end backup; 

alter tablespace SYSTEM begin backup;
host cp /oradata1/datafile/system01.dbs /oradata2/datafile/system01.dbs
alter tablespace SYSTEM end backup; 

alter tablespace UNDOTBS1 begin backup;
host cp /oradata1/datafile/undotbs01.dbs /oradata2/datafile/undotbs01.dbs
alter tablespace UNDOTBS1 end backup; 

alter tablespace IDOC_MAT_VIEW begin backup;
host cp /oradata1/datafile/idoc_mat_view01.dbs /oradata2/datafile/idoc_mat_view01.dbs
alter tablespace IDOC_MAT_VIEW end backup; 

alter tablespace IDOC_MAT_VIEW_IDX begin backup;
host cp /oradata1/datafile/idoc_mat_view_idx01.dbs /oradata2/datafile/idoc_mat_view_idx01.dbs
alter tablespace IDOC_MAT_VIEW_IDX end backup;  
 
-- Backup do Control File
alter database backup controlfile to '/opt/oracle/product/9.2.0/dbs/controlbkp.ctl' REUSE;
alter database backup controlfile to trace;
host cp /opt/oracle/product/9.2.0/dbs/controlbkp.ctl /oradata2/controlfile/control01.ctl
host cp /opt/oracle/product/9.2.0/dbs/controlbkp.ctl /oradata2/controlfile/control02.ctl

-- Backup init.ora
host cp /opt/oracle/product/9.2.0/dbs/initSIGEM.ora /oradata2/initSIGEM.ora

-- Parar Archive Log
alter system switch logfile;

spool off;

