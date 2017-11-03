%BK_Batches_Drive%
cd %BK_Batches_Dir%

echo %BK_NSR%\res\nsrdb > Savegroup.txt
echo %BK_NSR% >> Savegroup.txt
echo %BK_Batches_Path% >> Savegroup.txt
echo %BK_Oracle_Home% >> Savegroup.txt
echo %BK_Oracle_Admin% >> Savegroup.txt
echo %BK_Oracle_Archive1% >> Savegroup.txt
echo %BK_Oracle_Archive2% >> Savegroup.txt
echo %BK_Oracle_Backup% >> Savegroup.txt
echo %BK_Oracle_Export% >> Savegroup.txt
echo %BK_Registry_Backup% >> Savegroup.txt
echo SYSTEM STATE:\ >> Savegroup.txt
echo SYSTEM FILES:\ >> Savegroup.txt
echo SYSTEM DB:\ >> Savegroup.txt