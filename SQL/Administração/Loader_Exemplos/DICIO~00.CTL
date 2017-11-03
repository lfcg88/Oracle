LOAD DATA INFILE '/u/valeria/dicionario'
 BADFILE 'dicionario.BAD'
 DISCARDFILE 'dicionario.DSC'
 APPEND  
 INTO TABLE sishce.dicit
 (
 ATRIBUTO               position(1:18)        CHAR,
 SIGNIFICADO            position(20:74)       CHAR,
 TAB_REF                position(76:90)       CHAR)
