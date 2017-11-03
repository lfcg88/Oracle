setlocal

fscmd onlineresource %1.world /cluster=%BK_Cluster_Name% /user=%BK_CLuster_Username% /pwd=%BK_Cluster_PWD% /domain=%BK_CLuster_Domain%

wait 30

endlocal