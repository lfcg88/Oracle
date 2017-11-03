
/* Lista sessoes Oracle com respectivos comandos SQL (sem objeto) */

select to_char(sid,'99999') "Sid", 
       to_char(serial#,'99999') "Serial", 
       substr(username,1,15) "Usuario", 
       status, 
       terminal,
       command "Num.Comando",
       decode(command,2,'INSERT',3,'SELECT',6,'UPDATE',7,'DELETE',
                      27,'NO OPERATION',44,'COMMIT',45,'ROLLBACK',
                      46,'SAVEPOINT','Outro comando SQL') "Comando SQL"
from v$session
where type = 'USER'
/
