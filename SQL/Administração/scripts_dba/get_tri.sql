set linesize 200
select 'spool '||trigger_name||'
select trigger_body from user_triggers 
where trigger_name = '||trigger_name||';'
--spool off '
--!grep -i "peso_total_liquido" a.lst;if [ $? = 0 ] then cat a >> tri_ok fi' 
from user_triggers 
/
