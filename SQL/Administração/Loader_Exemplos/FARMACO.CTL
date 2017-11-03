LOAD DATA
 INFILE '/usr/oracle/pro1ora/carga/farmaco.aix'
 BADFILE 'farmaco.BAD'
 DISCARDFILE 'farmaco.DSC'
 APPEND  
 INTO TABLE sishce.farmaco
  (CODFAR          position(9:11)     CHAR ,
   NOMEFAR         position(13:47)    CHAR ,
   DATAHORA        position(49:67)    DATE "yyyy-mm-dd-hh24.mi.ss"
                      nullif datahora=blanks,           
   USERID          position(76:83)     CHAR
                      nullif userid=blanks,   
   TERMINAL        constant "hce019") 
