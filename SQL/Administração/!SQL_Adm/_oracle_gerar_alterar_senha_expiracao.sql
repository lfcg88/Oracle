
SELECT 'ALTER USER ' || USERNAME || CHR(10)                              
        || ' IDENTIFIED BY VALUES ' || '''' || us.password || ''';'   
    FROM DBA_USERS U, SYS.USER$ US
   WHERE U.USERNAME = US.NAME
   AND U.ACCOUNT_STATUS LIKE '%EXPIRED%'
   AND U.USERNAME NOT LIKE 'USR\_%' ESCAPE '\'
   and username NOT IN ('APEX_030200',
   	 'APEX_PUBLIC_USER',
   	 'APPQOSSYS',
   	 'FLOWS_FILES',
   	 'MGMT_VIEW',
   	 'ORDDATA',
   	 'OWBSYS',
   	 'OWBSYS_AUDIT',
   	 'SPATIAL_CSW_ADMIN_USR',
   	 'SPATIAL_WFS_ADMIN_USR',
   	'SYS',                                 
                         'SYSTEM', 
                         'AUDIT_HIST',
                         'PERFSTAT',                                 
                         'DBSNMP',                                 
                         'AURORA$JIS$UTILITY$',                         
                         'OSE$HTTP$ADMIN',                             
                         'AURORA$ORB$UNAUTHENTICATED',                     
                         'ANONYMOUS',                             
                         'XDB',                                
                         'CTXSYS',                                
                         'MDSYS',                                
                         'ORDPLUGINS',                            
                         'ORDSYS',                                
                         'WMSYS',                                
                         'OUTLN',                                
                         'DBA',                                
                         'JAVASYSPRIV',                            
                         'OEM_MONITOR',
                         'OLAPSYS',
                         'PUBLIC',
                         'DMSYS',
                         'SYSMAN',
                         'EXFSYS',
                         'ORACLE_OCM',
                         'IMP_FULL_DATABASE',
                         'RECOVERY_CATALOG_OWNER',
                         'SCHEDULER_ADMIN',
                         'EXP_FULL_DATABASE',
                         'OEM_ADVISOR',
                         'OLAP_DBA',
                         'AQ_ADMINISTRATOR_ROLE',
                         'JAVADEBUGPRIV',
                         'MGMT_USER',
                         'CONNECT',
                         'OLAP_USER',
                         'SCOTT',
                         'RESOURCE',
                         'MDDATA',
                         'SI_INFORMTN_SCHEMA',
                         'DIP',
                         'TSMSYS',
                         'XS$NULL',
                         'APEX_030200',
                         'APEX_PUBLIC_USER',
                         'APPQOSSYS',
                         'ORDDATA',
                         'OWBSYS',
                         'OWBSYS_AUDIT',
                         'SPATIAL_CSW_ADMIN_USR',
                         'SPATIAL_WFS_ADMIN_USR',
                         'XS$NULL',
                         'FLOWS_FILES'
                         )                              
 ORDER BY USERNAME;



-- trocando o tempo de expiração do profile
alter profile default limit password_life_time unlimited;