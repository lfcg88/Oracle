LOAD DATA INFILE '/transfer/backup/ebd4.aix'
 BADFILE '/transfer/backup/ebd.BAD'
 DISCARDFILE '/transfer/backup/ebd.DSC'
 APPEND  
 INTO TABLE sishce.ebd
 (
 NRP             position(13:19)      CHAR,
 PREC            position(21:26)      INTEGER EXTERNAL,
 CP              position(28:38)      INTEGER EXTERNAL,
 NOME            position(40:79)      CHAR,
 IDENT           position(81:92)      CHAR,            
 EXP             position(94:96)      CHAR,
 CODESTCV        position(98:98)      CHAR,             
 COR             position(100:100)    CHAR,
 SEXO            position(102:102)    CHAR,
 DTNASC          position(104:113)    DATE 'dd.mm.yyyy'     
                  nullif dtnasc=blanks,
 NATURAL         position(115:116)    CHAR,
 NOMEPAI         position(118:157)    CHAR,
 NOMEMAE         position(159:198)    CHAR,
 RUA             position(200:234)    CHAR,
 BAIRRO          position(236:250)    CHAR,
 CIDADE          position(252:271)    CHAR,
 UF              position(273:274)    CHAR,
 CEP             position(276:283)    CHAR,
 TEL             position(285:296)    CHAR,
 TB              position(298:298)    CHAR,
 USERID          constant 'VALERIA',
 TERMINAL        constant 'hce019',
 DATAHORA        constant '14/02/96'    
 )  
