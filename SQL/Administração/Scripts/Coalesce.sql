Prompt ###############################################################
Prompt #                                                             #
Prompt #              Coalesce numa tablespace                       #
Prompt # Para cada datafile na tablespace, o coalesce combina todos  #
Prompt #        os extents livres contínuos em um extent grande.     #
Prompt #                                                             #
Prompt ###############################################################

Accept tablespace_name prompt "Digite o nome da Tablespace : "

alter tablespace &tablespace_name coalesce
/


