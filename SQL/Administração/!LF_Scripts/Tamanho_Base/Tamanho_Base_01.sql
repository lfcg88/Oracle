set serveroutput on
declare
dbf number;  
tmpdbf number;  
lgf number;
ctl number;
soma number;
begin
   select trunc(sum(bytes/1024/1024),2) into dbf from v$datafile;
   select trunc(sum(bytes/1024/1024),2) into tmpdbf from v$tempfile;
   select trunc(sum(bytes/1024/1024),2) into lgf from v$log l, v$logfile lf where l.group# = lf.group#;
   select trunc(sum(block_size*file_size_blks/1024/1024),2) into ctl from v$controlfile;
   select trunc((dbf+tmpdbf+lgf+ctl)/1024,2) into soma from dual;
   DBMS_OUTPUT.PUT_LINE(chr(10));
   DBMS_OUTPUT.PUT_LINE('Datafiles: '|| dbf ||' MB');
   DBMS_OUTPUT.PUT_LINE(chr(0));
   DBMS_OUTPUT.PUT_LINE('Tempfiles: '|| tmpdbf ||' MB');
   DBMS_OUTPUT.PUT_LINE(chr(0));
   DBMS_OUTPUT.PUT_LINE('Logfiles: '|| lgf ||' MB');
   DBMS_OUTPUT.PUT_LINE(chr(0));
   DBMS_OUTPUT.PUT_LINE('Controlfiles: '|| ctl ||' MB');
   DBMS_OUTPUT.PUT_LINE(chr(0));
   DBMS_OUTPUT.PUT_LINE('Total Tamanho: '|| soma ||' GB');
end;
 /