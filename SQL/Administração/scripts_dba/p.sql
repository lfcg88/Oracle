delete from plan_table;
commit;
explain plan
 set statement_id='DANI' into plan_table 
for
SELECT ITEMT001.codigogrupo||ITEMT001.codigosubgrupo,
       ITEMT001.codigobrasif||' '| |ITEMT001.descricaoitem,'AISP',
       sum(ITVET012.valortotalvenda-NVL(ITVET012.valortotalestornado,0)) 
FROM ITEMT001,ITVET012 
WHERE ((ITEMT001.codigogrupo = '05' AND
        ITEMT001.codigosubgrupo = '93') OR (ITEMT001.codigogrupo = '05' AND 
        ITEMT001.cod igosubgrupo = '91')) AND 
        (((ITVET012.mesanovenda BETWEEN To_Date('19980101','yyyymmdd') AND 
        To_Date('19980731','yyyymmdd')))) AND 
        (ITEMT001.CODIGOBRASIF = ITVET012.CODIGOBRASIF)  
GROUP BY ITEMT001.codigogrupo||ITEMT001.codigosubgrupo,
ITEMT001.codigobrasif||' '||ITEMT001.descricaoitem,'AISP'
start plano DANI
/
