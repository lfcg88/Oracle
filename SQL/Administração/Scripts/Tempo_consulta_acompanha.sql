SELECT NEXT_DAY(TRUNC(A.DT_CONSULTA),'SUNDAY')-7 DOMINGO
     , TO_CHAR(A.DT_CONSULTA,'WW') SEMANA
     , MAX(A.VL_TEMPO_TRANSACAO) MAXIMO
     , MIN(A.VL_TEMPO_TRANSACAO) MINIMO
     , TRUNC(AVG(A.VL_TEMPO_TRANSACAO),4) MEDIA
     , TRUNC(STDDEV(A.VL_TEMPO_TRANSACAO),4) DESVIO_PADRA
  FROM S5B.LG_AUTORIZACAO A
 WHERE A.DT_CONSULTA > '01-JAN-2006'
 GROUP BY NEXT_DAY(TRUNC(A.DT_CONSULTA),'SUNDAY')-7
     , TO_CHAR(A.DT_CONSULTA,'WW')
/
