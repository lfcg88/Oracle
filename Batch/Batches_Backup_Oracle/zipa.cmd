setlocal
%BK_Batches_Drive%
cd %BK_Batches_Dir%
set path=%path%;%BK_Winzip_Path%
set zip=%1
set zip=%zip:~0,-3%ZIP

:ZIPA
wzzip -a -ex -m %zip% %1

if errorlevel 1 (
  echo Erro compressao de backup 
  net send %COMPUTERNAME% Erro compressao de backup 
)

:EOJZIPA
endlocal