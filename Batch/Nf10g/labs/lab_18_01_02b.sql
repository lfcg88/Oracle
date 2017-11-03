select banner
,      regexp_instr(banner,'e[a-z]{6,}', 1, 2, 0, 'i') hit_2
from   v$version
where  rownum = 1;