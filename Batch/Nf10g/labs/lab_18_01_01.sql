
set echo on

connect / as sysdba;

select view_name, text
from   dba_views
where  regexp_like(view_name,'^(dba|all|user)_&search.$','i');
