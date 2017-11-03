--imp 

--parametros/modos-- 
full=<y,n> 
transport_tablespace=<tablespace(s)> 
fromuser=<schema(s)>
tables=<tabela(s)>

--parametros mais importantes-- 

commit=<n,y>--se estiver especificado para y, a cada linha da tabela importada ser�
--efetuado um commit, especificado como n(default) o commit so sera efetuado ao fim 
--do import naquela tabela

compile=<y,n>--especifica se o import vai compilar o n�o cada fun��o, procedure, packages
--no momento da sua cria��o

constraints=<y,n> --especifica se ira ou n�o importar constraints para a(s) tabelas

feedback=<integer> --retorna informa��es quando o numero especificado de linhas � atingido

file=nome.dmp --nome do arquivo de onde ser� importadom os dados e objetos 

filesize=<integer,kb,mb,gb> --tamanho maximo do arquivo.dmp

grants=<y,n>--especifica se ira ou n�o importar grants de objetos

indexes=<y,n>--especifica se ira ou n�o importar indexes

indexfile=<none>--especifica um arquivo para receber os comandos para cria��o do index,
--caso queira criar os indices mais tarde

help=<none,y> --ajuda

ignore=<n,y>--caso queira importar dados para uma tabela que ja esteja criada e necessario
--especificar esse parametro para y caso o contrario ocorrer� um erro, pois a tabela ja 
--existe

log=<none,nome.log>--detalhes da opera��o

parfile=<none,nome.par>--antes de especificar deve-se fazer
--um arquivo para substituir os parametros
--ex exp pousada/pousadapwd parfile=nome.par

rows=<y,n>--especifica se ira ou n�o copiar as linhas da tabela

show=<n,y>--apenas mostra os comandos que ser�o executados no import mas sem executar

statistics=<always,none,safe,recalculate>--Especifica o que � feito com as estat�sticas
--do banco de dados otimizado em tempo de importa��o.

touser=<usuario>--para copiar um schema para outro, o schema touser deve existir
--ex imp marcio/marciopwd file=pousada.dmp fromuser=pousada touser=teste tables=cliente

--exemplos de importa��o--

--tabelas de um schema especifico
imp SYSTEM/password FILE=dba.dmp FROMUSER=scott TABLES=(dept,emp)

--tabelas de um schema para outro
imp SYSTEM/password FROMUSER=blake TOUSER=scott FILE=blake.dmp TABLES=(unit,manager)

