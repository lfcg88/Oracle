Prompt -- #############################################################
Prompt -- #                                                           #
Prompt -- #             Lista Pendencias de Réplica                   #
Prompt -- #                                                           #
Prompt -- #############################################################

set trimspool on
set feedback off
set heading off
set verify off
set lines 32767
set pages 0


SELECT t.deferred_tran_id,
       t.delivery_order,
       to_char(t.start_time, 'DD/MM/YYYY HH24:MI:SS')
  FROM deftrandest d, deftran t
 WHERE d.deferred_tran_id = t.deferred_tran_id
   AND d.delivery_order = t.delivery_order
 ORDER BY t.start_time;