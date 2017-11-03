SELECT owner, table_name, constraint_name,
       DECODE(constraint_type,'C','Check',
                              'P','Primary Key', 
                              'U','Unique',
                              'R','Referential Integrity', 
                              '?','Unknown',
                              'V','Check Option (View Constraint)', 
                              'O','Read Only (View Constraint)',
                              constraint_type) constraint_type,
        search_condition, delete_rule, status, DEFERRABLE, DEFERRED 
FROM   dba_constraints
WHERE  (owner = 'CRP' OR owner IN ('CRP'))
ORDER BY 1, 2, 3