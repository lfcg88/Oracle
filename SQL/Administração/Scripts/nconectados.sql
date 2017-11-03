-- Os usuários que não conectaram no banco nos ultimos 90 dias.

select username from dba_users minus 
select  distinct a.username from  DBA_USERS a , DBA_AUDIT_SESSION b
where a.username = b.username 
and b.timestamp > '25/03/10';

