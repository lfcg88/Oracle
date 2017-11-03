LOAD DATA INFILE '/transfer/backup/depdas34.08'
 BADFILE 'depdas.BAD'
 DISCARDFILE 'depdas.DSC'
 APPEND 
 INTO TABLE sishce.depdas
 (
 PREC            position(9:14)      INTEGER EXTERNAL,
 CP              position(16:26)      INTEGER EXTERNAL,
 SEQFAM          position(28:29)      CHAR,
 CONDIDEP        position(31:32)      CHAR,
 BIDEP           position(34:38)      CHAR,
 SEXO            position(40:40)      CHAR,
 DTNASC          position(42:51)      DATE "dd.mm.yyyy"
                  nullif dtnasc=blanks,
 NOMEDEP         position(53:100)     CHAR,
 DTVALCRT        position(102:111)    DATE "dd.mm.yyyy"
                  nullif dtnasc=blanks,
 TIPOVALCRT      position(113:113)    CHAR,
 EMISSAO         position(115:115)    CHAR,
 DTINCDEP        position(117:120)    DATE "mmyy"
                  nullif dtnasc=blanks,
 COBRCART        position(122:122)    CHAR,
 DATAHORA        SYSDATE                
 )
