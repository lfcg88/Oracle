begin
  DBMS_UTILITY.ANALYZE_SCHEMA (
   schema => 'SISGEM',
   method => 'ESTIMATE',
--   estimate_rows    NUMBER   DEFAULT NULL, 
   estimate_percent => 30,
   method_opt  => 'FOR ALL INDEXED COLUMNS SIZE 200');

END;