
-- Cleanup:
alter system set undo_tablespace=UNDOTBS1;

drop tablespace ut2 including contents and datafiles;

drop tablespace TBSALERT including contents and datafiles;
