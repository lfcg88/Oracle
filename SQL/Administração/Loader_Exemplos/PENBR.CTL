LOAD DATA INFILE '/u/valeria/carga/pendas.aix' 
 BADFILE 'pendas.BAD'
 DISCARDFILE 'pendas.DSC'
 APPEND        
 INTO TABLE sishce.bendas
 (
 CATEG           position(1:1)        CHAR,
 PREC            position(2:3)        INTEGER EXTERNAL,
 CP              position(4:10)       INTEGER EXTERNAL,
 SEXO            position(20:20)      CHAR
                  nullif sexo=blanks,
 DTNASC          position(21:30)      DATE "dd.mm.yyyy"
                  nullif dtnasc=blanks,
 NOMEBEN         position(31:78)      CHAR,
 DTVALCRT        position(79:88)      DATE "dd.mm.yyyy"
                  nullif dtvalcrt=blanks,
 TIPOVALCRT      position(89:89)      CHAR,
 CODOM           position(90:95)      CHAR,
 EMISSAO         position(96:96)      CHAR,
 DTINCBEN        position(97:100)     DATE "mmyy"
                  nullif dtincben=blanks,
 COBRCART        position(101:101)    CHAR,
 PSTGRD          position(103:103)    CHAR,
 IDENTBEN        position(104:115)    CHAR,
 CPFBEN          position(116:126)    CHAR,
 DATAHORA          position(149:167)     DATE "yyyy-mm-dd-hh24:mi:ss" ,
 USERID            constant "VALERIA",
 TERMINAL          constant "hce019"
)
