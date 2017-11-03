SELECT
   substr(name,1,10),
   file#,
   class#,
   max(xnc)
FROM
   v$ping
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

