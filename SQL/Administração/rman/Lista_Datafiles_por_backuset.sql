
select * from rc_datafile df,(select max(start_time) as DT from rc_backup_set where set_count <= 882 and backup_type='D' and incremental_level=0) bs
 where df.drop_time is  null and df.creation_time < bs.DT 
OR DROP_TIME IS NOT NULL AND DROP_TIME > bs.DT
AND DB_NAME = 'MIAFIS'
ORDER BY FILE#

