set feed off
set verify off
set linesize 200
set pages 500

col Total format a15;
col Usado format a15;
col Livre format a15;
col Acrescentar format a15;

whenever sqlerror exit 1;
whenever oserror exit 2;

spool &1;

SELECT  Total.name Tablespace,
        ROUND(Total.espaco,1) || ' Mb' Total,
	ROUND((total.espaco-livre.espaco),1 ) || ' Mb' Usado,
	ROUND(livre.espaco,1) || ' Mb' Livre--,
--	ROUND(((((total.espaco-livre.espaco)/(100-(livre.espaco)*100/Total.espaco)) *16) -livre.espaco),1) || ' Mb'  Acrescentar
  FROM
       (SELECT tablespace_name,
               sum(bytes/1024/1024) espaco
	  FROM sys.dba_free_space
	 GROUP BY tablespace_name
       ) Livre,
       (SELECT b.name,
               sum(a.bytes/1024/1024) espaco,
               c.autoextensible
	  FROM sys.v_$datafile a,
	       sys.v_$tablespace B,
               dba_data_files c
	 WHERE a.ts# = b.ts#
	   AND a.file# = c.file_id
	 GROUP BY b.name, c.autoextensible
       ) Total
 WHERE Livre.Tablespace_name = Total.name
   --AND ROUND(((livre.espaco) *100/Total.espaco),0) <20
   --AND Total.autoextensible = 'NO'
 ORDER BY 1;

spool off;

exit;

