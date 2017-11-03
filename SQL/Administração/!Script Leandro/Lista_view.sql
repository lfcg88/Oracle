Prompt #############################################################
Prompt #                                                           #
Prompt #                   Lista corpo da view                     #
Prompt #                                                           #
Prompt #############################################################

set long 2000000
set verify off
undefine nome_tabela
col view_name format a20


Accept nome_view prompt "Digite o nome da View : "

select text "Corpo da View"
     , owner||'.'||VIEW_NAME "Owner"
  from all_views
 where view_name like upper('%&nome_view%')
/

undefine nome_view
set verify on
clear columns
