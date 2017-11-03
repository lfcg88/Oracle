Prompt ###################################################
Prompt #                                                 #
Prompt #      Informações dos Segmentos de Rollback      #
Prompt #      Lista as informações dos segmentos de      #
Prompt #                      rollback.                  #
Prompt #                                                 #
Prompt ###################################################


SET ECHO off 
REM NAME:   TFSRBNFO.SQL 
REM USAGE:"@path/tfsrbnfo" 
REM -------------------------------------------------------------------------- 
REM REQUIREMENTS: 
REM    SELECT n V$rollname, V$rollstat, & sys.dba_rollback_segs 
REM -------------------------------------------------------------------------- 
REM PURPOSE: 
REM    To give detailed information about the rollback segments in a database 
REM ------------------------------------------------------------------------- 
REM Main text of script follows: 
 
 
set feed off 
set pause off 
col nm format a7 heading 'Name' trunc 
col ex format 999 headin 'NrEx' 
col rs format a7 heading 'Size' 
col init format 999,999,999 heading 'Init' 
col next format 999,999,999 heading 'Next' 
col mi format 999,999 heading 'MinE' 
col ma format 999,999 heading 'MaxE' 
col op format 99,999,999 heading 'Opt size' 
col pct format 990 heading 'PctI' 
col st format a4 heading 'Stat' 
col sn format a15 heading 'Segm Name' 
col ts format a12 heading 'In TabSpace' 
col fn format a45 heading 'File containing header of rbs' 
col ow format a4  heading 'Ownr' 
 
prompt All Rollback Segments 
select segment_name sn, decode(owner,'PUBLIC','Publ','Priv') ow, 
       tablespace_name ts, name fn 
from sys.dba_rollback_segs d, v$datafile f 
where d.file_id = f.file#; 
 
prompt 
prompt Online Rollback Segments: 
select d.segment_name nm, 
       s.extents ex, 
       (s.rssize/1024)||'K' rs, 
       d.initial_extent init, 
       d.next_extent next, 
   d.pct_increase pct, 
       d.min_extents mi, 
       d.max_extents ma, 
optsize op, 
       decode(d.status,'ONLINE','OnL','OFFLINE','OffL') st 
from v$rollname n, v$rollstat s, sys.dba_rollback_segs d 
where n.usn = s.usn 
and   d.segment_name = n.name(+); 
set feed on 
/* End of eval_rbs.sql */ 
 
clear columns
