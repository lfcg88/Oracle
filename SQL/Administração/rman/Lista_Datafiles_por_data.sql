
select * from rc_datafile where drop_time is  null and creation_time < to_date ('27/12/2002 22:00','DD/MM/YYYY HH24:MI:SS')
OR DROP_TIME IS NOT NULL AND DROP_TIME > TO_DATE('27/12/2002 22:00','DD/MM/YYYY HH24:MI:SS')
AND DB_NAME = 'MIAFIS'
ORDER BY FILE#

