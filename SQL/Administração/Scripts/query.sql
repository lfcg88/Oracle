--select owner||'.'||segment_name
--     , segment_type
--     , tablespace_name
--     , to_char(bytes/1024/1024, '999G990D99') Mb
--  from dba_segments where (segment_name like '%BKP%' or segment_name like '%BACKUP%')

--select * from dba_synonyms where substr(db_link,1,instr(db_link,'.',1,1)-1) = 'DIF01' or  --substr(db_link,1,instr(db_link,'.',1,1)-1) = 'DIF02'

--select * from dba_snapshots where substr(master_link,1,instr(master_link,'.',1,1)-1) = '@DIF01'
--or substr(master_link,1,instr(master_link,'.',1,1)-1) = '@DIF02'

--select JOB, what, broken, to_char(last_date, 'dd/mm/yyyy hh24:mi:ss')
--  from dba_jobs
-- where schema_user not in ('SYS', 'SYSTEM')
--   and upper(what) like ('%SACM%')

--select datacambio, taxacambio from cambt001 where datacambio = '22/9/2009'

--select * from dba_db_links where db_link = 'INTQ_RJD10.BRASIFNET.COM.BR'

--select username from dba_users where username like '%ORACLE%'

--select rowner, rname
--  from dba_refresh
-- where rname like '%CAMBT001%'
--    or rname like '%ITEM_APRESENTACAO_ITEM%'
--    or rname like '%LIR_GERAL_PRI%'

select grantee
     , granted_role
  from dba_role_privs
 where granted_role in ('SIA_AUDITOR', 'SIA_GERENTE_AUDITORIA', 'SIA_RECEITA_FEDERAL', 'SIA_GERENTE_DEPOSITO')
/
