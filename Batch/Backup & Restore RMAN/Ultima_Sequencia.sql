select max(l.sequence#)+1 as "Sequencia"
  from rc_backup_redolog l,rc_database_incarnation i 
  where i. dbinc_key = l.dbinc_key and i.current_incarnation = 'YES' and i.name = 'MIAFIS';