
set echo on

connect / as sysdba

shutdown immediate;

startup mount;

-- scn1
flashback database to scn &scn;
