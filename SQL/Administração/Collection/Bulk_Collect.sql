
alter session set current_schema = scott;

create  or replace type trec1 as object (col1 varchar2(20),col2 number); 

create or replace type ttab1 as table of trec1;

create table t1 (c1 trec1); 

insert into t1 (c1) values (trec1 ('aaa',1));
insert into t1 (c1) values (trec1 ('bbb',2));
insert into t1 (c1) values (trec1 ('ccc',3));
insert into t1 (c1) values (trec1 ('ddd',4));
commit;

select * from t1;

set serveroutput on 
declare 
  coll1 ttab1;
  conta pls_integer;
  
begin
	 select c1 bulk collect into coll1 from t1; -- Carrega a tabela T1 na collection COLL1
	 if coll1 is not null then
	   for n in coll1.first .. coll1.last loop 
	     if coll1.exists (n) then
		   dbms_output.put_line (coll1(n).col1 || ' - ' || to_char (coll1(n).col2));
		 end if;
	   end loop;
     end if;			 
  
     select count(*) into conta from table (coll1); -- usa a collection COLL1 como tabela 
	 dbms_output.put_line (conta);

end;
/
