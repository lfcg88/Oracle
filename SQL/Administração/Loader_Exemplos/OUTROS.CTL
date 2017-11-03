LOAD DATA INFILE '/transfer/backup/outros2.aix'
 BADFILE '/transfer/backup/outros.BAD'
 DISCARDFILE '/transfer/backup/outros.DSC'
 APPEND 
 INTO TABLE sishce.outros
 (
 NRP             position(13:19)      CHAR,
 NOME            position(21:60)      CHAR,
 IDENT           position(62:73)      CHAR,            
 EXP             position(75:77)      CHAR,
 CODESTCV        position(79:79)      CHAR,             
 COR             position(81:81)      CHAR,
 SEXO            position(83:83)      CHAR,
 DTNASC          position(85:94)      DATE 'dd.mm.yyyy'     
                  nullif dtnasc=blanks,
 NATURAL         position(96:97)      CHAR,
 NOMEPAI         position(99:138)     CHAR,
 NOMEMAE         position(140:179)    CHAR,
 RUA             position(181:215)    CHAR,
 BAIRRO          position(217:231)    CHAR,
 CIDADE          position(233:252)    CHAR,
 UF              position(254:255)    CHAR,
 CEP             position(257:264)    CHAR,
 TEL             position(266:277)    CHAR,
 USERID          constant 'VALERIA',
 TERMINAL        constant 'hce019',
 DATAHORA        constant '12/02/96'    
 )
