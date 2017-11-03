conn rman/rman@metdb01
spool listaseq.log
select max(sequence#)+1 as "Sequencia" from rc_backup_redolog l,rc_database d where
  l.db_key = d.db_key and d.name = 'GRPLAN';
spool off
exit;
