
alter tablespace CWMLITE begin backup;                                                                                                                
alter tablespace DRSYS begin backup;                                                                                                                  
alter tablespace EXAMPLE begin backup;                                                                                                                
alter tablespace INDX begin backup;                                                                                                                   
alter tablespace ODM begin backup;                                                                                                                    
alter tablespace SYSTEM begin backup;                                                                                                                 
alter tablespace TOOLS begin backup;                                                                                                                  
alter tablespace UNDOTBS1 begin backup;                                                                                                               
alter tablespace USERS begin backup;                                                                                                                  
alter tablespace XDB begin backup;                                                                                                                    
alter tablespace TEMP begin backup;                                                                                                                   
alter tablespace TBS_DATA_TEMP_SAFIT01 begin backup;                                                                                                  
alter tablespace TBS_DATA_TEMP_SAFIT02 begin backup;                                                                                                  

alter tablespace TBS_RECUPERA_TEMP begin backup;                                                                                                      
alter tablespace TBS_SAPR_DATA_01 begin backup;                                                                                                       
alter tablespace TBS_SAPR_IDX_01 begin backup;                                                                                                        
alter tablespace TBS_SCP_DATA_01 begin backup;                                                                                                        
alter tablespace TBS_SCP_IDX_01 begin backup;                                                                                                         
alter tablespace USR_TBS_01 begin backup;                                                                                                             
alter tablespace USR_TBS_02 begin backup;                                                                                                             
alter tablespace TBS_DATA_PDM_01 begin backup;                                                                                                        
alter tablespace OEM_REPOSITORY begin backup;                                                                                                         
alter tablespace TBS_DATA_REPLICA_PROD begin backup;                                                                                                  
alter tablespace TBS_DATA_PERFSTAT begin backup;                                                                                                      
alter tablespace TBS_DATA_REPLC_BDUP_PBK_01 begin backup;                                                                                             
alter tablespace GIS_DATA_BUSS01 begin backup;                                                                                                        

alter tablespace GIS_DATA_GEOM01 begin backup;                                                                                                        
alter tablespace GIS_DATA_IDXS01 begin backup;                                                                                                        
alter tablespace GIS_DATA_RASTER01 begin backup;                                                                                                      
alter tablespace MAPS begin backup;                                                                                                                   
alter tablespace SDE begin backup;                                                                                                                    

host cp /u01/app/oracle/oradata/orcl/system01.dbf /pub/bkp_oracle/backup_online/                                                                      
host cp /u01/app/oracle/oradata/orcl/undotbs01.dbf /pub/bkp_oracle/backup_online/                                                                     
host cp /u01/app/oracle/oradata/orcl/cwmlite01.dbf /pub/bkp_oracle/backup_online/                                                                     
host cp /u01/app/oracle/oradata/orcl/drsys01.dbf /pub/bkp_oracle/backup_online/                                                                       
host cp /u01/app/oracle/oradata/orcl/example01.dbf /pub/bkp_oracle/backup_online/                                                                     
host cp /u01/app/oracle/oradata/orcl/indx01.dbf /pub/bkp_oracle/backup_online/                                                                        
host cp /u01/app/oracle/oradata/orcl/odm01.dbf /pub/bkp_oracle/backup_online/                                                                         
host cp /u01/app/oracle/oradata/orcl/tools01.dbf /pub/bkp_oracle/backup_online/                                                                       
host cp /u01/app/oracle/oradata/orcl/users01.dbf /pub/bkp_oracle/backup_online/                                                                       
host cp /u01/app/oracle/oradata/orcl/xdb01.dbf /pub/bkp_oracle/backup_online/                                                                         
host cp /u01/app/oracle/oradata/orcl/TBS_DATA_TEMP_SAFIT01.dbf /pub/bkp_oracle/backup_online/                                                         
host cp /u01/app/oracle/oradata/orcl/TBS_DATA_TEMP_SAFIT02.dbf /pub/bkp_oracle/backup_online/                                                         
host cp /u01/app/oracle/oradata/orcl/TBS_RECUPERA_TEMP.dbf /pub/bkp_oracle/backup_online/                                                             

