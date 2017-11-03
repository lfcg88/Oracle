ALTER SYSTEM SET  db_name = TST1 SCOPE = SPFILE;  -- Must match the production database. 
ALTER SYSTEM SET INSTANCE_NAME = TST2 SCOPE = SPFILE; -- UNIQUE IDENTIFIER
ALTER SYSTEM SET lock_name_space = TST1 SCOPE = SPFILE;  -- Used when the standby or clone have the same  
                             --   name as the production database being copied. 
ALTER SYSTEM SET  service_names = TST2 SCOPE = SPFILE;     -- Specifies the service names supported by the instance. 
ALTER SYSTEM SET  fal_client = TST2 SCOPE = SPFILE;    -- Specifies the service name resolved from the  
  			 --    remote host to fetch archive logs to local. 
ALTER SYSTEM SET  fal_server = TST1 SCOPE = SPFILE;	    -- Specifies the service name resolved on the  
			  --   local host to request archive logs from remote. 
ALTER SYSTEM SET  db_file_name_convert     = ('C:\ORACLE\ORADATA\TST1','C:\ORACLE\ORADATA\TST2') SCOPE = SPFILE;
ALTER SYSTEM SET  LOG_file_name_convert     = ('C:\ORACLE\ORADATA\TST1','C:\ORACLE\ORADATA\TST2') SCOPE = SPFILE;
