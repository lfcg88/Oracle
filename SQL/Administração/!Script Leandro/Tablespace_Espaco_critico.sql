Prompt ###################################################
Prompt #                                                 #
Prompt #              Tamanho das tablespaces            #
Prompt #    Lista o tamanho de cada tablesapce do banco  #
Prompt #     com tamanho usado > 90% ou num_extents < 10 #
Prompt #                                                 #
Prompt ###################################################


COLUMN tsname        FORMAT a35
COLUMN Tot_Size      FORMAT 999G999D99 HEADING "TOTAL(M)"
COLUMN Tot_Free      FORMAT 999G999D99 HEADING "FREE(M)"
COLUMN Pct_Free      FORMAT 999 HEADING "FREE %"
COLUMN Nu_Extents    FORMAT 999G999G999 HEADING "Extents Livres"
set feedback off pages 999 trims on 

      SELECT a.tablespace_name                                           Tsname
           , round(SUM(a.tot_use)/1048576,2)                             Tot_Size
           , round(SUM(a.sumb)/1048576,2)                                Tot_Free
           , trunc((SUM(a.tot_use)-SUM(a.sumb))*100/sum(a.tot_use),2)    Pct_Use_Aloc
           , round((SUM(a.sumb)/1048576 )/ (next_extent/1024/1024),2)    Nu_Extents
           , round(sum(a.max_bytes)/1048576,2)                           max_bytes
           , trunc((SUM(a.tot_use)-SUM(a.sumb))*100/sum(a.max_bytes),2)  Pct_Use_Def
        FROM (SELECT tablespace_name
                   , 0 tot_use
                   , SUM(bytes) sumb
                   , MAX(bytes) largest
                   , 0 max_bytes
                   , COUNT(*) chunks
                FROM dba_free_space a
               GROUP BY tablespace_name
                UNION
              SELECT tablespace_name
                   , SUM(bytes) tot_use
                   , 0
                   , 0
                   , sum(nvl(maxbytes,0) + nvl(decode(maxbytes, 0,bytes),0)) max_bytes
                   , 0
                FROM dba_data_files
               GROUP BY tablespace_name) a
          , dba_tablespaces b
      WHERE b.tablespace_name = a.tablespace_name
        AND b.tablespace_name NOT IN ('TEMP', 'ROLLBACK')
      GROUP BY a.tablespace_name, next_extent
    having ((trunc((SUM(a.tot_use)-SUM(a.sumb))*100/sum(a.tot_use),2) > 90)
          or (round((SUM(a.sumb)/1048576 )/ (next_extent/1024/1024),2) < 10))
      Order by Pct_Use_Aloc desc, nu_extents desc
/

set feedback ON
undefine tablespace_name
