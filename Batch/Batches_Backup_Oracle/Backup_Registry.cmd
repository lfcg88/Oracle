setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
set DIR=%BK_Registry_Backup%

if exist %DIR%\security            del %DIR%\security
if exist %DIR%\software            del %DIR%\software
if exist %DIR%\system              del %DIR%\system
if exist %DIR%\default             del %DIR%\default
if exist %DIR%\SAM                 del %DIR%\SAM
if exist %DIR%\registry_backup.zip del %DIR%\registry_backup.zip
regback %DIR%

:COMPRESS
path=%path%;%BK_Winzip_Path%
wzzip -a -ex -m %DIR%\Registry_Backup.zip %DIR%\security %DIR%\software %DIR%\system %DIR%\default %DIR%\SAM

:EOJ
endlocal