Prompt #############################################################
Prompt #                                                           #
Prompt #              Adicionar coluna numa tabela                 #
Prompt # Altera estrutura acrescentando mais uma coluna na tabela. #
Prompt #                                                           #
Prompt #############################################################

Accept Nome_tabela prompt "Digite o nome da tabela : "
Accept Nome_coluna prompt "Digite o nome da Coluna : "
Accept Tipo_da_coluna prompt "Digite o tipo da coluna : "

alter table &Nome_tabela add &Nome_coluna &Tipo_da_coluna
/
