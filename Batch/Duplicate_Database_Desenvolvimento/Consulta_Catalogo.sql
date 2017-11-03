select 'set newname for datafile ' || TO_CHAR(FILE#) || ' TO ''' || NAME || ''';' from rmann.rc_datafile where drop_time is  null and creation_time < to_date ('24/03/2004 22:00','DD/MM/YYYY HH24:MI:SS')
OR DROP_TIME IS NOT NULL AND DROP_TIME > TO_DATE('24/03/2004 22:00','DD/MM/YYYY HH24:MI:SS')
AND DB_NAME = 'MIAFIS'
ORDER BY FILE#;

select max(l.sequence#)+1 as "Sequencia" from RMAN.rc_backup_redolog l,RMAN.rc_database_incarnation i 
 where i. dbinc_key = l.dbinc_key and i.current_incarnation = 'YES' and i.name = 'MIAFIS';


update rmann.bp set handle = 'C:\ORACLE\' || SUBSTR (HANDLE,11) WHERE UPPER(HANDLE) LIKE 'E:\ORACLE\%';

update rmann.CCF set FNAME = 'C:\ORACLE\' || SUBSTR (FNAME,11) WHERE UPPER(FNAME) LIKE 'E:\ORACLE\%';

SELECT HANDLE,START_TIME FROM RMANN.BP ORDER BY START_TIME DESC;

SELECT FNAME FROM RMANN.CCF ORDER BY CREATE_TIME DESC;

COMMIT;