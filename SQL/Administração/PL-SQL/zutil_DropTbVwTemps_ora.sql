clear screen
begin 
    
    FOR R IN (SELECT OBJECT_NAME, OBJECT_TYPE
    FROM USER_OBJECTS
       WHERE OBJECT_TYPE IN ('TABLE','VIEW')
       AND 
       (OBJECT_NAME LIKE '[bCHMS]%[_]%[0-9]'
       OR OBJECT_NAME LIKE '%[M,N][0-9]%[C,F,G,I][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
       OR OBJECT_NAME LIKE 'TABINT%[0-9]'
       OR OBJECT_NAME LIKE 'TABMV%[0-9]'
       OR OBJECT_NAME LIKE 'TABTEMP%_[0-9]'
       OR OBJECT_NAME LIKE 'TABTMP%_[0-9]'
       OR OBJECT_NAME LIKE 'TTN_%'
       OR OBJECT_NAME LIKE 'TT_%'
       OR OBJECT_NAME LIKE '%##TT_%'
       OR OBJECT_NAME LIKE '[V][^T]%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
       OR OBJECT_NAME LIKE '[V][T][_]%'))

    LOOP
      EXECUTE IMMEDIATE 'DROP ' || R.OBJECT_TYPE || ' ' || R.OBJECT_NAME;
    END LOOP;

END;
/
