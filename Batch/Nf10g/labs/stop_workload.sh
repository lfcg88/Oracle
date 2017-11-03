
. ./env

#
# Kill all the SQL plus connections
#
ps -ef | grep "LOCAL=Y" | awk '{print "kill -9 " $2 }' > x.sh
. ./x.sh
