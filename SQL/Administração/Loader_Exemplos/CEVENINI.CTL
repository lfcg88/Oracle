--LOAD DATA INFILE '/u/valeria/carga/CADASTRO.TXT' 
LOAD DATA INFILE '/u/valeria/control/mar1.BAD'      
 BADFILE 'marco.BAD'
 DISCARDFILE 'marco.DSC' 
 APPEND
 INTO TABLE sishce.depdas
   when seqfam != '00' 
 (
 PREC            position(2:3)       INTEGER EXTERNAL,
 CP              position(4:10)     INTEGER EXTERNAL,
 SEQFAM          position(11:12)      CHAR,
 CONDIDEP        position(13:14)      CHAR,
 BIDEP           position(15:19)      CHAR,
 SEXO            position(20:20)      CHAR,
 DTNASC          position(21:26)      DATE "ddmmyy"
                  nullif dtnasc=blanks,
 NOMEDEP         position(27:74)      CHAR,
 DTVALCRT        position(75:80)      DATE "ddmmyy"    
                  nullif dtvalcrt="000000",
 TIPOVALCRT      position(81:81)      CHAR,
 EMISSAO         position(88:88)      CHAR,
 DTINCDEP        position(89:92)      DATE "mmyy"
                  nullif dtincdep=blanks,
 COBRCART        position(93:93)      CHAR,
 DATAHORA          sysdate,                                            
 USERID            constant "VALERIA",
 TERMINAL          constant "hce238"
)
 
INTO TABLE sishce.bendas
   when (11:12) = '00' 
 (
 CATEG           position(1:1)        CHAR,
 PREC            position(2:3)        INTEGER EXTERNAL,
 CP              position(4:10)       INTEGER EXTERNAL,
 SEXO            position(20:20)      CHAR
                  nullif sexo=blanks,
 DTNASC          position(21:26)      DATE "ddmmyy"    
                  nullif dtnasc=blanks,
 NOMEBEN         position(27:74)      CHAR,
 DTVALCRT        position(75:80)      DATE "ddmmyy"    
                  nullif dtvalcrt="000000",
 TIPOVALCRT      position(81:81)      CHAR,
 CODOM           position(82:87)      CHAR,
 EMISSAO         position(88:88)      CHAR,
 DTINCBEN        position(89:92)      DATE "mmyy"
                  nullif dtincben=blanks,
 COBRCART        position(93:93)      CHAR,
 PSTGRD          position(94:95)      CHAR,
 IDENTBEN        position(96:107)     CHAR,
 CPFBEN          position(108:118)    CHAR,
 DATAHORA        sysdate,                                              
 USERID            constant "VALERIA",
 TERMINAL          constant "hce238"
)
