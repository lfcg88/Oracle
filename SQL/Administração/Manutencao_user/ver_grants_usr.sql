/* script para verificar grants */
accept owner prompt 'Qual o owner do sistema a ser verificado ? '
select grantor||' deu para '||grantee||' O PRIVILEGIO DE '
||privilege||' NA TABELA '||table_name||' DO SISTEMA '
||owner "Privilegios Concedidos" 
from user_Tab_privs
where owner = upper('&owner')
/