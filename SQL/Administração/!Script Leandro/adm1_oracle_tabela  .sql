--A tablespace onde a tabela reside, O tamanho da extensão, o numero do arquivo 
--no qual a extensão esta e em qual bloco ele começa
   
select tablespace_name, extent_id, bytes, file_id, block_id from dba_extents where owner='BDMARCASN'  and segment_name ='MRC_PROC_FIGUR_INC' 
--identifique o arquivo pelo nome.
select name from v$datafile where file#=5
select block_size * 1214592 from dba_tablespaces where tablespace_name='TBS_MARCAS';