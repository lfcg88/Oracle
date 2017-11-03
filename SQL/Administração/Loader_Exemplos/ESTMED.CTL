LOAD DATA
 INFILE '/home/valeria/control/estmed.BAD'
 BADFILE 'estmed.BAD'
 DISCARDFILE 'estmed.DSC'
 APPEND
 INTO TABLE sishce.estmed 
  (CODMED          position(9:19)     ,
   ESTINIC         position(21:31)    ,
   ENTRAEST        position(33:43)    ,
   SAIDAEST        position(45:55)    ,           
   ESTFIM          position(57:67)    ,
   VALUNIT         position(69:81)    DECIMAL EXTERNAL
             "TRANSLATE(:VALUNIT,'.',',')",
   CUSTOENT        position(83:93)    DECIMAL EXTERNAL 
             "TRANSLATE(:CUSTOENT,'.',',')",
   CUSTOSAI        position(95:105)   DECIMAL EXTERNAL
             "TRANSLATE(:CUSTOSAI,'.',',')",
   NIVMIN          position(107:117)  ,
   USERID          position(119:126)  ,
   TERMINAL        constant "hce019",
   DATAHORA        position(128:146)   DATE "yyyy-mm-dd-hh24.mi.ss"
                 nullif datahora=blanks
  )
