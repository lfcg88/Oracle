Prompt #############################################################
Prompt #                                                           #
Prompt #             Habilita/ Desabilita Trigger                  #
Prompt #                                                           #
Prompt #############################################################


set verify off
undefine trigger_name

Accept trigger_name prompt "Digite o nome da Trigger : "
Accept status       prompt "Digite o status disable/enable : "

alter trigger &trigger_name &status;

undefine trigger_name
undefine status
set verify on
