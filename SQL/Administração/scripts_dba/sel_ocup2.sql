/************************************************************************/
/*  Lista espaco total e espaco livre de cada tablespace por data file  */
/************************************************************************/

set feed off
break on t1_tbspc        
column t1_fname  heading "N_DATA_FILE"      format a45
column t1_tbspc  heading "TBS" format a15
column t1_fileid heading "ID"                     format 99 
column t2_bytes  heading " LIVRE"       format 9999.999
column t1_bytes  heading "TAMANHO"       format 9999.999
column pct_free  heading "LIVRE_P"              format 9999.9   
column t1_status heading "STATUS"                 format a15   


SELECT TBS, SUM(TAMANHO) Tam, SUM(LIVRE), SUM(LIVRE) / SUM(TAMANHO) * 100
FROM analyze.monitora_tablespaces2 
GROUP BY TBS;


create table analyze.monitora_tablespaces2 storage(initial 10M next 1M pctincrease 0) 
 tablespace monitora as 
(
select 'APPI' SITE			,
       'PRODUCAO'	DATABASE	,
       SYSDATE        	DATA ,       
       t1.file_name                         FILE_NAME,
       t1.tablespace_name                   TBS,
       t1.file_id                           FILE_ID,
       max(t1.bytes) / 1048576              TAMANHO,
       sum(t2.bytes) / 1048576              LIVRE,
       sum(t2.bytes) / max(t1.bytes) * 100  LIVRE_P,
       substr(t1.status,1,6)                STATUS
  from sys.dba_data_files t1,
       sys.dba_free_space t2
       where t1.tablespace_name = t2.tablespace_name (+) and
                     t1.file_id = t2.file_id (+)
             group by t1.file_name,
                      t1.tablespace_name,
                      t1.file_id,
                      status
)
/


