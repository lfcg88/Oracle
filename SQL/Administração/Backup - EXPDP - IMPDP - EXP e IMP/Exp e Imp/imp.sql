--imp 

--parametros/modos-- 
full=<y,n> 
transport_tablespace=<tablespace(s)> 
fromuser=<schema(s)>
tables=<tabela(s)>

--parametros mais importantes-- 

commit=<n,y>--se estiver especificado para y, a cada linha da tabela importada será
--efetuado um commit, especificado como n(default) o commit so sera efetuado ao fim 
--do import naquela tabela

compile=<y,n>--especifica se o import vai compilar o não cada função, procedure, packages
--no momento da sua criação

constraints=<y,n> --especifica se ira ou não importar constraints para a(s) tabelas

feedback=<integer> --retorna informações quando o numero especificado de linhas é atingido

file=nome.dmp --nome do arquivo de onde será importadom os dados e objetos 

filesize=<integer,kb,mb,gb> --tamanho maximo do arquivo.dmp

grants=<y,n>--especifica se ira ou não importar grants de objetos

indexes=<y,n>--especifica se ira ou não importar indexes

indexfile=<none>--especifica um arquivo para receber os comandos para criação do index,
--caso queira criar os indices mais tarde

help=<none,y> --ajuda

ignore=<n,y>--caso queira importar dados para uma tabela que ja esteja criada e necessario
--especificar esse parametro para y caso o contrario ocorrerá um erro, pois a tabela ja 
--existe

log=<none,nome.log>--detalhes da operação

parfile=<none,nome.par>--antes de especificar deve-se fazer
--um arquivo para substituir os parametros
--ex exp pousada/pousadapwd parfile=nome.par

rows=<y,n>--especifica se ira ou não copiar as linhas da tabela

show=<n,y>--apenas mostra os comandos que serão executados no import mas sem executar

statistics=<always,none,safe,recalculate>--Especifica o que é feito com as estatísticas
--do banco de dados otimizado em tempo de importação.

touser=<usuario>--para copiar um schema para outro, o schema touser deve existir
--ex imp marcio/marciopwd file=pousada.dmp fromuser=pousada touser=teste tables=cliente

--exemplos de importação--

--tabelas de um schema especifico
imp SYSTEM/password FILE=dba.dmp FROMUSER=scott TABLES=(dept,emp)

--tabelas de um schema para outro
imp SYSTEM/password FROMUSER=blake TOUSER=scott FILE=blake.dmp TABLES=(unit,manager)

