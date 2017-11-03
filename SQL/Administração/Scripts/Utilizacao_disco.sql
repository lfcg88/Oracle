select          substr(df.name,1,5)       drive
,               sum(fs.phyrds)            total_reads
,               sum(fs.phyblkrd)          blocks_read
,               sum(fs.phywrts)           total_writes
,               sum(fs.phyblkwrt)         blocks_written
,               sum(fs.phyrds+fs.phywrts) total_ios
from            v$filestat      fs
,               v$datafile      df
where           df.file# = fs.file#
group by        substr(df.name,1,5)
order by        total_ios desc;

select          substr(df.name,1,5)             drive
,               df.name                         file_name
,               fs.phyrds                       total_reads
,               fs.phyblkrd                     blocks_read
,               fs.phywrts                      total_writes
,               fs.phyblkwrt                    blocks_written
,               fs.phyrds+fs.phywrts            total_ios
from            v$filestat      fs
,               v$datafile      df
where           df.file# = fs.file#
order by        drive
,               file_name desc;