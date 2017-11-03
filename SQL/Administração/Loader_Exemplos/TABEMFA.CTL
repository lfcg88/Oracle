LOAD DATA
 INFILE 'tabemfa.aix'
 BADFILE 'tabemfa.BAD'
 DISCARDFILE 'tabemfa.DSC'
 TRUNCATE
 INTO TABLE sishce.tabemfa
 ( COD1            position(9:10)      CHAR ,
   COD2            position(12:13)     CHAR ,
   COD3            position(15:17)     CHAR ,
   USM             position(19:24)     INTEGER EXTERNAL,
   VALOR           position(26:36)     DECIMAL EXTERNAL
             "TRANSLATE(:VALOR,'.',',')",
   NOMEEMFA        position(38:109)    CHAR ,
   USERID          constant "valeria"       ,
   TERMINAL        constant "hce008"        ,
   DATAHORA        sysdate) 
