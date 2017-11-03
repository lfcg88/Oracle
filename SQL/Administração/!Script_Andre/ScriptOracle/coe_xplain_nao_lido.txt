/*$Header: coe_xplain.sql 8.1/11.5     2000/01/15 16:00:00     csierra coe $ */
SET term off;
SET ver off;
/*=============================================================================
 OVERVIEW:
    Generates enhanced Explain Plan for one SQL statement.  Includes relevant
    statistics: table(s), index(es) and index(es)_column(s).  It optionally
    displays histograms, storage parameters and database parameters.

 INSTRUCTIONS:
    Insert your SQL statement under the 'III. Generate Explain Plan' section. 
    Finish your SQL statement with a semicolon ';'. Save and run this script.  

 NOTES:
 1. Download newer version from (case sensitive): 
    http://coe.us.oracle.com/~csierra/CoE_Scripts/coe_xplain.sql
 2. The Explain Plan is spooled to file COE_XPLAIN.LST contains.  The original
    SQL statement is spooled to COE_STATEMENT.LST
 3. Open the spooled files using WordPad, change the font to Courier New, style
    regular and size 8.  Set up the page to Lanscape with all 4 margins 0.5 in.
 4. This script has been tested on 8.0.5 and 8.1.6.  It is ready to run on any
    8.1.6+ server. If you need to run it on 8.0 remove all lines having the
    comment '-- 8.1' on them.
 5. For a list of all install init.ora parameters and values on 11i run script
    $FND_TOP/sql/AFCHKCBO.sql.  This script includes the display of such
    parameters for Apps 11i.
 6. This script is capable of tracing the CBO.  Find the two lines referencing
    event 10053 (do find on '10053) and remove comment (--).
    Read Note:72346.1 for interpretation.
 7. Table COE_HISTOGRAMS has been created to workaround Bug 894549 (poor
    performance on TAB_HISTOGRAMS views)

 PARAMETERS:
 1. Include count(*) of Tables in SQL Statement? <Y/N> 
        N - Does not display count(*) information for all Tables (DEFAULT)
        Y - Creates nd runs a SQL script to perform a count(*) on all Tables
            referenced in the Explain Plan.  It may be slow but it is highly
            recommended for RULE based optimizer 
 2. Include Table and Index Storage Parameters? <N/Y> 
        Y - Displays both Table and Index Storage Parameters from ALL_TABLES
            and ALL_INDEXES.
        D - Same as Y.  It also displays, counts and summarizes Extents for
            each Object referenced in Explain Plan.  This step may be slow.
            Request this Detailed option only when really needed.
        N - Skips the extract and display of Storage Parameters (DEFAULT)
 3. Include all Table Columns? <N/Y> 
        Y - Extracts and displays all Columns for all Tables referenced in
            Explain Plan
        N - Displays statistics only for those Columns included in at least
            one Index of a Table referenced in the Explain Plan (DEFAULT)
 4. Include all Column Histograms? <N/Y>
        Y - Display all Histogram information from ALL_TAB_HISTOGRAMS for
            all Columns in all Tables referenced in Explain Plan
        N - Skips the display of all Histograms (DEFAULT)
 5. Include relevant INIT.ORA DB parameters? <N/Y>
        Y - Displays relevant DB parameters from v$parameter.  
        N - Skips the display of v$parameter (DEFAULT)
 6. Enter your initials to suffix objects <null>
        xx  Create COE temp objects with xx suffix (DEFAULT)
            Use this option if more than one analyst is using this script
            at the same time (concurrency).
            To activate this parameter, remove comments in ACCEPT INITIALS
 DISCLAIMER:
    This script is provided for educational purposes only.  It is not supported
    by Oracle World Wide Technical Support.  The script has been tested and 
    appears to works as intended.  However, you should always test any script 
    before relying on it. 
    Proofread this script prior to running it!  Due to differences in the way 
    text editors, email and operating systems handle text formatting (spaces, 
    tabs and carriage returns), this script may not be in an executable state 
    when you first receive it.  Check over the script to ensure that errors of 
    this type are corrected. 
    This script can be sent to customers.  Do not remove disclaimer paragraph.

 HISTORY:
    02-DEC-99 Created                                                   csierra
    21-JAN-00 Row Count(*) for Tables in Explain Plan is added          csierra
    17-FEB-00 Index summary is added                                    csierra
    20-MAR-00 Statistics information is enhanced and index_column added csierra
    06-APR-00 Operation Type and Order columns are incorporated         csierra
    08-MAY-00 Parameter include_count added to avoid redundant count(*) csierra
    01-SEP-00 COE_PLAN_TABLE is incorporated replacing PLAN_TABLE       csierra
    08-SEP-00 (RBO or CBO has been used) is displayed in Plan           csierra
    08-SEP-00 Display of DBA_TABLES data is splited by blocks           csierra
    14-SEP-00 COE_INDEXES table is created                              csierra
    21-SEP-00 Table Columns are added                                   csierra
    22-SEP-00 Storage Parameters plus Table and Index Extents           csierra
    25-SEP-00 Include relevant DB parameters from v$parameter           csierra
    06-NOV-00 Fixing some column sizes                                  csierra
    20-NOV-00 Include Object_id for tables and indexes (event 10053)    csierra
    27-NOV-00 Added parameter 'initials' to avoid sync crashes multiusr csierra
    12-DEC-00 Hide parameter 'initials' and CBO traceing                csierra
    13-DEC-00 Include all Column Histograms                             csierra 
    21-DEC-00 Fixed High Water Mark - adding 1 to blocks + empty bloks  csierra
    05-JAN-01 Table COE_HISTOGRAMS is created to workaround 894549      csierra
    05-JAN-01 Histograms and FND_HISTOGRAM_COLS are incorporated        csierra
 =============================================================================*/

/* I. Execution Parameters Section                                            
   ===========================================================================*/
SET term on;
PROMPT Unless otherwise instructed by Support, hit <Enter> for each parameter
accept include_count prompt - 
       '1. Include count(*) of Tables in SQL Statement? <n/y> ';
accept include_storage prompt - 
       '2. Include Table and Index Storage Parameters? <n/y/d> ';
accept include_all_columns prompt -
       '3. Include all Table Columns? <n/y> ';
accept include_histograms prompt -
       '4. Include all Column Histograms? <n/y> ';
accept include_vparameter prompt -
       '5. Include relevant INIT.ORA DB parameters? <n/y> ';
def initials='XX'; -- remove comments in next two lines to acctivate parameter
-- accept initials prompt -
--       '6. Enter your initials to suffix objects <null> ';
PROMPT Generating...
SET term off;

/* II. DDL Section - Create Tables COE_PLAN_TABLE, COE_TABLES and COE_INDEXES
   ========================================================================== */
