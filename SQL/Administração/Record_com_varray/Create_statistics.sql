declare
  type ty_owner is record
    (
    owner varchar2(30),
	enabled boolean:= true
	);
    
  type ty_lista_owner is varray (9) of ty_owner;
  
  own ty_lista_owner := ty_lista_owner (null, null, null, null, null, null, null, null, null); 
begin
  own(1).owner:= 'IDT'; own(2).owner:= 'CIV'; own(3).owner:= 'CRM'; own(4).owner:= 'MIG'; own(5).owner:= 'WFL'; 
  own(6).owner:= 'DGT'; own(7).owner:= 'BDI'; own(8).owner:= 'CRP'; own(9).owner:= 'LAT';
  
  own(1).enabled:= false;  own(2).enabled:= true;   own(3).enabled:= true;   own(4).enabled:= true; own(5).enabled:= true;    
  own(6).enabled:= true;   own(7).enabled:= true;   own(8).enabled:= true;   own(9).enabled:= true; 
  
  FOR X IN OWN.FIRST .. OWN.LAST LOOP
    if own(X).enabled then
      DBMS_STATS.GATHER_SCHEMA_STATS (
      ownname => OWN(X).owner,
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
    DBMS_OUTPUT.PUT_LINE ('Estatisticas criadas para owner ' || own(X).owner);
	ELSE
	  DBMS_OUTPUT.PUT_LINE ('Estatistica desabilitada para owner ' || own(X).owner);
	END IF;
  END LOOP;
END;
/
  
  
  