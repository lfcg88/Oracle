begin
  DBMS_STATS.GATHER_SCHEMA_STATS (
   ownname => 'WANDBNOVO',
   estimate_percent => 25,
   block_sample => true,
   method_opt    =>   'FOR ALL INDEXED COLUMNS SIZE 200',
--   degree           NUMBER   DEFAULT NULL,
   granularity    => 'DEFAULT', 
   cascade     => TRUE,
--   stattab          VARCHAR2 DEFAULT NULL, 
--   statid           VARCHAR2 DEFAULT NULL,
   options   => 'GATHER'  
--   objlist     OUT  ObjectTab,
--   statown          VARCHAR2 DEFAULT NULL
);
END;