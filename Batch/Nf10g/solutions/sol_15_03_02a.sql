
SQL "alter tablespace tbsasmmig offline";

backup as copy tablespace tbsasmmig format '+DGROUP1';

switch tablespace tbsasmmig to copy;

SQL "alter tablespace tbsasmmig online";

exit
