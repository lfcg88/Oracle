
. ./env

. ./stop_workload.sh > /tmp/stop_workload.log 2>&1


#
# Compute total number of streams
#

PERFLAB_NOISE_STREAM=2
PERFLAB_NOISE_SAMPLE=1000
PERFLAB_SQLTUNE_STREAM=14
PERFLAB_SQLTUNE_SAMPLE=1000

let STREAM_COUNT="PERFLAB_NOISE_STREAM+PERFLAB_SQLTUNE_STREAM"


#
# Initialize background processing
#
sqlplus -S sh/sh @setup_workload.sql $STREAM_COUNT

#
# Now start all the noise streams
#
STREAM_NUM=0
PIDLST=""
while [ $STREAM_NUM -lt $PERFLAB_NOISE_STREAM ]; do

  # one more 
  let STREAM_NUM="STREAM_NUM+1"

  # start one more stream
  sqlplus -S sh/sh @noise_workload.sql $STREAM_NUM $STREAM_COUNT $PERFLAB_NOISE_SAMPLE &

  # remember PID
  PIDLST="$! $PIDLST"

  # wait a little bit
  if [ $STREAM_NUM -ne $PERFLAB_NOISE_STREAM ]; then
    sleep 5
  fi

done


#
# Start also the sql_tune streams
#
while [ $STREAM_NUM -lt $STREAM_COUNT ]; do

  # one more 
  let STREAM_NUM="STREAM_NUM+1"

  # start one more stream
  sqlplus -S sh/sh @sqltune_workload.sql $STREAM_NUM $STREAM_COUNT $PERFLAB_SQLTUNE_SAMPLE &

  # remember PID
  PIDLST="$! $PIDLST"

done

#
# Save PID List
#
echo $PIDLST > $PERFLAB_PID
