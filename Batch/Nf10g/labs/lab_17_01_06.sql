connect vpd/vpd

exec DBMS_RLS.ADD_POLICY(                     -
OBJECT_SCHEMA     => 'vpd'                   ,-
OBJECT_NAME       => 'employees'             ,-
POLICY_NAME       => 'vpd_policy'            ,-
FUNCTION_SCHEMA   => 'vpd'                   ,-
POLICY_FUNCTION   => 'vpd_security.empno_sec',-
STATEMENT_TYPES   => 'select'                ,-
UPDATE_CHECK      => false                   ,-
ENABLE            => true                    ,-
STATIC_POLICY     => false                   ,-
POLICY_TYPE       => DBMS_RLS.DYNAMIC        ,-
LONG_PREDICATE    => false                   ,-
SEC_RELEVANT_COLS => 'SALARY,COMMISSION_PCT');