DROP   TABLE COE_PLAN_TABLE_&&initials;
CREATE TABLE COE_PLAN_TABLE_&&initials
    (statement_id varchar2(30),timestamp date,remarks varchar2(80),
     operation varchar2(30),options varchar2(30),object_node varchar2(128),
     object_owner varchar2(30),object_name varchar2(30),
     object_instance numeric,object_type varchar2(30),
     optimizer varchar2(255),search_columns number,id numeric,
     parent_id numeric,position numeric,cost numeric,cardinality numeric,
     bytes numeric,other_tag varchar2(255),partition_start varchar2(255),
     partition_stop varchar2(255),partition_id numeric,other long,
     execution_order numeric);
DROP   TABLE COE_TABLES_&&initials;
CREATE TABLE COE_TABLES_&&initials 
    (TABLE_NUM NUMBER,TABLE_OWNER VARCHAR2(30),TABLE_NAME VARCHAR2(30),
     ROWS_COUNT NUMBER);
DROP   TABLE COE_INDEXES_&&initials;
CREATE TABLE COE_INDEXES_&&initials 
    (TABLE_NUM NUMBER,INDEX_NUM NUMBER,INDEX_OWNER VARCHAR2(30), 
     INDEX_NAME VARCHAR2(30),TABLE_OWNER VARCHAR2(30),TABLE_NAME VARCHAR2(30));
DROP   TABLE COE_HISTOGRAMS_&&initials;
CREATE TABLE COE_HISTOGRAMS_&&initials
    (TABLE_NUM NUMBER,TABLE_OWNER VARCHAR2(30),TABLE_NAME VARCHAR2(30),
     COLUMN_NAME VARCHAR2(30),ENDPOINT_NUMBER NUMBER,ENDPOINT_VALUE NUMBER,
     ENDPOINT_ACTUAL_VALUE VARCHAR2(30), ENDPOINT_JULIAN NUMBER(7));

/* III. Generate Explain Plan Section                                         
   ===========================================================================*/
-- alter session set events '10053 trace name context forever, level 1';
SPOOL coe_statement.lst;
SET pages 1000;
SET lin 150;
SET sqlp '';
SET sqln off;
SET autotrace off;
SET term on;
SET echo on;

explain plan set statement_id = 'COE_XPLAIN' into COE_PLAN_TABLE_&&initials for
/*===========================================================================
  Generate Explain Plan for SQL statement below (ending with a semicolon ';') 
  =========================================================================== */ 
select
   fc.forecast_designator        "forecast",
   fc.forecast_set               "set",
   fi.inventory_item_id          "item",
   fd.forecast_date              "fc date",
   fd.original_forecast_quantity "orig qty",
   fd.current_forecast_quantity  "curr qty",
   fd.transaction_id             "xtn id",
   fu.update_sales_order         "sales order"
from
    mrp_forecast_designators     fc,
    mrp_forecast_items           fi,
    mrp_forecast_dates           fd,
    mrp_forecast_updates         fu
where
    fc.organization_id         = 207
and fc.forecast_designator     = 'F-M1-SCP'
and fd.forecast_date           < sysdate
and fc.organization_id         = fi.organization_id
and fc.forecast_designator     = fi.forecast_designator
and fi.organization_id         = fd.organization_id
and fi.forecast_designator     = fd.forecast_designator
and fi.inventory_item_id       = fd.inventory_item_id
and fd.transaction_id          = fu.transaction_id(+)
order by 1,2,3,4;

/* ========================================================================== */
SET echo off;
SPOOL OFF;
SET term off;
-- alter session set events '10053 trace name context off';

/* IV. Compute Execution Order Section                                        
   ===========================================================================*/
DECLARE
    coe_pointer     number := 0;  -- Row on COE_PLAN_TABLE being processed.
    coe_next_order  number := 1;  -- To update Execution Order
    coe_xplain      CONSTANT varchar2(30) := 'COE_XPLAIN'; -- statement_id.
    coe_parent_id   number;       -- To move pointer (only if needed).
    coe_curr_order  varchar2(80); -- Order in current row of COE_PLAN_TABLE.
    coe_count_child number;       -- Number of children for a parent.
BEGIN
    LOOP
        SELECT parent_id, execution_order    -- Reads COE_PLAN_TABLE w/pointer.
        INTO   coe_parent_id, coe_curr_order -- Starts on first row (id=0) and
        FROM   COE_PLAN_TABLE_&&initials     -- works its way down.
        WHERE  id           = coe_pointer
        AND    statement_id = coe_xplain;
        IF  coe_curr_order is not null THEN  -- When row has already its Order:
            EXIT WHEN coe_pointer = 0;       -- Exit Loop if back at the Top.
            coe_pointer := coe_parent_id;    -- Else, move pointer to parent.
        ELSE                                 -- When row doesn't have Order yet:
            SELECT count(*)                  -- Determines if there is any
            INTO   coe_count_child           -- child for the current parent
            FROM   COE_PLAN_TABLE_&&initials -- pending to receive Order.
            WHERE  parent_id        = coe_pointer
            AND    execution_order is null
            AND    statement_id     = coe_xplain;
            IF  coe_count_child     = 0 THEN -- If no child is pending:
                UPDATE COE_PLAN_TABLE_&&initials -- row gets updated with Order.
                SET execution_order = to_char(coe_next_order)
                WHERE  id           = coe_pointer
                AND    statement_id = coe_xplain;
                coe_next_order := coe_next_order + 1; -- Order gets incremented.
            ELSE                             -- If at least one pending child:
                SELECT id                    -- Move pointer to first pending
                INTO   coe_pointer           -- child.
                FROM   COE_PLAN_TABLE_&&initials
                WHERE  parent_id        = coe_pointer
                AND    execution_order is null
                AND    rownum           = 1
                AND    statement_id     = coe_xplain;
            END IF;
        END IF;
    END LOOP;
END;
/

/* V. COLUMN Definition Section                                               
   ===========================================================================*/
SET feed off;
SET numf 999,999,999;
CLEAR columns;
CLEAR breaks;
COLUMN typ FORMAT a3 HEADING 'Ope|Typ';
COLUMN execution_order FORMAT 9999 HEADING 'Exec|Order';
COLUMN query_plan FORMAT a140 HEADING - 
                    'Explain Plan (coe_xplain.sql 8.1/11.5 20010115)' wor;
COLUMN owner_table FORMAT a37 HEADING 'Owner.Table';
COLUMN owner_index FORMAT a40 HEADING 'Owner.Index';
COLUMN table_name FORMAT a30 HEADING 'Table';
COLUMN index_name FORMAT a33 HEADING 'Index';
COLUMN last_analyzed HEADING 'Last|Analyzed';
COLUMN num_rows FORMAT 99,999,999 HEADING -
                    '(B)|Num of rows|in Table|(Cardinality)';
