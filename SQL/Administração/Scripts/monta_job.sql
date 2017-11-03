Declare
wrkc_onde varchar2(10);
cursor c_job is (select *
                   from dba_jobs
                  where broken = 'Y' 
                    and schema_user not in ('SYS', 'SYSTEM')
                    and (   upper(what) not like ('%DBMS_REFRESH%') 
                        and upper(what) not like ('%DBMS_SNAPSHOT%') )
                 );

Begin
  Begin
   Select substr(global_name,1,instr(global_name,'.',1,1)-1)
     into wrkc_onde
     from global_name;
   dbms_output.put_line('BANCO: '||wrkc_onde);
  End;   

  For r_job in c_job loop
     
     dbms_output.put_line('JOB --'||r_job.job);     
     dbms_output.put_line('DECLARE');
     dbms_output.put_line('X NUMBER;');
     dbms_output.put_line('BEGIN');
     dbms_output.put_line('DBMS_JOB.SUBMIT');
     dbms_output.put_line('(job => X');
     dbms_output.put_line(',what => '||''''||replace(r_job.what, chr(10), ' ')||'''');
     dbms_output.put_line(',next_date => to_date('||''''||to_char(r_job.next_date, 'dd/mm/yyyy hh24:mi:ss')||''''||','||''''||'dd/mm/yyyy hh24:mi:ss'||''''||')');
     dbms_output.put_line(',interval => '||''''||r_job.interval||'''');
     dbms_output.put_line(',no_parse  => FALSE)');
     dbms_output.put_line('END;');
     dbms_output.put_line('/');
     dbms_output.put_line(' ');
                              
  End loop;
End;  
/