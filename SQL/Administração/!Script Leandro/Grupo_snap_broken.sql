Prompt ###################################################
Prompt #                                                 #
Prompt #      Identifica refresh Groups em Broken        #
Prompt #                                                 #
Prompt ###################################################


COLUMN "Nome do Snapshot"   FORMAT a40
COLUMN "Nome do Grupo"      FORMAT a40
COLUMN "Broken"             FORMAT a6
COLUMN "Intervalo"          FORMAT a40
set pages 999 trims on 



select owner || '.' || name "Nome do Snapshot",
       rowner || '.' || rname "Nome do Grupo",
       broken "Broken",
       next_date "Prox. Execucao",
       interval "Intervalo"
  from dba_refresh_children
 where broken <> 'N';
