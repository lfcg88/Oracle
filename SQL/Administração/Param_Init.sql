SELECT   a.NAME, a.VALUE, upper(i.instance_name) instance_name
FROM     v$parameter a, v$instance i
ORDER BY UPPER(NAME)