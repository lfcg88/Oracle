column noparse_ratio format 999;

SELECT 
   100 * (1 - A.hard_parses/B.executions)   noparse_ratio
FROM
   (select 
      value hard_parses
   from 
      v$sysstat 
   where 
      name = 'parse count (hard)' ) A, 
    (select value executions
     from 
        v$sysstat 
     where 
        name = 'execute count' )      B;
