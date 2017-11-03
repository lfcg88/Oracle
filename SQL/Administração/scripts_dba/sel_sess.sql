/* Lista sessoes utilizando Oracle */

select to_char(sid,'99999') "Sid", 
       to_char(serial#,'99999') "Serial", 
       substr(username,1,12) "User name", 
       status, 
       type, 
       terminal,
       substr(program,1,20) "Programa"
from v$session
/
