

if [ "$PERFLAB_PATH" = "" ]; then
  export PERFLAB_PATH=$HOME/labs
fi

cd $PERFLAB_PATH

#
# source environment
#
. ./env

#
# Run the install script to setup the database
#
#
# Configure SH account
#
sqlplus "/ as sysdba" <<! > /tmp/perflab_install.log 2>&1

grant connect, resource, dba to SH;
!

#
# create the fetch_n_rows procedure
#
sqlplus "$PERFLAB_USER" <<! > /tmp/perflab_install.log 2>&1

  drop index sales_time_bix;
  drop index sales_time_idx;
  create index sales_time_idx on sales(time_id) compute statistics;

  -----------------------------------------------------------------
  -- fetch_n_rows: fetches 'n' rows from the specified statement --
  -----------------------------------------------------------------
  CREATE OR REPLACE PROCEDURE fetch_n_rows(
    stmt  VARCHAR,
    name  VARCHAR,
    nexec NUMBER  := 1,
    nrows NUMBER  := 0,
    debug BOOLEAN := FALSE)
    IS
      -- Local variables
      curs     INTEGER := null;
      rc       INTEGER;
      nexec_it INTEGER := 0;
      nrows_it INTEGER;
    BEGIN

      dbms_application_info.set_module('DEMO', name);

      WHILE (nexec_it < nexec)
      LOOP

        curs := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(curs, stmt, DBMS_SQL.NATIVE);
        rc   := DBMS_SQL.EXECUTE(curs);
        nrows_it := 0;

        LOOP
          IF (dbms_sql.fetch_rows(curs) <= 0 OR (nrows <> 0 AND nrows_it = nrows
))
          THEN
            EXIT;
          ELSE IF (debug = TRUE)
            THEN
              DBMS_OUTPUT.PUT_LINE(nrows_it);
            END IF;
          END IF;

          nrows_it := nrows_it + 1;

        END LOOP;

        DBMS_SQL.CLOSE_CURSOR(curs);

       nexec_it := nexec_it + 1;

     END LOOP;

     dbms_application_info.set_module(null, null);

    END fetch_n_rows;
/

show errors

!

#
# Start the workload
#
. ./start_workload.sh >> /tmp/setup_perflab.log 2>&1

#
# Wait two minutes for workload to get going
#
sleep 120

#
# Modify snapshot interval
#

sqlplus -s /NOLOG <<EOF > /tmp/setup_perflab.log 2>&1

  connect / as sysdba

  set head on
  set feedback on;
  set pagesize 40

  rem -- event to allow setting very short Flushing interval
  alter session set events '13508 trace name context forever, level 1';

  rem -- change INTERVAL setting to 2 minutes
  rem -- change RETENTION setting to 6 hours (total of 180 snapshots)
  execute dbms_workload_repository.modify_snapshot_settings(interval => 2,-
     retention => 360);

EOF

