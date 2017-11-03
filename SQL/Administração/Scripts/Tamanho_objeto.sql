Prompt #############################################################
Prompt #                                                           #
Prompt #             Lista o tamanho do objeto                     #
Prompt #                                                           #
Prompt #############################################################

set verify off
clear columns
Accept wrk_nome_obj prompt "Digite o owner.nome do objeto : "

col objeto format a40

select owner||'.'|| segment_name objeto, SEGMENT_TYPE
     , sum(bytes)/1024/1024 "Tamanho (Mb)"
     , TABLESPACE_NAME "Tablespace" 
  from DBA_segments
where segment_name = upper(substr('&wrk_nome_obj',instr('&wrk_nome_obj','.',1,1)+1))
  and owner = upper(substr('&wrk_nome_obj',1,instr('&wrk_nome_obj','.',1,1)-1))
group  by owner, segment_name, SEGMENT_TYPE, TABLESPACE_NAME
ORDER BY "Tamanho (Mb)"
/

set verify on
clear columns
undefine objeto 
