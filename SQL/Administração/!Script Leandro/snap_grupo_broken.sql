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


select a.owner || '.' || a.name "Nome do Snapshot",
      a.rowner || '.' || a.rname "Nome do Grupo",
      a.broken "Broken",
      b.last_refresh  "Ult. Execução",
      a.next_date "Prox. Execucao",
      a.interval "Intervalo",
      a.job      "Num. Job",
      round(c.total_time/60,0) "Tempo Min."
 from dba_refresh_children  a
    , dba_snapshots         b
    , dba_jobs              c
where a.owner  =  b.owner
  And a.name   = b.name
  And a.job    =c.job
  And (b.last_refresh < sysdate-1 And b.last_refresh > sysdate-10)
order by "Nome do Grupo";