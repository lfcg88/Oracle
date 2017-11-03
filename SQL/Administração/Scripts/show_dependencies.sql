create or replace procedure show_dependencies( objectstr varchar2
                                             , plevel number := 0) as
/* Author:              Ahbaid Gaffoor
   Date:                Sunday 18th August 2002
   File:                show_dependencies.sql
   Purpose:             This procedure recursively examines DBA_DEPENDENCIES 
                        and prints a dependency tree for an object. 
   Usage:               exec show_dependencies('..');

   Example:             set serveroutput on
                        exec show_dependencies('SCOTT.EMPLOYEE.TABLE');

   Alterado por:        Sergio Rodrigues
   Data:                Sexta 11/08/2005

   Notes:               Create as SYS and create a public synonym for the procedure

                        grant execute on show_dependencies to public;
                        create public synonym show_dependencies for show_dependencies;
*/

   fowner varchar2(30);
   fname varchar2(30);
   ftype varchar2(30);

   cursor c1 (f1 varchar2, f2 varchar2, f3 varchar2) is 
                select owner, name, type
                from dba_dependencies
                where referenced_owner = f1 and
                      referenced_name = f2 and
                      referenced_type = f3;

   c1var c1%ROWTYPE;

begin
dbms_output.enable(9999999999);

   fowner := substr(objectstr,1,instr(objectstr,'.',1,1)-1);
   fname  := substr(objectstr,instr(objectstr,'.',1,1)+1,instr(objectstr,'.',1,2)-instr(objectstr,'.',1,1)-1);
   ftype  := substr(objectstr,instr(objectstr,'.',1,2)+1);

   open c1(fowner,fname,ftype);
   loop

      fetch c1 into c1var;
      exit when c1%NOTFOUND;
         dbms_output.put_line(rpad('-',(plevel+1)*3,' ')||to_char(plevel+1)||' - '||
                               c1var.type||':  '||c1var.owner||'.'||c1var.name);
         show_dependencies(c1var.owner||'.'||c1var.name||'.'||c1var.type,plevel+1);

   end loop;
   close c1;

end;
/
show errors


grant execute on show_dependencies to public;

create public synonym show_dependencies for show_dependencies;

