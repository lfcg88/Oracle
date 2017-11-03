Prompt #############################################################
Prompt #                                                           #
Prompt #             Lista script disbale/ enable constraint       #
Prompt #                                                           #
Prompt #############################################################

set feedback off
set heading off
set verify off
set lines 300


accept p_owner prompt "Digite o Owner da Tabela: "
accept p_table  prompt "Digite o nome da  Tabela: "
accept opcao  prompt     "Escolha entre Disable ou Enable: "

select 'ALTER TABLE '||OWNER||'.'||TABLE_NAME
       || ' '||'&opcao'||' CONSTRAIMT '||CONSTRAINT_NAME ||';'
  FROM ALL_CONSTRAINTS
 WHERE CONSTRAINT_TYPE = 'R'
   AND OWNER = '&P_OWNER'
   AND TABLE_NAME = '&P_TABLE'
/

undefine p_name
UNDEFINE p_owner
UNDEFINE OPCAO
set feedback on
set heading on
set verify on
set feedback oN
set heading oN
set verify oN
set lines 100


