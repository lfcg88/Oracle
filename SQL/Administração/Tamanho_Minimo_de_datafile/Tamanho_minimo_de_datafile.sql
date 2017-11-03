/* Formatted on 2005/03/15 18:37 (Formatter Plus v4.8.5) */
SELECT SUM (BYTES)
  FROM dba_free_space
 WHERE tablespace_name = :tsn
   AND file_id = :fid
   AND block_id >=
          NVL ((SELECT (block_id + (BYTES / 8192))
                  FROM dba_extents
                 WHERE block_id =
                              (SELECT MAX (block_id)
                                 FROM dba_extents
                                WHERE file_id = :fid AND tablespace_name =
                                                                          :tsn)
                   AND file_id = :fid
                   AND tablespace_name = :tsn),
               0
              )