set verify off
accept aaa prompt "Gostaria de ver os grants que qual usuário recebeu ?"
select grantor||' deu para '||grantee||' O PRIVILEGIO DE '||privilege||' NA TABELA '||table_name||' DO SISTEMA '||table_schema "Privilegios Concedidos " from all_Tab_privs
where table_schema not like 'SYS%'
and grantee = upper('&aaa')
order by table_name
/
set verify on