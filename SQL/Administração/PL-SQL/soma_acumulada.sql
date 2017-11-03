select to_char(USU.DATA_CRIACAO, 'mm'), COUNT(USU.USUARIO) USUARIOS
    , SUM(COUNT(USU.USUARIO)) 
over (order by to_char(USU.DATA_CRIACAO, 'mm') 
rows between unbounded preceding and current row) AS USUARIO_ACUMULADOS
from CADADMIN.USUARIO USU
group by to_char(USU.DATA_CRIACAO, 'mm')