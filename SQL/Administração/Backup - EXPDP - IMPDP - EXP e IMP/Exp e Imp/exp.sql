--Exp-- 
--dar grant as roles exp_full_database e imp_full_database
--entrar no diretorio onde vão ficar os arquivos ou especificar no file todo o diretorio
--ex file=/u01/app/oracle/oracle/backup/cliente.dmp

cd /u01/app/oracle/oracle/backup
--exportando tabelas
exp pousada/pousadapwd tables=cliente file=cliente.dmp

--exportando schemas
exp pousada/pousadapwd owner=hr file=hr.dmp

--exportando o banco completo
exp pousada/pousadapwd full=y file=full.dmp

--parametros/modos-- 
full=<y,n> 
transport_tablespace=<tablespace(s)> 
owner=<schema(s)>
tables=<tabela(s)>

--parametros mais importantes--

consistent=<y,n> --garante que ninguem ira atualizar os dados durante a exportação

constraints=<y,n> --especifica se ira ou não exportar constraints para a(s) tabelas

direct=<n,y> -- especifica o uso do diretorio direto de exportação

feedback=<integer> --retorna informações quando o numero especificado de linhas é atingido

file=nome.dmp --nome do arquivo de exportação 

filesize=<integer,kb,mb,gb> --tamanho maximo do arquivo.dmp

FLASHBACK_SCN=<integer> --pega os dados mais próximo do scn(system change number) especificado

FLASHBACK_TIME="TO_TIMESTAMP('25-08-2003 14:35:00', 'DD-MM-YYYY HH24:MI:SS')"
--pega os dados mais próximo do tempo especificado

grants=<y,n>--especifica se ira ou não exportar grants de objetos

help=<none,y> --ajuda

indexes=<y,n>--especifica se ira ou não exportar indexes

triggers=<y,n>--especifica se ira ou não exportar triggers

log=<none,nome.log>--detalhes da operação

parfile=<none,nome.par>--antes de especificar deve-se fazer
--um arquivo para substituir os parametros
--ex exp pousada/pousadapwd parfile=nome.par

query=<"'where id = 10'">--restrigir dados de uma ou mais tabelas que se encontram
--especificadas no parametro TABLES
--ex: exp scott/tiger TABLES=emp QUERY=\"WHERE job=\'SALESMAN\' and sal \<1600\"

rows=<y,n>--especifica se ira ou não copiar as linhas da tabela

transport_tablespace=<n,y> --backup dos metadados para as tabelas (e seus
--objetos dependentes) de uma especifica tablespace

--exemplos de exportação--

--full
exp SYSTEM/password FULL=y FILE=dba.dmp GRANTS=y ROWS=y

--schema
exp scott/tiger FILE=scott.dmp OWNER=scott GRANTS=y ROWS=y COMPRESS=y

--tabelas de usuarios diferentes
exp SYSTEM/password FILE=expdat.dmp TABLES=(scott.emp,blake.dept) GRANTS=y INDEXES=y

