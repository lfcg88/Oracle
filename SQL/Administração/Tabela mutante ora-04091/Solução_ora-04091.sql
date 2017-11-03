
drop table emp
/
create table emp
(empno number
,ename varchar2(30)
)
/

insert into emp values (1001,'Keiichi Yamada')
/


create or replace package emp_pkg as
type emp_tab_type is table of rowid index by binary_integer;
emp_tab emp_tab_type;
emp_index binary_integer;
end emp_pkg;
/

create or replace trigger emp_bef_stm_all
before insert or update or delete on emp
begin
/*
Remember to reset the pl/sql table before each statement
*/
emp_pkg.emp_index := 0;
end;
/

create or replace trigger emp_aft_row_all
after insert or update or delete on emp
for each row
begin
/*
Store the rowid of updated record into global pl/sql table
*/
emp_pkg.emp_index := emp_pkg.emp_index + 1;
emp_pkg.emp_tab(emp_pkg.emp_index) := :new.rowid;
end;
/

create or replace trigger emp_aft_stm_all
after insert or update or delete on emp
begin
for i in 1 .. emp_pkg.emp_index loop

/* Modified to update emp */

update emp
set ename = 'Test Trigger'
where rowid = emp_pkg.emp_tab(i);

dbms_output.put_line(emp_pkg.emp_tab(i));
end loop;
emp_pkg.emp_index := 0;
end;
/

update emp set ename='test'
where empno=1001
/ 