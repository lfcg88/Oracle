BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.FNECT001'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'FNECT001';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.FNECT002'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'FNECT002';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.GRUPT001'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'GRUPT001';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.PRECT001'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'PRECT001';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.TIPOT001'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'TIPOT001';

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.SGRPT001'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'SGRPT001';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.SERVT002'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'SERVT002';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.ISSET001'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'ISSET001';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.PRECT005'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'PRECT005';

BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.PRECT007'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'PRECT007';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.LNDYT001'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'LNDYT001';


BEGIN
  DBMS_SNAPSHOT.REFRESH(
    LIST                 => 'COMERCIAL.PRECT004'
   ,METHOD               => 'C'
   ,PUSH_DEFERRED_RPC    => TRUE
   ,REFRESH_AFTER_ERRORS => FALSE
   ,PURGE_OPTION         => 1
   ,PARALLELISM          => 0
   ,ATOMIC_REFRESH       => TRUE);
END;
/

select owner
      , name
      , last_refresh
   from dba_snapshots
  where owner = 'COMERCIAL'
    and name  = 'PRECT004';


