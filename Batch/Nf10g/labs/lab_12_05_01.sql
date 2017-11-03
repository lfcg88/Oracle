rem
rem Header: hr_popul.sql 09-jan-01
rem
rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
rem
rem Owner  : ahunold
rem
rem NAME
rem   hr_popul.sql - Populate script for HR schema
rem
rem DESCRIPTON
rem
rem
rem NOTES
rem   There is a circular foreign key reference between 
rem   EMPLOYESS and DEPARTMENTS. That's why we disable
rem   the FK constraints here
rem
rem CREATED
rem   Nancy Greenberg, Nagavalli Pataballa - 06/01/00
rem
rem MODIFIED   (MM/DD/YY)
rem   hyeh      08/29/02 - hyeh_mv_comschema_to_rdbms
rem   ahunold   03/07/01 - small data errors corrected
rem                      - Modified region values of countries table
rem                      - Replaced ID sequence values for employees
rem                        and departments tables with numbers
rem                      - Moved create sequence statements to hr_cre
rem                      - Removed dn values for employees and
rem                        departments tables
rem                      - Removed currency columns values from
rem                        countries table
rem   ngreenbe           - Updated employee 178 for no department
rem   pnathan            - Insert new rows to job_history table
rem   ahunold   02/20/01 - NLS_LANGUAGE, replacing non American
rem   ahunold   01/09/01 - checkin ADE

SET VERIFY OFF
ALTER SESSION SET NLS_LANGUAGE=American; 

connect hr1/hr1

REM ***************************insert data into the REGIONS table

Prompt ******  Populating REGIONS table ....

INSERT INTO br_regions VALUES 
        ( 10
        , 'Europe' 
        );

INSERT INTO br_regions VALUES 
        ( 11
        , 'Americas' 
        );

INSERT INTO br_regions VALUES 
        ( 12
        , 'Asia' 
        );

INSERT INTO br_regions VALUES 
        ( 13
        , 'Middle East and Africa' 
        );
commit;
