LOAD DATA
 INFILE '/transfer/backup/crm.aix'
 BADFILE '/transfer/backup/crm.BAD'
 DISCARDFILE '/transfer/backup/crm.DSC'
 APPEND  
 INTO TABLE sishce.pessoal
  (CODPESSOAL      sequence (count), 
   GUERRA          position(9:28)      CHAR ,
   NOME            position(30:69)     CHAR ,
   BIP             position(71:78)     CHAR ,           
   RUA             position(80:114)    CHAR ,
   BAIRRO          position(116:130)   CHAR ,
   CIDADE          position(132:151)   CHAR ,
   CEP             position(153:160)   CHAR ,
   UF              position(162:163)   CHAR ,
   TEL             position(165:176)   CHAR ,
   CRPROF          position(178:186)   CHAR ,
   CODESP          position(188:190)   CHAR ,
   PSTGRD          position(192:193)   CHAR,
   USERID          constant "valeria",
   TERMINAL        constant "hce008",
   DATAHORA        position(200:218)   DATE "yyyy-mm-dd-hh24.mi.ss"
  )
