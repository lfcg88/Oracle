
connect jfv/jfv

create smallfile tablespace jfvtbs2
datafile 'jfvtbs2.dbf' size 500K
logging
extent management local
segment space management auto;

alter tablespace jfvtbs2 flashback off;

select name,flashback_on from v$tablespace;

