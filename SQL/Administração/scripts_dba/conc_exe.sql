set arraysize 1
col REQUESTOR format a20
col PROGRAM format a20
SELECT  PHASE_CODE, REQUESTOR, REQUEST_ID, 
  PROGRAM,PRIORITY
FROM
 FND_CONC_REQ_SUMMARY_V
WHERE PHASE_CODE = 'R'
/