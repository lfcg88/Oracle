
select warning_value,critical_value
from dba_thresholds
where metrics_name='Tablespace Space Usage' and
      object_name is null;
