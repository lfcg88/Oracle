LOAD DATA INFILE '/transfer/backup/ebpe.aix'
 BADFILE '/transfer/backup/ebp.BAD'
 DISCARDFILE '/transfer/backup/ebp.DSC'
 APPEND 
 INTO TABLE sishce.ebb
 (
 NRP             position(13:19)      CHAR,
 PREC            position(21:26)      INTEGER EXTERNAL,
 CP              position(28:38)      INTEGER EXTERNAL,
 PSTGRD          position(40:41)      CHAR,
 CODOM           position(43:48)      CHAR,
 NOME            position(50:89)      CHAR,
 IDENT           position(91:102)     CHAR,            
 EXP             position(104:106)    CHAR,
 CODESTCV        position(108:108)    CHAR,             
 COR             position(110:110)    CHAR,
 SEXO            position(112:112)    CHAR,
 DTNASC          position(114:123)    DATE 'dd.mm.yyyy'     
                  nullif dtnasc=blanks,
 NATURAL         position(125:126)    CHAR,
 NOMEPAI         position(128:167)    CHAR,
 NOMEMAE         position(169:208)    CHAR,
 RUA             position(210:244)    CHAR,
 BAIRRO          position(246:260)    CHAR,
 CIDADE          position(262:281)    CHAR,
 UF              position(283:284)    CHAR,
 CEP             position(286:293)    CHAR,
 TEL             position(295:306)    CHAR,
 TB              position(308:308)    CHAR,
 USERID          constant 'VALERIA',
 TERMINAL        constant 'hce019',
 DATAHORA        constant '13/02/96'    
 )
