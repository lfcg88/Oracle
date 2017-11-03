/* Criar Diretorios*/
mkdir /usr/apps/datafiles
sqlplus 
create directory DIR as '/usr/apps/datafiles'

/*Dar grant de leitura e escrita para o schema no diretorio*/
grant read,write on directory DIR to pousada

/*Dar grant as devidas roles ao schema*/
grant exp_full_database, imp_full_database to pousada

/* Caso haja a necessidade de consultar diretorios criados podemos executar os seguintes comandos */

desc dba_directories

select * from dba_directories;

/*Exportar o banco completo*/
expdp pousada/pousadapwd full=y directory=DIR dumpfile=db_pousada.dmp 
logfile=db_pousada.log

/*parametros mais importantes*/

help=y--descrição de todos os parametros, expdp help=y

full=y --backup do banco completo

tables=<tabela> --backup de uma tabela especifica

schemas=<schema(default)> --backup do schema

tablespaces=<tablespace> --backup das tabelas contidas em um conjunto 
--especificado de tablespaces

transport_tablespace=<tablespace> --backup dos metadados para as tabelas (e seus
--objetos dependentes) de uma especifica tablespace

directory=<diretorio> --especifica o diretorio criado anteriormente

content=<all, metadata_only, data_only> --define o que vai ser exportado

estimate_only=<n, y>--serve para estimar o tamanho que tera o backup
--ex: expdp pousada/pousadapwd estimate_only=y nologfile=y

exclude=<tipo_objeto:'nome'>--exclui um tipo de objeto do backup o nome é opcional
--ex: 
--exclude=view,function,package
--exclude=schema:"='hr'"--exclui o schema

include=<tipo_objeto:'nome'>--exporta somente objetos que foram incluidos e grants etc
--ex:
--expdp pousada/pousada  dumpfile=include.dmp directory=dir nologfile=y 
--include=TABLE:"IN ('usuario', 'cliente')" include=procedure

FLASHBACK_TIME="TO_TIMESTAMP('25-08-2003 14:35:00', 'DD-MM-YYYY HH24:MI:SS')"
--exporta os dados mais próximo do tempo especificado

job_name=<nome>--especifica um nome para o serviço

logfile=<nome.log>--gera um arquivo de log da operação

nologfile=y--não gera um arquivo de log da operação 

parallel=<1, numero>--escreve ate o numero de arquivos no dumpfile=nome%u.dmp

parfile=<nome.par>--antes de especificar deve-se fazer
--um arquivo para substituir os parametros
--ex expdp pousada/pousadapwd parfile=nome.par

query=<tabela:"'where id = 10'">--restrigir dados de uma tabela, caso seja
--em um esquema pegaria todos os dados de todas as tabelas mas na <tabela>
--recuperaria dados que atendem ao where

transport_full_check=<y,n>--é usado somente com transport_tablespace
--verifica por exemplo se um index está sendo transportado com uma tabela

version=<compatible, latest, nome_da_version>--especifica para que versão os objetos
--serão exportados

/*Para acessar o modo interativo*/
ctrl+c
stop_job=immediate
expdp attach=<nome_job>
continue_cliente