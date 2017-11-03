LOAD DATA
 INFILE'/usr/oracle/pro1ora/carga/orgao.aix'
 BADFILE 'orgao.BAD'
 DISCARDFILE 'orgao.DSC'
 APPEND  
 INTO TABLE sishce.orgao 
  (CODORGAO        position(9:19)     INTEGER EXTERNAL,
   NOMEORGAO       position(21:62)    INTEGER EXTERNAL, 
   USERID          constant "VALERIA",     
   TERMINAL        constant "hce019", 
   DATAHORA        position(64:82)    DATE "yyyy-mm-dd-hh24.mi.ss"
                      nullif datahora=blanks)           
