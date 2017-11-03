select banner
,      regexp_instr(banner,'[^ ]+', 1, 5) word_5
from   v$version
where  rownum = 1;