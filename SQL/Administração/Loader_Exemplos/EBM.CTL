LOAD DATA INFILE '/transfer/backup/ebmf.aix'
 BADFILE '/transfer/backup/ebm.BAD'
 DISCARDFILE '/transfer/backup/ebm.DSC'
 APPEND 
 INTO TABLE sishce.ebb
 (
 NRP             position(13:19)      CHAR,
 PREC            position(21:26)      INTEGER EXTERNAL,
 CP              position(28:38)      INTEGER EXTERNAL,
 PSTGRD          position(40:41)      CHAR,
 CODOM           position(43:48)      CHAR,
 SITBEN          position(50:50)      CHAR,
 NOME            position(52:91)      CHAR,
 IDENT           position(93:104)     CHAR,            
 EXP             position(106:108)    CHAR,
 CODESTCV        position(110:110)    CHAR,             
 COR             position(112:112)    CHAR,
 SEXO            position(114:114)    CHAR,
 DTNASC          position(116:125)    DATE 'dd.mm.yyyy'     
                  nullif dtnasc=blanks,
 NATURAL         position(127:128)    CHAR,
 NOMEPAI         position(130:169)    CHAR,
 NOMEMAE         position(171:210)    CHAR,
 RUA             position(212:246)    CHAR,
 BAIRRO          position(248:262)    CHAR,
 CIDADE          position(264:283)    CHAR,
 UF              position(285:286)    CHAR,
 CEP             position(288:295)    CHAR,
 TEL             position(297:308)    CHAR,
 TB              position(310:310)    CHAR,
 USERID          constant 'VALERIA',
 TERMINAL        constant 'hce019',
 DATAHORA        constant '07/02/96'    
 )
