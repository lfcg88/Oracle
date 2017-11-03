Prompt ###################################################
Prompt #                                                 #
Prompt #        Compara os objetos  de um banco          #
Prompt #     com os objetos do mesmo owner no TL01       #
Prompt #              DEVE SER RODADA NO BANCO A         #
Prompt #               SER COMPARADO COM O TL01          #
Prompt #                                                 #
Prompt ###################################################


SET LINES 1000
COL owner FORMAT A15
COL object_name FORMAT A32
COL Falta FORMAT A32
COL CONSTRAINT_TYPE FORMAT A5
SET VERIFY OFF

Accept owner Prompt 'Digite o nome do Owner:'

select owner
     , object_name
     , object_type  Falta
     , 'OUTRO'  constraint_type
  from dba_objects@tl01
 where owner =  UPPER('&&owner')
--   and object_type in ('DATABASE LINK','FUNCTION','INDEX','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','SYNONYM','TRIGGER','VIEW','TABLE')
   and object_name not like '%$%'
minus
select owner
     , object_name
     , object_type  Falta
     , 'OUTRO'  constraint_type
  from dba_objects
 where owner =  UPPER('&&owner')
--   and object_type in ('DATABASE LINK','FUNCTION','INDEX','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','SYNONYM','TRIGGER','VIEW','TABLE')
   and object_name not like '%$%'
union ALL
select owner
     , table_name 
     , constraint_name  Falta
     , constraint_type
  from dba_constraints@tl01
 where owner =  UPPER('&&owner')
   and constraint_type in ('P','R','U')
minus
select owner
     , table_name 
     , constraint_name  Falta
     , constraint_type
  from dba_constraints
 where owner =  UPPER('&&owner')
   and constraint_type in ('P','R','U')
ORDER BY 1,3,2
/



SET VERIFY OFF
CLEAR COLUMNS
undefine owner
