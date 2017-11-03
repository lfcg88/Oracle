Prompt ###################################################
Prompt #                                                 #
Prompt #              Query no schema Perfstat           #
Prompt #                                                 #
Prompt ###################################################

Accept HASH_VALUE Prompt 'Digite o valor do hash : '

set feedback off pages 999 trims on 

SELECT SQL_TEXT 
  FROM PERFSTAT.STATS$SQLTEXT
 WHERE HASH_VALUE = &HASH_VALUE
 ORDER BY PIECE
/

set feedback on
