
connect jfv/jfv

select sum(salary) from emp;

-- scn1
select current_scn from v$database;

insert into emp select * from emp;

commit;

select sum(salary) from emp;
