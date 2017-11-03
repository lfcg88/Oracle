
                                                                                                     
alter tablespace OEM_REPOSITORY begin backup;                                                       
host cp /u01/app/oracle/oradata/orcl/oem_repository.dbf /pub/bkp_oracle/backup_online/                                                                
alter tablespace OEM_REPOSITORY end backup;                                                                                                           

exit                                                                                                                                                  
