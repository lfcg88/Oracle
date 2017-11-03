


Prompt ###############################################                                                    
Prompt #                  Grants                                  
Prompt #                BASES                          
Prompt ###############################################                                                                        



ACCEPT SENHA CHAR PROMPT 'Digite a senha do SYSTEM:' HIDE
SET LINESIZE 900
SET PAGESIZE 1000
COLUMN WHAT FORMAT a100
COLUMN NLS_ENV FORMAT a250
COLUMN INTERVAL FORMAT a50
COLUMN MISC_ENV FORMAT a20
COLUMN LOG_USER FORMAT a10                      
COLUMN PRIV_USER FORMAT a10
COLUMN SCHEMA_USER FORMAT a10



 


conn system/&senha@bhd1
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;




conn system/&senha@dftpux01
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;



conn system/&senha@fzd0
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;




conn system/&senha@fld0
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;



conn system/&senha@ped0
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;




conn system/&senha@rsd0
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;





conn system/&senha@rjd3
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;



conn system/&senha@spd1
SET SERVEROUTPUT ON

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;


conn system/&senha@bad0

grant SIA_GERENTE_OPERACAO to  ALIBORIO;
grant SIA_GERENTE_AEROPORTO to  ALIBORIO;
grant SIA_IMPORTACAO to  ALIBORIO;
grant SIA_OTM to  ALIBORIO;
grant SIA_ADM_RESSUP_FILIAL to  ALIBORIO;



spool off






