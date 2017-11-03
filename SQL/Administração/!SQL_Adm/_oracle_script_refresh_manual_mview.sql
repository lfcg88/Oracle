SELECT distinct 'EXECUTE DBMS_REFRESH.REFRESH (name => ''"'|| s.OWNER || '"."' || r.NAME ||'"'' );'
FROM DBA_SNAPSHOTS
WHERE OWNER = 'CRMPS8'




-- fazendo o refresh de todos os grupos de um banco
SELECT distinct 'EXECUTE DBMS_REFRESH.REFRESH (name => ''"'|| s.OWNER || '"."' || r.NAME ||'"'' );'
FROM DBA_SNAPSHOTS s, DBA_RGROUP r
where s.refresh_group = r.refgroup