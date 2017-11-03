
mkdir /home/oracle/tape

rman target / << END

CONFIGURE DEVICE TYPE 'SBT_TAPE' PARALLELISM 2;
CONFIGURE CHANNEL 2 DEVICE TYPE 'SBT_TAPE' PARMS 'SBT_LIBRARY=oracle.disksbt, ENV=(ORASBT_SIM_ERROR=sbtbackup, BACKUP_DIR=/home/oracle/tape)';
CONFIGURE CHANNEL 1 DEVICE TYPE 'SBT_TAPE' PARMS 'SBT_LIBRARY=oracle.disksbt, ENV=(BACKUP_DIR=/home/oracle/tape)';
exit;
END
