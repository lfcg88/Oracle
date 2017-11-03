set serveroutput on

declare
        VAR1 number;
        VAR2 number;
        VAR3 number;
        VAR4 number;
        VAR5 number;
        VAR6 number;
        VAR7 number;
begin
dbms_space.unused_space('&USER','&NAME','&TYPE',
                          VAR1,VAR2,VAR3,VAR4,VAR5,VAR6,VAR7);
   dbms_output.put_line('OBJECT_NAME       = SPACES');
   dbms_output.put_line('---------------------------');
   dbms_output.put_line('TOTAL_BLOCKS      = '||VAR1);
   dbms_output.put_line('TOTAL_MBYTES       = '||VAR2/1024/1024);
   dbms_output.put_line('UNUSED_BLOCKS     = '||VAR3);
   dbms_output.put_line('UNUSED_MBYTES      = '||VAR4/1024/1024);
   dbms_output.put_line('OCCUPED_MBYTES      = '||((VAR2/1024/1024)-(VAR4/1024/1024)));
   dbms_output.put_line('LAST_USED_EXTENT_FILE_ID  = '||VAR5);
   dbms_output.put_line('LAST_USED_EXTENT_BLOCK_ID = '||VAR6);
   dbms_output.put_line('LAST_USED_BLOCK   = '||VAR7);
end;
/
