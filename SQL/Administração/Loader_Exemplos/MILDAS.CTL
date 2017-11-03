LOAD DATA INFILE '/transfer/backup/mildas14.aix'
 BADFILE 'mildas.BAD'
 DISCARDFILE 'mildas.DSC'
 APPEND 
 INTO TABLE sishce.bendas
 (
 CATEG           position(9:9)        CHAR,
 PREC            position(11:16)      INTEGER EXTERNAL,
 CP              position(18:28)      INTEGER EXTERNAL,
 SEXO            position(30:30)      CHAR
                  nullif sexo=blanks,
 DTNASC          position(32:41)      DATE "dd.mm.yyyy"
                  nullif dtnasc=blanks,
 NOMEBEN         position(43:90)      CHAR,
 DTVALCRT        position(92:101)     DATE "dd.mm.yyyy"
                  nullif dtnasc=blanks,
 TIPOVALCRT      position(103:103)    CHAR,
 CODOM           position(105:110)    CHAR,
 EMISSAO         position(112:112)    CHAR,
 DTINCBEN        position(114:117)    DATE "mmyy"
                  nullif dtnasc=blanks,
 COBRCART        position(119:119)    CHAR,
 PSTGRD          position(121:122)    CHAR,
 IDENTBEN        position(124:135)    CHAR,
 CPFBEN          position(137:147)    CHAR,
 USERID          constant "VALERIA",  
 TERMINAL        constant "hce019", 
 DATAHORA        constant "23/02/96"                
 )
