conn /@miafis as sysdba

begin
  DBMS_STATS.GATHER_DATABASE_STATS (
--   estimate_percent => null,
--   block_sample => true,
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
/

exit;