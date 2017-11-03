col username       format a20
col "SID,SESSION#" format a20
col sess_id        format a10
col object format a30
col mode_held      format a10
select     oracle_username || ' (' || s.osuser || ')' username
  ,  s.sid || ',' || s.serial# "SID,SESSION#"
  ,  owner || '.' || object_name object
  ,  object_type
  ,  decode( l.block
     ,       0, 'Not Blocking'
     ,       1, 'Blocking'
     ,       2, 'Global') status
  ,  decode(v.locked_mode
    ,       0, 'None'
    ,       1, 'Null'
    ,       2, 'Row-S (SS)'
    ,       3, 'Row-X (SX)'
    ,       4, 'Share'
    ,       5, 'S/Row-X (SSX)'
    ,       6, 'Exclusive', TO_CHAR(lmode)) mode_held
 from       v$locked_object v
 ,  dba_objects d
 ,  v$lock l
 ,  v$session s
 where      v.object_id = d.object_id
 and        v.object_id = l.id1
 and        v.session_id = s.sid
 order by oracle_username,session_id;
 
 
 
 SELECT * FROM v$locked_object
 
 ALTER SYSTEM KILL SESSION '113,587'
 
 113, 587
 244, 1263
 
 select * from dba_blockers
 
 
 select l1.sid, ' IS BLOCKING ', l2.sid
  from v$lock l1, v$lock l2
  where l1.block =1 and l2.request > 0
  and l1.id1=l2.id1
  and l1.id2=l2.id2
  
select * from v$locked_object
  
  
  select a.sid, a.serial#
from v$session a, v$locked_object b, dba_objects c 
where b.object_id = c.object_id 
and a.sid = b.session_id
and OBJECT_NAME='EMPRESA';







CREATE MATERIALIZED VIEW CRMPS8.PS_WE_USUARIO (person_id, we_produto_id, we_cod_webb, we_cod_webb_emp)
TABLESPACE "CRMPS8_S_DAT"
USING INDEX TABLESPACE "CRMPS8_S_IDX"
REFRESH FORCE ON DEMAND
AS
select person_id,
       we_produto_id,
       we_cod_webb,
       we_cod_webb_emp
from crm.ps_we_usuario@ps8;

GRANT SELECT on CRMPS8.PS_WE_USUARIO TO ROLE_PS8UPDT_READ;



BEGIN
DBMS_REFRESH.ADD (
NAME => '"CRMPS8"."GRUPO_01"', 
LIST => '"CRMPS8"."PS_WE_USUARIO"',
lax => TRUE);
END;
/


select * from DBA_REFRESH 