#!/bin/bash
#Script de copia das tablespace do banco ora 9i por FTP.
#Autor:Marcio Donato


ftp -vin << EOF
open s5700bd32
echo "conectado ao FTP"
user oracle xxxxxx
bin
prompt

printf "%s\n" "Copiando datafiles..."

get /oradata2/datafile/idoc_security01.dbs /bck/datafile/idoc_security01.dbs
get /oradata2/datafile/idoc_security02.dbs /bck/datafile/idoc_security02.dbs
get /oradata2/datafile/idoc_security03.dbs /bck/datafile/idoc_security03.dbs
get /oradata2/datafile/idoc_workflow01.dbs /bck/datafile/idoc_workflow01.dbs
get /oradata2/datafile/idoc_workflow02.dbs /bck/datafile/idoc_workflow02.dbs
get /oradata2/datafile/idoc_workflow03.dbs /bck/datafile/idoc_workflow03.dbs
get /oradata2/datafile/idoc_workflow04.dbs /bck/datafile/idoc_workflow04.dbs
get /oradata2/datafile/idoc_workflow05.dbs /bck/datafile/idoc_workflow05.dbs
get /oradata2/datafile/idoc_workflow06.dbs /bck/datafile/idoc_workflow06.dbs
get /oradata2/datafile/idoc_workflow07.dbs /bck/datafile/idoc_workflow07.dbs
get /oradata2/datafile/idoc_workflow08.dbs /bck/datafile/idoc_workflow08.dbs
get /oradata2/datafile/idoc_security_idx01.dbs /bck/datafile/idoc_security_idx01.dbs
get /oradata2/datafile/idoc_security_idx02.dbs /bck/datafile/idoc_security_idx02.dbs
get /oradata2/datafile/idoc_security_idx03.dbs /bck/datafile/idoc_security_idx03.dbs
get /oradata2/datafile/idoc_security_idx04.dbs /bck/datafile/idoc_security_idx04.dbs
get /oradata2/datafile/idoc_security_idx05.dbs /bck/datafile/idoc_security_idx05.dbs
get /oradata2/datafile/idoc_security_idx06.dbs /bck/datafile/idoc_security_idx06.dbs
get /oradata2/datafile/idoc_security_idx07.dbs /bck/datafile/idoc_security_idx07.dbs
get /oradata2/datafile/idoc_security_idx08.dbs /bck/datafile/idoc_security_idx08.dbs
get /oradata2/datafile/idoc_security_idx09.dbs /bck/datafile/idoc_security_idx09.dbs
get /oradata2/datafile/idoc_attribute_idx01.dbs /bck/datafile/idoc_attribute_idx01.dbs
get /oradata2/datafile/idoc_attribute_idx02.dbs /bck/datafile/idoc_attribute_idx02.dbs
get /oradata2/datafile/idoc_cbr_idx01.dbs /bck/datafile/idoc_cbr_idx01.dbs
get /oradata2/datafile/idoc_cbr_idx02.dbs /bck/datafile/idoc_cbr_idx02.dbs
get /oradata2/datafile/idoc_cbr_idx03.dbs /bck/datafile/idoc_cbr_idx03.dbs
get /oradata2/datafile/idoc_cbr_idx04.dbs /bck/datafile/idoc_cbr_idx04.dbs
get /oradata2/datafile/idoc_document_idx01.dbs /bck/datafile/idoc_document_idx01.dbs
get /oradata2/datafile/idoc_file_idx01.dbs /bck/datafile/idoc_file_idx01.dbs
get /oradata2/datafile/idoc_file_idx02.dbs /bck/datafile/idoc_file_idx02.dbs
get /oradata2/datafile/idoc_folder_idx01.dbs /bck/datafile/idoc_folder_idx01.dbs
get /oradata2/datafile/idoc_folder_idx02.dbs /bck/datafile/idoc_folder_idx02.dbs
get /oradata2/datafile/idoc_hierarchy_idx01.dbs /bck/datafile/idoc_hierarchy_idx01.dbs
get /oradata2/datafile/idoc_hierarchy_idx02.dbs /bck/datafile/idoc_hierarchy_idx02.dbs
get /oradata2/datafile/idoc_hierarchy_idx03.dbs /bck/datafile/idoc_hierarchy_idx03.dbs
get /oradata2/datafile/idoc_hierarchy_idx04.dbs /bck/datafile/idoc_hierarchy_idx04.dbs
get /oradata2/datafile/idoc_hierarchy_idx05.dbs /bck/datafile/idoc_hierarchy_idx05.dbs
get /oradata2/datafile/idoc_history_idx01.dbs /bck/datafile/idoc_history_idx01.dbs
get /oradata2/datafile/idoc_history_idx02.dbs /bck/datafile/idoc_history_idx02.dbs
get /oradata2/datafile/idoc_history_idx03.dbs /bck/datafile/idoc_history_idx03.dbs
get /oradata2/datafile/idoc_mat_view_idx01.dbs /bck/datafile/idoc_mat_view_idx01.dbs
get /oradata2/datafile/idoc_measurement_idx01.dbs /bck/datafile/idoc_measurement_idx01.dbs
get /oradata2/datafile/idoc_measurement_idx02.dbs /bck/datafile/idoc_measurement_idx02.dbs
get /oradata2/datafile/idoc_measurement_idx03.dbs /bck/datafile/idoc_measurement_idx03.dbs
get /oradata2/datafile/idoc_system_idx01.dbs /bck/datafile/idoc_system_idx01.dbs
get /oradata2/datafile/idoc_message01.dbs /bck/datafile/idoc_message01.dbs
get /oradata2/datafile/idoc_message02.dbs /bck/datafile/idoc_message02.dbs
get /oradata2/datafile/idoc_message03.dbs /bck/datafile/idoc_message03.dbs
get /oradata2/datafile/idoc_message04.dbs /bck/datafile/idoc_message04.dbs
get /oradata2/datafile/idoc_message05.dbs /bck/datafile/idoc_message05.dbs
get /oradata2/datafile/idoc_message06.dbs /bck/datafile/idoc_message06.dbs
get /oradata2/datafile/idoc_message07.dbs /bck/datafile/idoc_message07.dbs
get /oradata2/datafile/idoc_message_idx01.dbs /bck/datafile/idoc_message_idx01.dbs
get /oradata2/datafile/idoc_message_idx02.dbs /bck/datafile/idoc_message_idx02.dbs
get /oradata2/datafile/idoc_message_idx03.dbs /bck/datafile/idoc_message_idx03.dbs
get /oradata2/datafile/idoc_message_idx04.dbs /bck/datafile/idoc_message_idx04.dbs
get /oradata2/datafile/idoc_message_idx05.dbs /bck/datafile/idoc_message_idx05.dbs
get /oradata2/datafile/idoc_workflow_idx01.dbs /bck/datafile/idoc_workflow_idx01.dbs
get /oradata2/datafile/idoc_workflow_idx02.dbs /bck/datafile/idoc_workflow_idx02.dbs
get /oradata2/datafile/idoc_workflow_idx03.dbs /bck/datafile/idoc_workflow_idx03.dbs
get /oradata2/datafile/idoc_workflow_idx04.dbs /bck/datafile/idoc_workflow_idx04.dbs
get /oradata2/datafile/idoc_workflow_idx05.dbs /bck/datafile/idoc_workflow_idx05.dbs
get /oradata2/datafile/idoc_workflow_idx06.dbs /bck/datafile/idoc_workflow_idx06.dbs
get /oradata2/datafile/idoc_workflow_idx07.dbs /bck/datafile/idoc_workflow_idx07.dbs
get /oradata2/datafile/idoc_workflow_idx08.dbs /bck/datafile/idoc_workflow_idx08.dbs
get /oradata2/datafile/idoc_workflow_idx09.dbs /bck/datafile/idoc_workflow_idx09.dbs
get /oradata2/datafile/idoc_workflow_idx10.dbs /bck/datafile/idoc_workflow_idx10.dbs
get /oradata2/datafile/idoc_workflow_idx11.dbs /bck/datafile/idoc_workflow_idx11.dbs
get /oradata2/datafile/idoc_attribute01.dbs /bck/datafile/idoc_attribute01.dbs
get /oradata2/datafile/idoc_attribute02.dbs /bck/datafile/idoc_attribute02.dbs
get /oradata2/datafile/idoc_attribute03.dbs /bck/datafile/idoc_attribute03.dbs
get /oradata2/datafile/idoc_attribute04.dbs /bck/datafile/idoc_attribute04.dbs
get /oradata2/datafile/idoc_cbr01.dbs /bck/datafile/idoc_cbr01.dbs
get /oradata2/datafile/idoc_cbr02.dbs /bck/datafile/idoc_cbr02.dbs
get /oradata2/datafile/idoc_document01.dbs /bck/datafile/idoc_document01.dbs
get /oradata2/datafile/idoc_file01.dbs /bck/datafile/idoc_file01.dbs
get /oradata2/datafile/idoc_folder01.dbs /bck/datafile/idoc_folder01.dbs
get /oradata2/datafile/idoc_hierarchy01.dbs /bck/datafile/idoc_hierarchy01.dbs
get /oradata2/datafile/idoc_hierarchy02.dbs /bck/datafile/idoc_hierarchy02.dbs
get /oradata2/datafile/idoc_hierarchy03.dbs /bck/datafile/idoc_hierarchy03.dbs
get /oradata2/datafile/idoc_hierarchy04.dbs /bck/datafile/idoc_hierarchy04.dbs
get /oradata2/datafile/idoc_history01.dbs /bck/datafile/idoc_history01.dbs
get /oradata2/datafile/idoc_history02.dbs /bck/datafile/idoc_history02.dbs
get /oradata2/datafile/idoc_history03.dbs /bck/datafile/idoc_history03.dbs
get /oradata2/datafile/idoc_mat_view01.dbs /bck/datafile/idoc_mat_view01.dbs
get /oradata2/datafile/idoc_measurement01.dbs /bck/datafile/idoc_measurement01.dbs
get /oradata2/datafile/idoc_measurement02.dbs /bck/datafile/idoc_measurement02.dbs
get /oradata2/datafile/idoc_measurement03.dbs /bck/datafile/idoc_measurement03.dbs
get /oradata2/datafile/idoc_system01.dbs /bck/datafile/idoc_system01.dbs
get /oradata2/datafile/system01.dbs /bck/datafile/system01.dbs
get /oradata2/datafile/undotbs01.dbs /bck/datafile/undotbs01.dbs


printf "%s\n" "Copiando controlfiles..."

get /oradata2/controlfile/control01.ctl /bck/controlfile/control01.ctl
get /oradata2/controlfile/control02.ctl /bck/controlfile/control02.ctl

by

EOF

echo "Transferencia de arquivo terminada"

