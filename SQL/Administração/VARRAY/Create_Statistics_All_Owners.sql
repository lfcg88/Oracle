declare
  type string is varray (9) of varchar2(30);
  type lista_owner is record
    (
    owner string,
	enabled boolean
	);
	
    
  type string is varray (9) of varchar2(30);
  
  own string;
begin
  own := string ('CRP','CIV','IDT','WFL','MIG','WFL','CRM','BDI','LAT' );
 
  FOR X IN OWN.FIRST .. OWN.LAST LOOP
    DBMS_STATS.GATHER_SCHEMA_STATS (
      ownname => OWN(X),
--    estimate_percent => null,
--    block_sample => true,
      method_opt    =>   'FOR ALL INDEXED COLUMNS SIZE 200',
--    degree           NUMBER   DEFAULT NULL,
      granularity    => 'DEFAULT', 
      cascade     => TRUE,
--    stattab          VARCHAR2 DEFAULT NULL, 
--    statid           VARCHAR2 DEFAULT NULL,
      options   => 'GATHER'  
--    objlist     OUT  ObjectTab,
--    statown          VARCHAR2 DEFAULT NULL
);
    DBMS_OUTPUT.PUT_LINE ('Estatisticas criadas para owner ' || own(X));
  END LOOP;	 
END;
/
  
  