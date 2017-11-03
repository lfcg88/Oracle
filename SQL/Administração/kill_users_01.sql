select 'alter system kill session ''' || sid || ',' || SERIAL# || '''  IMMEDIATE;' from v$session where username NOT IN ('SYS','SYSTEM',)
                                                                                                                                        *
ERROR at line 1:
ORA-00936: missing expression 



exit                                                                                                                                                  
