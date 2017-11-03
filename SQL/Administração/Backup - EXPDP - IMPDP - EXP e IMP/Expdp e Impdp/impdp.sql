impdp pousada/pousadapwp directory=dir dumpfile=nome.dmp nologfile=y
tables=tabela full=y ... 

--paremtros mais importantes
help=<y>--descrição dos parametros que podem ser utilizados
 
full=<y,n>--importação completa do banco

schemas=<nome_schema>--importação de um schema

tables=<nome_tabela>--importação de uma ou mais tabelas, caso queira fazer o restore alterando o schema basta usar o remap_schema.

tablespaces=<tablespace> --importação das tabelas contidas em um conjunto 
--especificado de tablespaces

content=<all, data_only, metadata_only>--especifica o que vai ser importado

directory=<nome_diretorio>--diretorio criado anteriormente

dumpfile=<nome.dmp>--nome do arquivo que sera importado

exclude=<objeto>--exclui objetos da importação
--ex exclude=function

include=<objeto>--inclui somente os objetos especificados, não sendo usado caso queira fazer um remap_schema (usar o "tables")
--ex include=tables:"IN ('tablea1', 'tabela2')"

job_name=<nome_job>--especifica um nome para o serviço de impotação

logfile=<nome.log>--especifica um arquivo de log para o processo de importação

nologfile=<n, y>--especifica que não havera um arquivo de log

network _link=<nome_do_banco>--habilita uma importação pela rede

parallel=<1, numero>--copia ate o numero de arquivos no dumpfile=nome%u.dmp

parfile=<nome>--especifica um arquivo .par de onde os parametros irão ser copiados

query=<tabela:"'where id = 10'">--restrigir dados de uma tabela, caso seja
--em um esquema pegaria todos os dados de todas as tabelas mas na <tabela>
--recuperaria dados que atendem ao where

remap_datafile=<fonte.nome:alvo.nome>--importa um datafile para um banco com outro nome

remap_schema=<schema.fonte:schema.alvo>--altera o owner dos objetos do owner fonte para o owner alvo,
--sendo que, no caso das triggers, o corpo do script não altera, fazendo com que as triggers não sejam compiladas.

remap_tablespace=<tablespace.fonte:tablespace.alvo>--copia todos os dados de uma 
--tablespace fonte criando uma tablespace fonte

sqlfile=<nome.>--ler um arquivo de expdp e escreve os comandos sql no arquivo
--nome.sql, que pode ser executado em 2º momento

table_exist_action=<skip, append, truncate, replace>--especifica qual ação tomar quando
--uma tabela que esta sendo imporatda ja existir
--[skip]: deixa a tabela como está e se move para o próximo objeto. Esta não é uma 
--opção válida se o parâmetro de conteúdo é definido como DATA_ONLY
--[append]: insere as linhas e deixa as linhas que ja eistem sem serem modificadas
--[truncate]: deleta todas as linhas e então insere novas linhas
--[replace]: dropa tabelas existentes e então cria as tabelas e insere as linhas
-- não pode ser utilizada com o parametro data_only

transport_full_check=<y,n>--é usado somente com transport_tablespace
--verifica por exemplo se um index está sendo transportado com uma tabela

version=<compatible, latest, nome_da_version>--especifica para que versão os objetos
--serão importados