COLUMN num_rows_i FORMAT 99,999,999 HEADING '(C)|Number|of rows|in Index';
COLUMN delta_percent FORMAT b999.9 HEADING 'Delta|Percent|ABS(A-B)/A';
COLUMN avg_row_len FORMAT b99,999 HEADING 'Avg Row|Length|(bytes)';
COLUMN avg_col_len FORMAT b99,999 HEADING 'Avg Col|Length|(bytes)';
COLUMN num_buckets FORMAT b99,999 HEADING 'Number|Buckets|Histogr';
COLUMN hwm_blocks FORMAT b99,999,999 HEADING 'High|Water-Mark|(blocks)';
COLUMN empty_blocks FORMAT b99,999,999 HEADING 'Empty|Blocks';
COLUMN used_blocks FORMAT b99,999,999 HEADING 'Used|Blocks';
COLUMN freelists FORMAT b99 HEADING 'Free|Lists';
COLUMN global_stats FORMAT a6 HEADING 'Global|Stats';
COLUMN distinct_keys FORMAT 99,999,999 HEADING '(D)|Distinct|Keys';
COLUMN num_distinct FORMAT 99,999,999 HEADING '(H)|Num of|Distinct|Values';
COLUMN rows_count FORMAT b99,999,999 HEADING '(A)|Rows from|Count(*)';
COLUMN index_cardinality FORMAT 99,999,999 HEADING - 
                    '(E)|Computed|Index|Cardinality|(C/D)';
COLUMN index_selectivity FORMAT 9.9999eeee HEADING -
                    'Computed|Index|Selectivity|(E/B)';
COLUMN column_cardinality FORMAT 99,999,999 HEADING -
                    '(I)|Computed|Column|Cardinality|(G/H)';
COLUMN column_selectivity FORMAT 9.9999eeee HEADING -
                    'Computed|Column|Selectivity|(I/B)';
COLUMN density FORMAT 9.9999eeee HEADING -
                    'Column|Density';
COLUMN table_num FORMAT 99 HEADING 'Tab|Num';
COLUMN index_num FORMAT 999 HEADING 'Indx|Num';
COLUMN uniqueness FORMAT a10 HEADING 'Uniqueness';
COLUMN column_name FORMAT a30 HEADING 'Column';
COLUMN column_position FORMAT 999 HEADING 'Pos';
COLUMN nullable FORMAT a9 HEADING 'Null?';
COLUMN num_nulls FORMAT 99,999,999 HEADING -
                    '(F)|Number of|Rows with|NULLs in|this column';
COLUMN not_nulls FORMAT 99,999,999 HEADING -
                    '(G)|Number of|Rows with|Value|(B-F)';
COLUMN avg_space FORMAT b9,999,999,999 HEADING - 
                    'Average|free space|per allocated|block (bytes)';
COLUMN avg_space_percent FORMAT b99,999,999.9 HEADING - 
                    'Average|free space|per allocated|block (%)';
COLUMN degree FORMAT b99,999 HEADING 'Degree|of Para-|llelism';
COLUMN partitioned FORMAT a7 HEADING 'Parti-|tioned?';
COLUMN sample_size FORMAT b9,999,999 HEADING 'Sample|Size|(% or|rows)';
COLUMN chain_cnt FORMAT 99,999,999 HEADING 'Chain|Count|(rows)';
COLUMN tablespace_name FORMAT a20 HEADING 'Tablespace';
COLUMN pct_free FORMAT b999 HEADING - 
                    'Minimum|percent of|free space|per block|(pct_free)';
COLUMN pct_used FORMAT b999 HEADING - 
                    'Minimum|percent of|used space|per block|(pct_used)';
COLUMN initial_extent FORMAT b999,999,999,999 HEADING - 
                    'Initial|Extent|size|(bytes)';
COLUMN next_extent FORMAT b999,999,999,999 HEADING -
                    'Next|Extent|size|(bytes)';
COLUMN min_extents FORMAT b999,999 HEADING 'Minimum|num. of|Extents';
COLUMN max_extents FORMAT b9,999,999,999 HEADING 'Maximum num.|of Extents';
COLUMN pct_increase FORMAT b99,999 HEADING - 
                    'Percent|increase|size for|Next|Extent';
COLUMN count_extents FORMAT b99,999 HEADING 'Actual|Extents|Count';
COLUMN index_type FORMAT a12 HEADING 'Index Type';
COLUMN status FORMAT a8 HEADING 'Status';
COLUMN blevel FORMAT 999,999 HEADING 'B*-Tree|level|(index|depth)';
COLUMN leaf_blocks FORMAT 9,999,999 HEADING 'Number|of|leaf|blocks';
COLUMN avg_leaf_blocks_per_key FORMAT 9,999,999 HEADING - 
                    'Avg num of|leaf blocks|per key';
COLUMN avg_data_blocks_per_key FORMAT 9,999,999 HEADING -
                    'Avg Num of|data blocks|per key';
COLUMN clustering_factor FORMAT 99,999,999 HEADING 'Clustering|factor';
COLUMN data_type FORMAT a14 HEADING 'Type';
COLUMN column_id FORMAT 9999 HEADING 'Col';
COLUMN extent_id FORMAT 999999999 HEADING 'Extent ID';
COLUMN file_id FORMAT 9999999 HEADING 'File ID';
COLUMN block_id FORMAT 9999999999 HEADING 'Block ID|from';
COLUMN block_to FORMAT 9999999999 HEADING 'Block ID|to';
COLUMN blocks FORMAT 99,999,999 HEADING 'Blocks';
COLUMN bytes FORMAT 999,999,999,999 HEADING 'Bytes';
COLUMN vparameter FORMAT a50 HEADING - 
                    'Relevant init.ora parameters from v$parameter'; 
COLUMN init11i FORMAT a14  HEADING -
                    'init.ora value|required for|apps 11i';
COLUMN object_id FORMAT 999999 HEADING 'Object';
COLUMN indexed_column FORMAT a7 HEADING 'Indexed|Column';
COLUMN endpoint_number FORMAT 999999 HEADING 'Bucket|Number';
COLUMN endpoint_value FORMAT B999999999999 HEADING -
                    'Normalized|end point|numeric|value';
COLUMN endpoint_value_e FORMAT 9.999999eeee HEADING -
                    'Normalized|end point|numeric|value (e10)';
COLUMN endpoint_value_d FORMAT a11 HEADING -
                    'Normalized|end point|numeric|value (date)';
COLUMN endpoint_actual_value FORMAT a30 HEADING -
                    'Normalized|end point|actual|value';
COLUMN partition FORMAT a30 HEADING 'Partition';
COLUMN hsize FORMAT 9999999 HEADING 'Num. of|Buckets|(max)';

/* VI. Populate COE_TABLES and COE_INDEXES Section                            
   ===========================================================================*/
INSERT 
    INTO COE_TABLES_&&initials 
SELECT 
    NULL,         -- TABLE_NUM
    OBJECT_OWNER, -- TABLE_OWNER
    OBJECT_NAME,  -- TABLE_NAME
    NULL          -- ROWS_COUNT
FROM 
    COE_PLAN_TABLE_&&initials 
WHERE 
    STATEMENT_ID = 'COE_XPLAIN' 
and OPERATION    = 'TABLE ACCESS'
UNION 
SELECT 
    NULL,        -- TABLE_NUM
    TABLE_OWNER, -- TABLE_OWNER
    TABLE_NAME,  -- TABLE_NAME
    NULL         -- ROWS_COUNT
