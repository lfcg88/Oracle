LOAD DATA
INFILE 'unidfede.dadoshp'
BADFILE 'unidfede.BAD'
DISCARDFILE 'unidfede.DSC'
REPLACE
INTO TABLE tabapoio.unidade_federativa
 (sg_uf                   POSITION(1:2)    char,
  nm_uf                   POSITION(3:32)   char, 
  cd_esta_uf              POSITION(33:34)  zoned,	
  cd_aliq_apre_uf         POSITION(35:35)  zoned, 
  st_uf                   POSITION(36:36)  zoned,	 
  dt_incl                 SYSDATE)
  
