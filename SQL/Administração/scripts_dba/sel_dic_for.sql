/* Lista tabelas dos fornecedores cadastradas no nosso dicionario interno */

set linesize 80
set pagesize 66
set pause off

column nom_tabela      format a25 heading "Tabela"
column fase_utilizacao format a15 heading "Fase utilizacao"
column tratam_implant  format a10 heading "Tratamento"
column txt_comentario  format a26 heading "Comentario"

select nom_tabela,
       decode(cod_fase_utilizacao,'1','1a fase','2','2a fase','N','sem uso','?','em duvida') fase_utilizacao,
       decode(cod_tratam_implant,'C','Carga','I','Interface') tratam_implant,
       txt_comentario
from dic_fornec
where nom_fornecedor = '&fornecedor' and
      cod_fase_utilizacao like '&fase_utilizacao'
order by cod_fase_utilizacao, nom_tabela
/
