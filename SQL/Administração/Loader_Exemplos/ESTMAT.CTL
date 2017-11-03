LOAD DATA
 INFILE '/home/valeria/control/estmat.BAD'
 BADFILE 'estmat.BAD'
 DISCARDFILE 'estmat.DSC'
 APPEND   
 INTO TABLE sishce.estmat 
  (CODMAT          position(9:13)    CHAR ,
   ESTINIC         position(23:32)   CHAR ,            
   ENTRAEST        position(35:44)   CHAR ,
   SAIDAEST        position(52:62)   CHAR ,           
   ESTFIM          position(64:74)   CHAR ,
   VALUNIT         position(84:96)   CHAR ,
   CUSTOENT        position(98:108)  CHAR ,
   CUSTOSAI        position(110:120) CHAR ,
   NIVMIN          position(122:132) CHAR ,
   USERID          constant "valeria",
   TERMINAL        constant "hce019",
   DATAHORA        position(143:161)   DATE "yyyy-mm-dd-hh24.mi.ss"
                 nullif datahora=blanks
  )
