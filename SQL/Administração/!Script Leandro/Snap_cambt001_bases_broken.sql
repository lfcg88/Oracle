Prompt ###############################################
Prompt #                                             #
Prompt #           REFRESH SNAPSHOT CAMBT001         #
Prompt #               EM TODAS AS BASES             #
Prompt #                                             #
Prompt ###############################################

SET LINES 1000
set numformat 999999999999
COL INTERVAL FORMAT A40
COL SNAPSHOT FORMAT A40
ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE


conn system/&senha@bhd1
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';


conn system/&senha@dftpux01
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';


conn system/&senha@fld0
@onde
select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';




conn system/&senha@fzd0
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';



conn system/&senha@ped0
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';



conn system/&senha@bad0
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';



conn system/&senha@spd1
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';


conn system/&senha@dfd0
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';


conn system/&senha@rjd3
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';


conn system/&senha@rsd0
@onde

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';

ACCEPT JOB CHAR PROMPT 'Digite o numero do JOB:' 

BEGIN
  SYS.DBMS_IJOB.BROKEN('&JOB',FALSE);
  COMMIT;
END;
/


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.CAMBT001'
   ,METHOD               => 'F'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select OWNER || '.' || NAME SNAPSHOT,
       RNAME,
       JOB,
       NEXT_DATE,
       INTERVAL,
       BROKEN
  from dba_refresh_children
 where name = 'CAMBT001';







