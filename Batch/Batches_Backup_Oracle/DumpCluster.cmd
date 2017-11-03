setlocal

fscmd dumpcluster /cluster=%BK_Cluster_Name% /logfile=%BK_Batches_Logs%\Dumpcluster.log /user=%BK_Cluster_Username% /password=%BK_Cluster_pwd% /domain=%BK_Cluster_Domain%

endlocal