SELECT  owner, trigger_name, trigger_type,
        triggering_event, table_owner, table_name,
        referencing_names, when_clause, status,
        description, trigger_body
FROM    DBA_TRIGGERS t
WHERE   (owner = 'CRP' OR owner IN ('CRP'))
ORDER BY owner, trigger_name