FROM 
    ALL_INDEXES
WHERE 
    (OWNER, 
     INDEX_NAME) 
IN  (SELECT DISTINCT 
         OBJECT_OWNER, 
         OBJECT_NAME 
     FROM 
         COE_PLAN_TABLE_&&initials
     WHERE 
         STATEMENT_ID = 'COE_XPLAIN' 
     and OPERATION    = 'INDEX');

UPDATE 
    COE_TABLES_&&initials 
SET 
    TABLE_NUM = ROWNUM;

INSERT 
    INTO COE_INDEXES_&&initials 
SELECT DISTINCT
    CT.TABLE_NUM,   -- TABLE_NUM
    NULL,           -- INDEX_NUM
    AI.OWNER,       -- INDEX_OWNER
    AI.INDEX_NAME,  -- INDEX_NAME
    CT.TABLE_OWNER, -- TABLE_OWNER
    CT.TABLE_NAME   -- TABLE_NAME
FROM 
    COE_TABLES_&&initials CT,
    ALL_INDEXES           AI
WHERE 
    CT.TABLE_OWNER   = AI.TABLE_OWNER
AND CT.TABLE_NAME    = AI.TABLE_NAME;

UPDATE 
    COE_INDEXES_&&initials
SET 
    INDEX_NUM = ROWNUM;

