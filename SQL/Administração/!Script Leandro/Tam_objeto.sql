Prompt #############################################################
Prompt #                                                           #
Prompt #             Lista o tamanho do objeto                     #
Prompt #                                                           #
Prompt #############################################################

set verify off
clear columns
Accept objeto prompt "Digite o nome do objeto : "

col objeto format a40

select owner||'.'|| segment_name objeto, SEGMENT_TYPE
     , sum(bytes)/1024/1024 "Tamanho (Mb)" 
  from DBA_segments
where segment_name like upper('%&objeto%')
group  by owner, segment_name, SEGMENT_TYPE
ORDER BY "Tamanho (Mb)"
/

select segment_name , SEGMENT_TYPE
     , sum(bytes)/1024/1024 "Tamanho (Mb)" 
  from user_segments
where segment_name like upper('%&objeto%')
group  by segment_name, SEGMENT_TYPE
/

set verify on
clear columns
undefine objeto 
