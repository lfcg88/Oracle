Prompt ###############################################
Prompt #                                             #
Prompt #           REFRESH SNAPSHOT CAMBT001         #
Prompt #               EM TODAS AS BASES             #
Prompt #                                             #
Prompt ###############################################


ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE


conn system/&senha@bhd1
@onde

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



conn system/&senha@dftpux01
@onde

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



conn system/&senha@fld0
@onde
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



conn system/&senha@fzd0
@onde

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



conn system/&senha@ped0
@onde

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



conn system/&senha@bad0
@onde

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



conn system/&senha@spd1
@onde

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



conn system/&senha@dfd0
@onde

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



conn system/&senha@rjd3
@onde

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



conn system/&senha@rsd0
@onde

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
