LOAD DATA
INFILE 'grupctrc.dadoshp'
BADFILE 'grupctrc.BAD'
DISCARDFILE 'grupctrc.DSC'
REPLACE
INTO TABLE tabapoio.grupo_ctrc
 (cd_grupo_ctrc           POSITION(2:4)    zoned,
  nm_grupo_ctrc           POSITION(5:34)   char, 
  dt_incl                 SYSDATE)
  