SET hea off;
SET pages 0;
SET lin 400;
SPOOL coe_xplain_tables.sql;
SELECT 
    'UPDATE COE_TABLES_&&initials CT SET ROWS_COUNT=(SELECT '||
    'COUNT(*) FROM '||TABLE_OWNER||'.'||TABLE_NAME||
    ') WHERE CT.TABLE_OWNER='''||
    TABLE_OWNER||''' AND CT.TABLE_NAME='''||TABLE_NAME||''';'
FROM 
    COE_TABLES_&&initials
WHERE
    NVL(substr(upper('&include_count'),1,1),'N') = 'Y';
SPOOL OFF;
@coe_xplain_tables.sql;
SPOOL coe_xplain_histograms.sql;
SELECT
    'INSERT INTO COE_HISTOGRAMS_&&initials SELECT '||TABLE_NUM||', '''||
    TABLE_OWNER||''', '''||TABLE_NAME||''', COLUMN_NAME, ENDPOINT_NUMBER, '||
    'ENDPOINT_VALUE, SUBSTR(ENDPOINT_ACTUAL_VALUE,1,30), NULL '||
    'FROM ALL_TAB_HISTOGRAMS WHERE OWNER='''||TABLE_OWNER||
    ''' AND TABLE_NAME='''||TABLE_NAME||''';'
FROM 
    COE_TABLES_&&initials
WHERE
    NVL(substr(upper('&include_histograms'),1,1),'N') = 'Y';
SPOOL OFF;
@coe_xplain_histograms.sql;
UPDATE
    COE_HISTOGRAMS_&&initials
SET
    ENDPOINT_JULIAN = TRUNC(ENDPOINT_VALUE)
WHERE
    ENDPOINT_VALUE BETWEEN 1 AND 5373484;
COMMIT;

/* VII. Creates coe_xplain.lst spool file with Explain Plan                   
   ===========================================================================*/
SET hea on;
SET pages 10000;
SPOOL coe_xplain.lst;
SET lin 150;
SET term on;

SELECT 
    DECODE(OPERATION,'SORT','SET','VIEW','SET','HASH JOIN','S/R',
           'ROW') typ,  -- Operation Type
    EXECUTION_ORDER, -- Processing Order
    lpad(' ',LEVEL,rpad(' ',80,'....|'))||OPERATION||' '|| -- Operation
    DECODE(OPTIONS,NULL,'',DECODE(SUBSTR(OPTIONS,1,4),'FULL', 
           '***('||OPTIONS||')*** ','('||OPTIONS||') '))|| -- Options
    DECODE(OBJECT_OWNER,null,'','OF '''||OBJECT_OWNER||'.')|| -- Owner
    DECODE(OBJECT_NAME,null,'',OBJECT_NAME||''' ')|| -- Object Name
    DECODE(OBJECT_TYPE,null,'','('||OBJECT_TYPE||') ')|| -- Object Type
    DECODE(ID,0,'Opt_Mode:')||
    DECODE(OPTIMIZER,null,'','ANALYZED','',OPTIMIZER||' ')||
    DECODE(ID,0,DECODE(POSITION,null,'(RBO','Total_Cost:'||POSITION||' '||
           '(CBO')||' has been used)  ')|| -- CBO or RBO has been used
    DECODE(ID,0,'',DECODE(COST||CARDINALITY||BYTES,null,'','('))|| -- (
    DECODE(COST,NULL,'',DECODE(ID,0,'','Cost='||COST))|| -- Operation Cost
    DECODE(CARDINALITY,null,'',DECODE(ID,0,'',
    DECODE(COST,null,'',' ')||'Card='||CARDINALITY))||
    DECODE(BYTES,null,'',DECODE(ID,0,'',
    DECODE(COST||CARDINALITY,null,'',' ')||'Bytes='||BYTES))||
    DECODE(ID,0,'',DECODE(COST||CARDINALITY||BYTES,null,'',')')) -- )
    query_plan -- Explain Plan
FROM 
    COE_PLAN_TABLE_&&initials 
WHERE 
    STATEMENT_ID = 'COE_XPLAIN'
CONNECT BY 
    PRIOR ID     = PARENT_ID 
AND STATEMENT_ID = 'COE_XPLAIN'
START WITH 
    ID           = 0 
AND STATEMENT_ID = 'COE_XPLAIN';
PROMPT
PROMPT Note: Card=Computed or Default Object Cardinality
PROMPT
PAUSE Enter to continue

/* VIII. TABLES Section                                                       */
/* ===========================================================================*/
PROMPT
PROMPT I. TABLES
PROMPT =========
SELECT 
    CT.TABLE_NUM,          -- Table Number
    AA.OBJECT_ID,          -- For Event 10053
    CT.TABLE_OWNER||'.'||CT.TABLE_NAME
        OWNER_TABLE,       -- Table Owner and Name
    CT.ROWS_COUNT,         -- Count(*) on Table
    to_number(AT.DEGREE)
        DEGREE,            -- Degree of Parallelism
    AT.PARTITIONED,        -- Is this Table partitioned?
    AT.CHAIN_CNT,          -- Count of rows that are chained
    AT.FREELISTS           
FROM 
    ALL_OBJECTS            AA,
    ALL_TABLES             AT,
    COE_TABLES_&&initials  CT   -- All Tables referenced in Explain Plan
WHERE 
    CT.TABLE_OWNER = AT.OWNER 
AND CT.TABLE_NAME  = AT.TABLE_NAME
AND CT.TABLE_OWNER = AA.OWNER
AND CT.TABLE_NAME  = AA.OBJECT_NAME
AND AA.OBJECT_TYPE = 'TABLE'
ORDER BY
    CT.TABLE_NUM;

PROMPT
PROMPT I.a TABLES Statistics
PROMPT =====================
SELECT 
    CT.TABLE_NUM,          -- Table Number
    to_char(AT.LAST_ANALYZED,'YYYYMMDD:HH24MISS')
        LAST_ANALYZED,     -- Last Analyzed
    AT.SAMPLE_SIZE,        -- Sample Size used when Alalyzed
    AT.NUM_ROWS,           -- Number of Rows in Table according to Analyze
    ROUND(ABS(CT.ROWS_COUNT-AT.NUM_ROWS)/
    DECODE(AT.NUM_ROWS,0,null,AT.NUM_ROWS)*100,1)
        DELTA_PERCENT,     -- Delta % = ABS(A-B)/A
    AT.AVG_ROW_LEN,        -- Average Row Length in bytes
    AT.BLOCKS
       USED_BLOCKS,        -- Used Blocks in Table
    AT.EMPTY_BLOCKS,       -- Empty Blocks in Table
    AT.BLOCKS + AT.EMPTY_BLOCKS + 1 -- Includes Root block
       HWM_BLOCKS,         -- High Water Mark in Blocks
    AT.AVG_SPACE,          -- Avg free space per allocated block in bytes
    ROUND(AT.AVG_SPACE/TO_NUMBER(VP.VALUE)*100,3)
       AVG_SPACE_PERCENT   -- Avg free space per allocated block (percent)
FROM 
    V$PARAMETER            VP,
    ALL_TABLES             AT,
    COE_TABLES_&&initials  CT   -- All Tables referenced in Explain Plan
WHERE 
    CT.TABLE_OWNER = AT.OWNER 
AND CT.TABLE_NAME  = AT.TABLE_NAME
AND VP.NAME        = 'db_block_size'
ORDER BY
    CT.TABLE_NUM;

PROMPT
PROMPT I.b TABLES Storage Parameters
PROMPT =============================
SELECT 
    CT.TABLE_NUM,          -- Table Number
    AT.TABLESPACE_NAME,    -- Tablespace
    AT.PCT_FREE,           -- Minimum percentage of free space per block
    AT.PCT_USED,           -- Minimum percentage of used space per block
    AT.INITIAL_EXTENT,     -- Initial Extent size in bytes
    AT.NEXT_EXTENT,        -- Next Extent size in bytes
    AT.MIN_EXTENTS,        -- Minimum number of Extents for this Table
    AT.MAX_EXTENTS,        -- Maximum number of Extents for this Table
    AT.PCT_INCREASE       -- Percentage increase size for Next Extent
FROM 
    ALL_TABLES            AT,
    COE_TABLES_&&initials CT  -- All Tables referenced in Explain Plan
WHERE 
    substr(upper('&include_storage'),1,1) IN ('Y','D')
AND CT.TABLE_OWNER  = AT.OWNER 
AND CT.TABLE_NAME   = AT.TABLE_NAME
ORDER BY
    CT.TABLE_NUM;

BREAK ON TABLE_NUM SKIP 1 ON TABLESPACE_NAME;
COMPUTE SUM LABEL "" OF BLOCKS BYTES ON TABLE_NUM;
SELECT
    CT.TABLE_NUM,          -- Table Number
    DE.TABLESPACE_NAME,    -- Tablespace
    DE.EXTENT_ID,          -- Extent ID
    DE.FILE_ID,            -- File ID
    DE.BLOCK_ID,           -- Block ID from
    DE.BLOCK_ID + DE.BLOCKS - 1
        BLOCK_TO,          -- Block ID to
    DE.BLOCKS,             -- Number of Blocks
    DE.BYTES               -- Number of Bytes
FROM
    DBA_EXTENTS            DE,
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_storage'),1,1) = 'D'
AND CT.TABLE_OWNER  = DE.OWNER
AND CT.TABLE_NAME   = DE.SEGMENT_NAME
AND DE.SEGMENT_TYPE = 'TABLE'
ORDER BY
    CT.TABLE_NUM,
    DE.TABLESPACE_NAME,
    DE.EXTENT_ID;

/* IX. INDEXES Section                                                        */
/* ===========================================================================*/
PROMPT
PROMPT II. INDEXES
PROMPT ===========
BREAK ON TABLE_NUM SKIP 1;
SELECT 
    CI.TABLE_NUM,           -- Table Number
    CI.INDEX_NUM,           -- Index Number
    AA.OBJECT_ID,           -- For Event 10053
    CI.INDEX_OWNER||'.'||CI.INDEX_NAME
        OWNER_INDEX,        -- Index Owner and Name
    AI.INDEX_TYPE,          -- Index Type
    AI.UNIQUENESS,          -- UNIQUE or NONUNIQUE
    AI.STATUS,              -- VALID or UNUSABLE
    to_number(AI.DEGREE)
        DEGREE,            -- Degree of Parallelism
    AI.PARTITIONED,        -- Is this Table partitioned?
    AI.FREELISTS
FROM 
    ALL_OBJECTS            AA, 
    ALL_INDEXES            AI, 
    COE_INDEXES_&&initials CI  -- All Tables referenced in Explain Plan
WHERE 
    CI.INDEX_OWNER  = AI.OWNER 
AND CI.INDEX_NAME   = AI.INDEX_NAME 
AND CI.INDEX_OWNER  = AA.OWNER
AND CI.INDEX_NAME   = AA.OBJECT_NAME
AND AA.OBJECT_TYPE  = 'INDEX'
ORDER BY 
    CI.TABLE_NUM,
    CI.INDEX_NUM;

PROMPT
PROMPT II.a INDEXES Statistics
PROMPT =======================
SELECT 
    CI.TABLE_NUM,           -- Table Number
    CI.INDEX_NUM,           -- Index Number
    AA.OBJECT_ID,           -- For Event 10053
    CI.INDEX_NAME,          -- Index Name
    to_char(AI.LAST_ANALYZED,'YYYYMMDD:HH24MISS')
        LAST_ANALYZED,      -- Last Analyzed
    AI.SAMPLE_SIZE,         -- Sample Size used when Analyzed
    AI.NUM_ROWS NUM_ROWS_I, -- Number of Rows in Index according to Analyze
    AI.DISTINCT_KEYS,       -- Number of Distinct code combinations in Index
    CEIL(AI.NUM_ROWS/DECODE(AI.DISTINCT_KEYS,0,null,AI.DISTINCT_KEYS))
       INDEX_CARDINALITY,   -- The lower the better.  1 is the best
    AI.NUM_ROWS/DECODE(AI.DISTINCT_KEYS,0,null,AI.DISTINCT_KEYS)/
    DECODE(AT.NUM_ROWS,0,null,AT.NUM_ROWS)
       INDEX_SELECTIVITY    -- Index Selectivity
FROM 
    ALL_OBJECTS             AA,
    ALL_TABLES              AT,
    ALL_INDEXES             AI,
    COE_INDEXES_&&initials  CI -- All Tables referenced in Explain Plan
WHERE 
    CI.INDEX_OWNER  = AI.OWNER 
AND CI.INDEX_NAME   = AI.INDEX_NAME 
AND CI.TABLE_OWNER  = AT.OWNER
AND CI.TABLE_NAME   = AT.TABLE_NAME
AND CI.INDEX_OWNER  = AA.OWNER
AND CI.INDEX_NAME   = AA.OBJECT_NAME
AND AA.OBJECT_TYPE  = 'INDEX'
ORDER BY 
    CI.TABLE_NUM,
    CI.INDEX_NUM;

SELECT 
    CI.TABLE_NUM,           -- Table Number
    CI.INDEX_NUM,           -- Index Number
    AA.OBJECT_ID,           -- For Event 10053
    CI.INDEX_NAME,          -- Index Name
    AI.BLEVEL,              -- B*-Tree level (index depth)
    AI.LEAF_BLOCKS,         -- Number of leaf blocks
    AI.AVG_LEAF_BLOCKS_PER_KEY, -- Avg num of leaf blocks per key
    AI.AVG_DATA_BLOCKS_PER_KEY, -- Avg num of data blocks per key
    SUM(ATC.AVG_COL_LEN)    -- 8.1
       AVG_ROW_LEN,         -- 8.1
    AI.CLUSTERING_FACTOR    -- Between Num Blocks and Num Rows
FROM                        
    ALL_OBJECTS             AA,
    ALL_TAB_COLUMNS         ATC,
    ALL_IND_COLUMNS         AIC,
    ALL_INDEXES             AI,
    COE_INDEXES_&&initials  CI -- All Tables referenced in Explain Plan
WHERE 
    CI.INDEX_OWNER  = AI.OWNER 
AND CI.INDEX_NAME   = AI.INDEX_NAME 
AND CI.INDEX_OWNER  = AIC.INDEX_OWNER 
AND CI.INDEX_NAME   = AIC.INDEX_NAME
AND CI.TABLE_OWNER  = ATC.OWNER
AND CI.TABLE_NAME   = ATC.TABLE_NAME
AND AIC.COLUMN_NAME = ATC.COLUMN_NAME
AND CI.INDEX_OWNER  = AA.OWNER
AND CI.INDEX_NAME   = AA.OBJECT_NAME
AND AA.OBJECT_TYPE  = 'INDEX'
GROUP BY
    CI.TABLE_NUM,
    CI.INDEX_NUM,
    AA.OBJECT_ID,
    CI.INDEX_NAME,
    AI.BLEVEL,
    AI.LEAF_BLOCKS,
    AI.AVG_LEAF_BLOCKS_PER_KEY,
    AI.AVG_DATA_BLOCKS_PER_KEY,
    AI.CLUSTERING_FACTOR
ORDER BY 
    CI.TABLE_NUM,
    CI.INDEX_NUM;

PROMPT
PROMPT II.b INDEXES Storage Parameters
PROMPT ===============================
SELECT 
    CI.TABLE_NUM,          -- Table Number
    CI.INDEX_NUM,          -- Index Number
    AI.TABLESPACE_NAME,    -- Tablespace
    AI.PCT_FREE,           -- Minimum percentage of free space per block
    AI.INITIAL_EXTENT,     -- Initial Extent size in bytes
    AI.NEXT_EXTENT,        -- Next Extent size in bytes
    AI.MIN_EXTENTS,        -- Minimum number of Extents for this Index
    AI.MAX_EXTENTS,        -- Maximum number of Extents for this Index
    AI.PCT_INCREASE        -- Percentage increase size for Next Extent
FROM 
    ALL_INDEXES            AI,
    COE_INDEXES_&&initials CI -- All Indexes referenced in Explain Plan
WHERE 
    substr(upper('&include_storage'),1,1) IN ('Y','D')
AND CI.INDEX_OWNER  = AI.OWNER 
AND CI.INDEX_NAME   = AI.INDEX_NAME
ORDER BY
    CI.TABLE_NUM,
    CI.INDEX_NUM;

BREAK ON TABLE_NUM SKIP 2 ON INDEX_NUM SKIP 1 ON TABLESPACE_NAME;
COMPUTE SUM LABEL "" OF BLOCKS BYTES ON INDEX_NUM;
SELECT
    CI.TABLE_NUM,          -- Table Number
    CI.INDEX_NUM,          -- Index Number
    DE.TABLESPACE_NAME,    -- Tablespace
    DE.EXTENT_ID,          -- Extent ID
    DE.FILE_ID,            -- File ID
    DE.BLOCK_ID,           -- Block ID from
    DE.BLOCK_ID + DE.BLOCKS - 1
        BLOCK_TO,          -- Block ID to
    DE.BLOCKS,             -- Number of Blocks
    DE.BYTES               -- Number of Bytes
FROM
    DBA_EXTENTS            DE,
    COE_INDEXES_&&initials CI
WHERE
    substr(upper('&include_storage'),1,1) = 'D'
AND CI.INDEX_OWNER  = DE.OWNER
AND CI.INDEX_NAME   = DE.SEGMENT_NAME
AND DE.SEGMENT_TYPE = 'INDEX'
ORDER BY
    CI.TABLE_NUM,
    CI.INDEX_NUM,
    DE.TABLESPACE_NAME,
    DE.EXTENT_ID;

/* X. COLUMNS Section                                                         */
/* ===========================================================================*/
PROMPT
PROMPT III. COLUMNS
PROMPT ============
BREAK ON TABLE_NUM ON INDEX_NUM ON OBJECT_ID ON INDEX_NAME SKIP 1;
SELECT
    CI.TABLE_NUM,          -- Table Number
    CI.INDEX_NUM,          -- Index Number
    AA.OBJECT_ID,          -- For Event 10053
    CI.INDEX_NAME,         -- Index Name
    AIC.COLUMN_POSITION,   -- Position within Index
    ATC.COLUMN_ID,         -- For Event 10053
    AIC.COLUMN_NAME,       -- Column Name (ordered by column_position)
    DECODE(ATC.NULLABLE,'N','NOT NULL') 
        NULLABLE,          -- NULL or NOT NULL
    ATC.DATA_TYPE||DECODE(ATC.DATA_TYPE,
        'VARCHAR2','('||ATC.DATA_LENGTH||')',
        'CHAR','('||ATC.DATA_LENGTH||')',
        'NUMBER',DECODE(ATC.DATA_PRECISION,NULL,NULL,'('||ATC.DATA_PRECISION||
           DECODE(ATC.DATA_SCALE,NULL,NULL,0,NULL,','||ATC.DATA_SCALE)||')'))
        DATA_TYPE          -- Data Type and length
FROM 
    ALL_OBJECTS            AA,
    ALL_TAB_COLUMNS        ATC,
    ALL_IND_COLUMNS        AIC,
    COE_INDEXES_&&initials CI -- All Indexes referenced in Explain Plan
WHERE 
    CI.INDEX_OWNER  = AIC.INDEX_OWNER 
AND CI.INDEX_NAME   = AIC.INDEX_NAME
AND CI.TABLE_OWNER  = ATC.OWNER 
AND CI.TABLE_NAME   = ATC.TABLE_NAME
AND AIC.COLUMN_NAME = ATC.COLUMN_NAME 
AND CI.INDEX_OWNER  = AA.OWNER
AND CI.INDEX_NAME   = AA.OBJECT_NAME
AND AA.OBJECT_TYPE  = 'INDEX'
ORDER BY 
   CI.TABLE_NUM,
   CI.INDEX_NUM,
   AIC.COLUMN_POSITION;

PROMPT 
PROMPT III.a INDEX COLUMNS Statistics
PROMPT ==============================
BREAK ON INDEX_NAME SKIP 1;
SELECT
    CI.INDEX_NAME,         -- Index Name
    AIC.COLUMN_NAME,       -- Column Name (ordered by column_position)
    ATC.NUM_NULLS,         -- Number of Rows with NULLs in this column
    AT.NUM_ROWS - ATC.NUM_NULLS
        NOT_NULLS,         -- Number of Rows with Value
    ATC.NUM_DISTINCT,      -- Number of Distinct values on this column
    CEIL((AT.NUM_ROWS-ATC.NUM_NULLS)/
           DECODE(ATC.NUM_DISTINCT,0,null,ATC.NUM_DISTINCT))
        COLUMN_CARDINALITY,-- The Lower the better.  1 is the best.
    (AT.NUM_ROWS-ATC.NUM_NULLS)/
           DECODE(ATC.NUM_DISTINCT,0,null,ATC.NUM_DISTINCT)/
           DECODE(AT.NUM_ROWS,0,null,AT.NUM_ROWS)
        COLUMN_SELECTIVITY,-- Column Selectivity
    ATC.DENSITY            -- Column Density (possible due to Histograms)
FROM 
    ALL_TABLES             AT,
    ALL_TAB_COLUMNS        ATC,
    ALL_IND_COLUMNS        AIC, 
    COE_INDEXES_&&initials CI -- All Indexes referenced in Explain Plan
WHERE 
    CI.INDEX_OWNER  = AIC.INDEX_OWNER 
AND CI.INDEX_NAME   = AIC.INDEX_NAME
AND CI.TABLE_OWNER  = ATC.OWNER 
AND CI.TABLE_NAME   = ATC.TABLE_NAME
AND AIC.COLUMN_NAME = ATC.COLUMN_NAME 
AND CI.TABLE_OWNER  = AT.OWNER 
AND CI.TABLE_NAME   = AT.TABLE_NAME
ORDER BY   
   CI.TABLE_NUM,
   CI.INDEX_NUM,
   AIC.COLUMN_POSITION;

PROMPT
PROMPT III.b TABLE COLUMNS
PROMPT ===================
CLEAR breaks;
SELECT
    CT.TABLE_NUM,          -- Table Number
    CT.TABLE_NAME          -- Table Name
FROM
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_all_columns'),1,1) = 'Y';

BREAK ON TABLE_NUM SKIP 1;
SELECT
    CT.TABLE_NUM,          -- Table Number
    ATC.COLUMN_ID,         -- Sequence number of column as created
    ATC.COLUMN_NAME,
    DECODE(ATC.NULLABLE,'N','NOT NULL') 
        NULLABLE,          -- NULL or NOT NULL
    ATC.DATA_TYPE||DECODE(ATC.DATA_TYPE,
        'VARCHAR2','('||ATC.DATA_LENGTH||')',
        'CHAR','('||ATC.DATA_LENGTH||')',
        'NUMBER',DECODE(ATC.DATA_PRECISION,NULL,NULL,'('||ATC.DATA_PRECISION||
           DECODE(ATC.DATA_SCALE,NULL,NULL,0,NULL,','||ATC.DATA_SCALE)||')'))
        DATA_TYPE          -- Data Type and length
FROM
    ALL_TAB_COLUMNS        ATC,
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_all_columns'),1,1) = 'Y'
AND CT.TABLE_OWNER  = ATC.OWNER
AND CT.TABLE_NAME   = ATC.TABLE_NAME
ORDER BY
    CT.TABLE_NUM,
    ATC.COLUMN_ID;

PROMPT
PROMPT III.c TABLE COLUMNS Statistics
PROMPT ==============================
CLEAR breaks;
SELECT
    CT.TABLE_NUM,          -- Table Number
    CT.TABLE_NAME          -- Table Name
FROM
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_all_columns'),1,1) = 'Y';

BREAK ON TABLE_NUM SKIP 1;
SELECT
    CT.TABLE_NUM,          -- Table Number
    ATC.COLUMN_ID,         -- Sequence number of column as created
    ATC.COLUMN_NAME,       -- Column Name
    to_char(ATC.LAST_ANALYZED,'YYYYMMDD:HH24MISS')
        LAST_ANALYZED,     -- Last Analyzed
    ATC.SAMPLE_SIZE,       -- Sample Size used when Analyzed
    ATC.AVG_COL_LEN,       -- 8.1 Average column length
    ATC.NUM_BUCKETS        -- Num. of Buckets for Histograms
FROM
    ALL_TAB_COLUMNS        ATC,
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_all_columns'),1,1) = 'Y'
AND CT.TABLE_OWNER  = ATC.OWNER 
AND CT.TABLE_NAME   = ATC.TABLE_NAME
ORDER BY
    CT.TABLE_NUM,
    ATC.COLUMN_ID;

CLEAR breaks;
SELECT
    CT.TABLE_NUM,          -- Table Number
    CT.TABLE_NAME          -- Table Name
FROM
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_all_columns'),1,1) = 'Y';

BREAK ON TABLE_NUM SKIP 1;
SELECT
    CT.TABLE_NUM,          -- Table Number
    ATC.COLUMN_ID,         -- Sequence number of column as created
    ATC.COLUMN_NAME,       -- Column Name
    ATC.NUM_NULLS,         -- Number of Rows with NULLs in this column
    AT.NUM_ROWS - ATC.NUM_NULLS
        NOT_NULLS,         -- Number of Rows with Value
    ATC.NUM_DISTINCT,      -- Number of Distinct values on this column
    CEIL((AT.NUM_ROWS-ATC.NUM_NULLS)/
           DECODE(ATC.NUM_DISTINCT,0,null,ATC.NUM_DISTINCT))
        COLUMN_CARDINALITY,-- The Lower the better.  1 is the best.
    (AT.NUM_ROWS-ATC.NUM_NULLS)/
           DECODE(ATC.NUM_DISTINCT,0,null,ATC.NUM_DISTINCT)/
           DECODE(AT.NUM_ROWS,0,null,AT.NUM_ROWS)
        COLUMN_SELECTIVITY,-- Column Selectivity
    ATC.DENSITY            -- Column Density (possible due to Histograms)
FROM
    ALL_TAB_COLUMNS        ATC,
    ALL_TABLES             AT,
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_all_columns'),1,1) = 'Y'
AND CT.TABLE_OWNER  = AT.OWNER 
AND CT.TABLE_NAME   = AT.TABLE_NAME
AND CT.TABLE_OWNER  = ATC.OWNER
AND CT.TABLE_NAME   = ATC.TABLE_NAME
ORDER BY
    CT.TABLE_NUM,
    ATC.COLUMN_ID;

/* XI. Histograms Section                                                     */
/* ===========================================================================*/
PROMPT
PROMPT IV. HISTOGRAMS
PROMPT ==============
CLEAR breaks;
SELECT
    CT.TABLE_NUM,          -- Table Number
    CT.TABLE_NAME          -- Table Name
FROM
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_histograms'),1,1) = 'Y';

BREAK ON TABLE_NUM SKIP 1;
SELECT
    CT.TABLE_NUM,          -- Table Number
    FHC.COLUMN_NAME,       -- Column Name
    FHC.PARTITION,         -- Table Partition
    FHC.HSIZE              -- Number of Buckets (Max)
FROM
    FND_HISTOGRAM_COLS  FHC,
    COE_TABLES_&&initials  CT
WHERE
    substr(upper('&include_histograms'),1,1) = 'Y'
AND CT.TABLE_NAME   = FHC.TABLE_NAME
ORDER BY
    CT.TABLE_NUM,
    FHC.COLUMN_NAME;

BREAK ON TABLE_NUM SKIP 1 ON COLUMN_ID ON COLUMN_NAME SKIP 1;
SELECT 
    CH.TABLE_NUM,          -- Table Number
    ATC.COLUMN_ID,         -- Column Id
    CH.COLUMN_NAME,        -- Column Name
    CH.ENDPOINT_NUMBER,    -- Bucket
    CH.ENDPOINT_VALUE
        endpoint_value_e,  -- Normalized numeric value (e10)
    DECODE(ATC.DATA_TYPE,'NUMBER',CH.ENDPOINT_VALUE)
        endpoint_value,    -- Normalized numeric value
    DECODE(ATC.DATA_TYPE,'DATE',
    TO_CHAR(TO_DATE(CH.ENDPOINT_JULIAN,'J'),'DD-MON-YYYY'))
        endpoint_value_d,  -- Normalized numeric value (date)
    CH.ENDPOINT_ACTUAL_VALUE -- Normalized actual value
FROM
    ALL_TAB_COLUMNS            ATC,
    COE_HISTOGRAMS_&&initials  CH
WHERE
    substr(upper('&include_histograms'),1,1) = 'Y'
AND CH.TABLE_OWNER  = ATC.OWNER
AND CH.TABLE_NAME   = ATC.TABLE_NAME
AND CH.COLUMN_NAME  = ATC.COLUMN_NAME
ORDER BY
    CH.TABLE_NUM,
    ATC.COLUMN_ID,
    CH.COLUMN_NAME,
    CH.ENDPOINT_NUMBER;

/* X. v$parameter Section                                                     */
/* ===========================================================================*/
PROMPT
PROMPT V. INIT.ORA parameters
PROMPT ======================
SELECT
    name||' = '||value vparameter,
    decode(name,
        '_sort_elimination_cost_ratio',decode(value,'5','ok','5'),
        '_optimizer_mode_force',decode(value,'TRUE','ok','TRUE'),
        '_fast_full_scan_enabled',decode(value,'FALSE','ok','FALSE'),
        '_ordered_nested_loop',decode(value,'TRUE','ok','TRUE'),
        '_complex_view_merging',decode(value,'TRUE','ok','TRUE'),
        '_push_join_predicate',decode(value,'TRUE','ok','TRUE'),
        '_use_column_stats_for_function',decode(value,'TRUE','ok','TRUE'),
        '_push_join_union_view',decode(value,'TRUE','ok','TRUE'),
        '_like_with_bind_as_equality',decode(value,'TRUE','ok','TRUE'),
        '_or_expand_nvl_predicate',decode(value,'TRUE','ok','TRUE'),
        '_table_scan_cost_plus_one',decode(value,'TRUE','ok','TRUE'),
        '_optimizer_undo_changes',decode(value,'FALSE','ok','FALSE'),
        'db_file_multiblock_read_count',decode(value,'8','ok','8'),
        'optimizer_max_permutations',decode(value,'79000','ok','79000'),
        'optimizer_mode',decode(value,'CHOOSE','ok','CHOOSE'),
        'optimizer_percent_parallel',decode(value,'0','ok','0'),
        'optimizer_features_enable',decode(value,'8.1.6','ok','8.1.6'),
        'query_rewrite_enabled',decode(value,'TRUE','ok','TRUE'),
        'compatible',decode(value,'8.1.6','ok','8.1.6'),
        null) init11i
FROM
    v$parameter
WHERE
    (   name like '_optimizer%'
     OR name like 'optimizer%'
     OR name like 'always%join'
     OR name like 'compatible'
     OR name like 'db_block_buffers'
     OR name like 'db_block_size'
     OR name like 'db_file_multiblock_read_count'
     OR name like '_complex_view_merging'
     OR name like 'complex_view_merging'
     OR name like 'cursor_sharing'
     OR name like '_fast_full_scan_enabled'
     OR name like 'fast_full_scan_enabled'
     OR name like '_ordered_nested_loop'
     OR name like 'ordered_nested_loop'
     OR name like 'hash%'
     OR name like 'max_dump_file_size'
     OR name like 'parallel%'
     OR name like 'partition_view_enabled'
     OR name like '_push_join%'
     OR name like 'push_join%'
     OR name like 'shared_pool_size'
     OR name like '_sort%'
     OR name like 'sort%'
     OR name like '_use_column_stats_for_function'
     OR name like 'use_column_stats_for_function'
     OR name like '_table_scan_cost_plus_one'
     OR name like 'table_scan_cost_plus_one'
     OR name like '_like_with_bind_as_equality'
     OR name like 'like_with_bind_as_equality'
     OR name like '_or_expand_nvl_predicate'
     OR name like 'or_expand_nvl_predicate'
     OR name like 'star_transformation_enabled'
     OR name like 'query_rewrite_enabled'
     OR name like 'user_dump_dest')
AND substr(upper('&include_vparameter'),1,1) = 'Y'
ORDER BY
    name;

/* XI. Finishing Section                                                      */
/* ===========================================================================*/
COMMIT;
SPOOL OFF;
PROMPT
PROMPT coe_statement.lst and coe_xplain.lst files have been generated.
PROMPT
PROMPT To Print them nicely, open these two files using Wordpad or Word.
PROMPT Use File -> Page Setup (menu option) to change Orientation to Landscape.
PROMPT Using same menu option make all 4 Margins 0.5".  Exit this menu option.
PROMPT Do a 'Select All' (Ctrl+A) and change Font to 'Courier New' Size 8.
PROMPT
PAUSE Hit <Enter> to close this SQL*Plus session
DROP TABLE COE_PLAN_TABLE_&&initials;
DROP TABLE COE_TABLES_&&initials;
DROP TABLE COE_INDEXES_&&initials;
exit;
/* The-End                                                                    */
