set linesize 300;

prompt Para as tarefas a seguir, entregue consulta e resultado.
prompt 
prompt 2) Mostre nomes de instrutores, c�digos de turma e Arrecada��oTotal do instrutor na turma (preco_hora_instrutor*carga_horaria). Resultado � composto por 20 linhas
prompt 
prompt select i.nome_instrutor "Nome"
prompt     , t.cod_turma "CodTurma"
prompt     , (t.preco_hora_instrutor * c.carga_horaria) "Arrecada��oTotal"
prompt  from instrutores i
prompt  join turmas t on t.cod_instrutor = i.cod_instrutor
prompt  join cursos c on c.cod_curso     = t.cod_curso
prompt /

select i.nome_instrutor "Nome"
     , t.cod_turma "CodTurma"
     , (t.preco_hora_instrutor * c.carga_horaria) "Arrecada��oTotal"
  from instrutores i
  join turmas t on t.cod_instrutor = i.cod_instrutor
  join cursos c on c.cod_curso     = t.cod_curso
/


prompt 3) Explique por que M�nica Silveira Capela nada arrecadou na turma 4
prompt 
prompt Por que a turma 4 possui o curso 3 (Redes I) em que a M�nica daria aula porem na tabela de CURSOS a CARGA_HORARIA � NULA.
prompt 
prompt 4) Acrescente totais por instrutor e geral. Resultado ganhar� mais dez linhas
prompt 
prompt select nvl(i.nome_instrutor, 'Total') "Nome"
prompt      , t.cod_turma "CodTurma"
prompt      , sum(nvl((t.preco_hora_instrutor * c.carga_horaria),0)) Total
prompt   from instrutores i
prompt   join turmas t on t.cod_instrutor = i.cod_instrutor
prompt   join cursos c on c.cod_curso     = t.cod_curso
prompt  group by rollup (i.nome_instrutor, t.cod_turma)
prompt /

select nvl(i.nome_instrutor, 'Total') "Nome"
     , t.cod_turma "CodTurma"
     , sum(nvl((t.preco_hora_instrutor * c.carga_horaria),0)) Total
  from instrutores i
  join turmas t on t.cod_instrutor = i.cod_instrutor
  join cursos c on c.cod_curso     = t.cod_curso
  group by rollup (i.nome_instrutor, t.cod_turma)
/

prompt 5) Acrescente totais por turma. Resultado final ter� 50 linhas
prompt 
prompt select nvl(i.nome_instrutor, 'Total') "Nome"
prompt      , t.cod_turma "CodTurma"
prompt      , sum(nvl((t.preco_hora_instrutor * c.carga_horaria),0)) "Total"
prompt   from instrutores i
prompt   join turmas t on t.cod_instrutor = i.cod_instrutor
prompt   join cursos c on c.cod_curso     = t.cod_curso
prompt   group by cube (i.nome_instrutor, t.cod_turma)
prompt   order by 2
prompt /

select nvl(i.nome_instrutor, 'Total') "Nome"
     , t.cod_turma "CodTurma"
     , sum(nvl((t.preco_hora_instrutor * c.carga_horaria),0)) "Total"
  from instrutores i
  join turmas t on t.cod_instrutor = i.cod_instrutor
  join cursos c on c.cod_curso     = t.cod_curso
  group by cube (i.nome_instrutor, t.cod_turma)
  order by 2
/


prompt select nvl(i.nome_instrutor, 'Total') "Nome"
prompt      , t.cod_turma "CodTurma"
prompt      , sum(nvl((t.preco_hora_instrutor * c.carga_horaria),0)) Total
prompt   from instrutores i
prompt   join turmas t on t.cod_instrutor = i.cod_instrutor
prompt   join cursos c on c.cod_curso     = t.cod_curso
prompt   group by grouping sets ((t.cod_turma), (i.nome_instrutor), null)
prompt /

select nvl(i.nome_instrutor, 'Total') "Nome"
     , t.cod_turma "CodTurma"
     , sum(nvl((t.preco_hora_instrutor * c.carga_horaria),0)) Total
  from instrutores i
  join turmas t on t.cod_instrutor = i.cod_instrutor
  join cursos c on c.cod_curso     = t.cod_curso
  group by grouping sets ((t.cod_turma), (i.nome_instrutor), null)
/
