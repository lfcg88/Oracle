setlocal

fscmd movegroup "MIAFISDB" /cluster=%BK_Cluster_Name% /node=%BK_Cluster_Node% /logfile=%BK_Batches_Logs%\Movegroup.log /user=%BK_Cluster_Username% /password=%BK_Cluster_pwd% /domain=%BK_Cluster_Domain%

endlocal