host cp /u01/app/oracle/oradata/orcl/TBS_SAPR_DATA_01.dbf /pub/bkp_oracle/backup_online/                                                              
host cp /u01/app/oracle/oradata/orcl/TBS_SAPR_IDX_01.dbf /pub/bkp_oracle/backup_online/                                                               
host cp /u01/app/oracle/oradata/orcl/TBS_SCP_DATA_01.dbf /pub/bkp_oracle/backup_online/                                                               
host cp /u01/app/oracle/oradata/orcl/TBS_SCP_IDX_01.dbf /pub/bkp_oracle/backup_online/                                                                
host cp /u01/app/oracle/oradata/orcl/USR_TBS_01.dbf /pub/bkp_oracle/backup_online/                                                                    
host cp /u01/app/oracle/oradata/orcl/USR_TBS_02.dbf /pub/bkp_oracle/backup_online/                                                                    
host cp /u01/app/oracle/oradata/orcl/TBS_DATA_PDM_01.dbf /pub/bkp_oracle/backup_online/                                                               
host cp /u01/app/oracle/oradata/orcl/oem_repository.dbf /pub/bkp_oracle/backup_online/                                                                
host cp /u01/app/oracle/oradata/orcl/TBS_DATA_REPLICA_PROD.dbf /pub/bkp_oracle/backup_online/                                                         
host cp /u01/app/oracle/oradata/orcl/TBS_DATA_PERFSTAT1.dbf /pub/bkp_oracle/backup_online/                                                            
host cp /u01/app/oracle/oradata/orcl/TBS_DATA_REPLC_BDUP_PBK_01.dbf /pub/bkp_oracle/backup_online/                                                    
host cp /u01/app/oracle/oradata/orcl/GIS_DATA_BUSS01.dbf /pub/bkp_oracle/backup_online/                                                               
host cp /u01/app/oracle/oradata/orcl/GIS_DATA_GEOM01.dbf /pub/bkp_oracle/backup_online/                                                               

host cp /u01/app/oracle/oradata/orcl/GIS_DATA_IDXS01.dbf /pub/bkp_oracle/backup_online/                                                               
host cp /u01/app/oracle/oradata/orcl/GIS_DATA_RASTER01.dbf /pub/bkp_oracle/backup_online/                                                             
host cp /u01/app/oracle/oradata/orcl/MAPS.dbf /pub/bkp_oracle/backup_online/                                                                          
host cp /u01/app/oracle/oradata/orcl/SDE.dbf /pub/bkp_oracle/backup_online/                                                                           

alter tablespace CWMLITE end backup;                                                                                                                  
alter tablespace DRSYS end backup;                                                                                                                    
alter tablespace EXAMPLE end backup;                                                                                                                  
alter tablespace INDX end backup;                                                                                                                     
alter tablespace ODM end backup;                                                                                                                      
alter tablespace SYSTEM end backup;                                                                                                                   
alter tablespace TOOLS end backup;                                                                                                                    
alter tablespace UNDOTBS1 end backup;                                                                                                                 
alter tablespace USERS end backup;                                                                                                                    
alter tablespace XDB end backup;                                                                                                                      
alter tablespace TEMP end backup;                                                                                                                     
alter tablespace TBS_DATA_TEMP_SAFIT01 end backup;                                                                                                    
alter tablespace TBS_DATA_TEMP_SAFIT02 end backup;                                                                                                    

alter tablespace TBS_RECUPERA_TEMP end backup;                                                                                                        
alter tablespace TBS_SAPR_DATA_01 end backup;                                                                                                         
alter tablespace TBS_SAPR_IDX_01 end backup;                                                                                                          
alter tablespace TBS_SCP_DATA_01 end backup;                                                                                                          
alter tablespace TBS_SCP_IDX_01 end backup;                                                                                                           
alter tablespace USR_TBS_01 end backup;                                                                                                               
alter tablespace USR_TBS_02 end backup;                                                                                                               
alter tablespace TBS_DATA_PDM_01 end backup;                                                                                                          
alter tablespace OEM_REPOSITORY end backup;                                                                                                           
alter tablespace TBS_DATA_REPLICA_PROD end backup;                                                                                                    
alter tablespace TBS_DATA_PERFSTAT end backup;                                                                                                        
alter tablespace TBS_DATA_REPLC_BDUP_PBK_01 end backup;                                                                                               
alter tablespace GIS_DATA_BUSS01 end backup;                                                                                                          

alter tablespace GIS_DATA_GEOM01 end backup;                                                                                                          
alter tablespace GIS_DATA_IDXS01 end backup;                                                                                                          
alter tablespace GIS_DATA_RASTER01 end backup;                                                                                                        
alter tablespace MAPS end backup;                                                                                                                     
alter tablespace SDE end backup;                                                                                                                      

exit                                                                                                                                                  
