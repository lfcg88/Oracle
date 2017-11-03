select user,global_name from global_name;

/* Tamanho do Database */

select 'SOMA TOTAL TABLESPACE', sum(ts_size) || ' GB'
  from (select t.tablespace_name,
               to_char(round(sum(bytes / (1024 * 1024 * 1024)), 0)) ts_size
          from dba_tablespaces t, dba_data_files d
         where t.tablespace_name = d.tablespace_name
         group by t.tablespace_name
        union all
        select tablespace_name,
               to_char(round(sum(bytes / (1024 * 1024 * 1024)), 0)) ts_size
          from dba_temp_files
         group by tablespace_name)
UNION ALL
select t.tablespace_name,
       to_char(round(sum(bytes / (1024 * 1024)), 0)) ts_size
  from dba_tablespaces t, dba_data_files d
 where t.tablespace_name = d.tablespace_name
 group by t.tablespace_name
union all
select tablespace_name,
       to_char(round(sum(bytes / (1024 * 1024 * 1024)), 0)) ts_size
  from dba_temp_files
 group by tablespace_name


/* Referencias de um objeto */

select DISTINCT(A.name),A.TYPE,a.referenced_name,A.owner
from dba_dependencies a, dba_tab_cols  b where refeREnced_name =UPPER('NOME_DO_OBJETO')
AND a.referenced_name=b.table_name


/* Verifica a utilização dos indices monitorados  */

ALTER INDEX INDEX_NAME MONITORING USAGE;  -- HABILITA A MONITORIA DO INDICE

ALTER INDEX INDEX_NAME NOMONITORING USAGE;  -- DESABILITA A MONITORIA DO INDICE  

SELECT * FROM V$OBJECT_USAGE WHERE MONITORING = 'YES'
ORDER BY USED DESC


/* Verifica objetos sem analyze */

select   owner ,table_name,last_analyzed 
from     sys.dba_tab_columns
WHERE TRUNC(last_analyzed) < '30-MAy-2008'
AND OWNER NOT IN ('SYS','SYSTEM','PERFSTAT','PUBLIC')


/* VERIFICA OBJETOS DESCOMPILADOS */
SELECT OWNER, COUNT(*) FROM DBA_OBJECTS WHERE STATUS = 'INVALID'
AND OWNER NOT IN ('SYS','SYSTEM','HOME','AGR_SECUR','CFI','IMOBILIARIA','MONITORAMENTO','PERFSTAT','PUBLIC','SENIOR','MERCADORIAS')
GROUP BY OWNER


/* Objetos locados  */
select b.locked_mode, b.process, b.os_user_name,a.object_name,a.owner, st.sql_text
from dba_objects a, v$locked_object b, v$session c,  V$SQLtext st, V$SQL sq
where a.object_id = b.OBJECT_ID
AND c.sql_address = st.address (+)
AND st.sql_id = sq.sql_id


-- lista os grants de uma instancia

select 'grant ' || privilege || ' on ' || owner || '.' || table_name || 
       ' to '   || 
        grantee || decode(grantable, 'YES', ' with grant option') || ';'
from dba_tab_privs
where owner not in ('SYS','SYSTEM', 'OLAPSYS', 'DMSYS', 'TSMSYS',
'SCOTT','DBSNMP','OUTLN','WMSYS','ORDSYS','ORDPLUGINS','MDSYS', 'SI_INFORMTN_SCHEMA',
'CTXSYS','XDB','ANONYMOUS', 'MGMT_VIEW', 'EXFSYS','MDDATA')
order by owner

-- Verifica conexões no banco
select inst_id, SID, SERIAL#, USERNAME, OSUSER, TERMINAL, status,PROGRAM, STATE, SERVICE_NAME FROM GV$SESSION
where status = 'ACTIVE'
and osuser <> 'oracle'
order by terminal

-- Indica em que banco e usuários está logado (GN)
select user, global_name from global_name;


-- Movendo objetos entre Tablespaces
ALTER INDEX PRA_RISKMANAGER.DADOS_RISCO_CLIENTE_PK REBUILD TABLESPACE RISKMAN_TBS_INDX

alter table corrwin.cliente_maquina1 move tablespace stage

alter table DWSINISTRO.TEMP_EMPRESA_PROD_CONSOL move tablespace DWSINISTRO1;
alter table DWSINISTRO.TEMP_EMPRESA_PROD move tablespace DWSINISTRO1;

--

select segment_name, owner, segment_type
from dba_segments
where tablespace_name='DWSINISTRO3';

-- Plano de Execução
SET AUTOTRACE ON


-- Atualização das estatísticas
analyze index NU3_TBOMOVCLH compute statistics;

exec dbms_stats.gather_schema_stats('SCHEMA_NAME',null,false,'FOR ALL COLUMNS SIZE 1',8,'DEFAULT',true,null,null,'GATHER');

-- Kill session
ALTER SYSTEM KILL SESSION '128,3942' immediate


--Verificar a fragmentação
select owner, segment_name, segment_type, bytes, extents from dba_segments gments where extents > 20
AND segment_type = 'INDEX' AND OWNER = 'CORRWIN'
