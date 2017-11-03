drop table perfstat.stats$iostat;

create table 
perfstat.stats$iostat 
(
snap_time          date,
elapsed_seconds    number(4),
hdisk              varchar2(8),
kb_read            number(9,0),
kb_write           number(9,0)
)
tablespace perfstat
storage (initial 20m next 1m )
;

create index 
perfstat.stats$iostat_date_idx
on 
perfstat.stats$iostat
(snap_time)
tablespace perfstat
storage (initial 5m next 1m)
;

create index
perfstat.stats$iostat_hdisk_idx
on
perfstat.stats$iostat
(hdisk)
tablespace perfstat
storage (initial 5m next 1m)
;
