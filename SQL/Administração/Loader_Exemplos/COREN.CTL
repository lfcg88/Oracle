LOAD DATA
 INFILE'/transfer/backup/coren.aix'
 BADFILE '/transfer/backup/coren.BAD'
 DISCARDFILE '/transfer/backup/coren.DSC'
 TRUNCATE
 INTO TABLE sishce.pessoal
  (CODPESSOAL      sequence (max),
   GUERRA          position(9:28)      CHAR ,
   NOME            position(30:69)     CHAR ,
   RUA             position(71:105)    CHAR ,
   BAIRRO          position(107:121)   CHAR ,
   CIDADE          position(123:142)   CHAR ,
   CEP             position(144:151)   CHAR ,
   UF              position(153:154)   CHAR ,
   TEL             position(156:167)   CHAR ,
   CRPROF          position(169:175)   CHAR ,
   USERID          constant "valeria",
   TERMINAL        constant "hce008",
   DATAHORA        position(177-195)   DATE "yyyy-mm-dd-hh24.mi.ss"
  )
