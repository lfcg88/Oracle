Rem	Filename : Generate_createdb.sql
Rem	Purpose	 : To reverse engineer the createdb.sql from a running database
Rem	Syntax	 : sqlplus -s / @Generate_createdb.sql
Rem		   produces an output called createdb_$ORACLE_SID.sql
Rem
Rem	Notes	 : Developed and tested on Oracle 7.3.3 for Solaris
Rem		   Autoextending files NOT catered for
Rem		   Runs ONLY catproc.sql and catalog.sql
Rem		   Assumes TEMPORARY tablespace is TEMP
Rem		   Non UNIX databases may need small modifications to the paths
Rem		   of called scripts i.e. catalog.sql, catproc.sql ... 
Rem
Rem	History  : 20-01-2000 E Augustine 	Created
Rem		   14-02-2000 E Augustine	
Rem 			Database is created in NOARCHIVELOG and then altered
Rem			to ARCHIVELOG if originally configured in ARCHIVELOG.
Rem

Set TERM On SERVEROUTPUT On Size 50000 FEEDBACK Off LINESIZE 300 TRIMSPOOL On 
Spool d:\createdb_${ORACLE_SID}.sql

Declare

	-- Non SYSTEM Tablespaces are created explicitly. 
	-- The Min(FILE_ID) is used to select the order in which Tablespaces
	-- were created.
	Cursor C_Tablespaces Is
	Select TABLESPACE_NAME, Min(FILE_ID) From DBA_DATA_FILES 
	 Where TABLESPACE_NAME Not Like 'SYSTEM%'
	 Group By TABLESPACE_NAME
 	 Order By 2;

	-- All files for a tablespace.
	Cursor C_Datafiles ( P_TS Varchar2 ) Is
	Select * From DBA_DATA_FILES 
	 Where TABLESPACE_NAME = P_TS
	 Order By FILE_ID;

	-- Tablespace information
	Cursor C_Tablespace_Info ( P_TS Varchar2 ) Is
	Select * From DBA_TABLESPACES
	 Where TABLESPACE_NAME = P_TS;

	-- SYSTEM rollback segment is created implicitly hence not selected.
	Cursor C_Rollback_Segs ( P_TS Varchar2 ) Is
	Select * From DBA_ROLLBACK_SEGS 
	 Where TABLESPACE_NAME = P_TS 
	   And SEGMENT_NAME <> 'SYSTEM'
	 Order By SEGMENT_ID;

 	Cursor C_Logfile ( L_GROUP_NUM In Varchar2 ) Is
        Select A.Group#, A.Bytes, A.Members, B.Member
          From V$LOG A, V$LOGFILE B
         Where A.Group# = B.Group#
           And A.Group# = L_GROUP_NUM
        Order By A.Group#; 

	FirstTime	Boolean;
 	L_LINE 		Varchar2(2000);		-- A line to output
	L_SID		Varchar2(20);		-- Oracle Database Name 
	L_LOGMODE	Varchar2(50);		-- Archivelog or not
	L_CHRSET	Varchar2(50);		-- NLS character set
	L_GROUPS	Number(9);		-- Nos of Log Groups
	L_LOGSIZE	Number(9);		-- Logfile size
	L_MEMBERS	Number(9);		-- Nos Members per Group
	L6		Varchar2(9);		-- 6 spaces
	L4		Varchar2(9);		-- 4 spaces
	L2		Varchar2(9);		-- 2 spaces

Begin
	L2 := '  ';
	L4 := L2||L2;
	L6 := L2||L4;
	
	L_LINE := 'Connect Internal'||Chr(10)||
		  'Set TERMOUT On ECHO On'||Chr(10)||
		  'Spool createdb_${ORACLE_SID}.log'||Chr(10)||
		  'Startup nomount pfile=../pfile/init_0.ora'||Chr(10); 
 
	dbms_output.put_line(L_LINE);

	Select NAME, LOG_MODE 
 	  Into L_SID, L_LOGMODE 
	  From V$DATABASE;

	Select VALUE Into L_CHRSET 
   	  From V$NLS_PARAMETERS
	 Where Upper(PARAMETER) = 'NLS_CHARACTERSET';

	Select Max(GROUP#), Max(MEMBERS), Max(BYTES)/1024
          Into L_GROUPS, L_MEMBERS, L_LOGSIZE
          From V$LOG;

	L_LINE := 'Create Database "'|| L_SID ||'"'|| Chr(10)||
	         L4||'Maxlogfiles    '||To_Char(L_GROUPS*L_MEMBERS*4)||Chr(10)||
	         L4||'Maxlogmembers  '||To_Char(L_MEMBERS*2)||Chr(10)||
		 L4||'Maxloghistory  160'||Chr(10)||
		 L4||'Maxdatafiles   255'||Chr(10)||
		 L4||'Maxinstances   1'||Chr(10)||
		 L4||'NOARCHIVELOG'||Chr(10)||
		 L4||'Character Set  "'||L_CHRSET||'"'||Chr(10)||
		 L4||'Datafile';

	dbms_output.put_line(L_LINE);

	--
	-- Get the datafiles for the SYSTEM tablespace
	--
	FirstTime := TRUE;
	For Rec_Datafiles In C_Datafiles ( 'SYSTEM' ) Loop

	  If FirstTime Then
	     FirstTime := FALSE;
	     L_LINE := '	';
	  Else
	     L_LINE := L_LINE||' ,'||Chr(10)||'	';
 	  End If;

	  L_LINE := L_LINE||
			 ''''||Rec_Datafiles.FILE_NAME||''''||' Size '||
		         To_Char(Rec_Datafiles.BYTES/1024)||' K';
        End Loop;

	L_LINE := L_LINE || Chr(10) || L4 || 'Logfile ';
	dbms_output.put_line(L_LINE);

	--
	-- Create the LOGFILE bits ...
	--

	FirstTime := TRUE;	-- For groups
	For L_INDEX In 1.. L_GROUPS Loop

	    If FirstTime Then
	      FirstTime := FALSE;	-- For groups
	      L_LINE := '	 Group '|| To_Char(L_INDEX) || ' (';
	    Else
	      L_LINE := '	,Group '|| To_Char(L_INDEX) || ' (';
	    End If;

	    FirstTime := TRUE;	-- For members

	    For Rec_Logfile In C_Logfile ( L_INDEX ) Loop

	      If FirstTime Then
		FirstTime := FALSE;  -- For members
	      Else
		L_LINE := L_LINE ||Chr(10)||L6||L2||'	 ,';
	      End If;

	      L_LINE := L_LINE||''''||Rec_Logfile.MEMBER||'''';

	    End Loop;   

	    L_LINE := L_LINE || Chr(10)||L6||L2||
				'	 ) Size '||To_Char(L_LOGSIZE)||' K ';
	    dbms_output.put_line(L_LINE);
	End Loop;

	--
	-- The bootstrapping stuff ... 
	--

	L_LINE := '/'||Chr(10)||Chr(10)||
		     'Set TERMOUT Off ECHO Off'||Chr(10)||
		     '@?/rdbms/admin/catalog.sql'||Chr(10)||
		     '@?/rdbms/admin/catproc.sql'||Chr(10)||
		     'Set TERMOUT On ECHO On'||Chr(10)||Chr(10);	

	dbms_output.put_line(L_LINE);

	--
	-- The Rollback segments in the SYSTEM tablespace 
	--

        For Rec_RBS In C_Rollback_Segs ('SYSTEM') Loop

          L_LINE := 'Create Rollback Segment '||Rec_RBS.SEGMENT_NAME||
		   	 Chr(10)||'  Tablespace '||
			 Rec_RBS.TABLESPACE_NAME||
			 Chr(10)||'  '||'Storage (';

	  L_LINE := L_LINE||Chr(10)||'    Initial     '||
			     To_Char(Rec_RBS.INITIAL_EXTENT/1024)||' K'||
			 Chr(10)||'    Next        '||
			     To_Char(Rec_RBS.NEXT_EXTENT/1024)||' K'||
			 Chr(10)||'    Minextents  '||
			     To_Char(Rec_RBS.MIN_EXTENTS)||
			 Chr(10)||'    Maxextents  '||
			     To_Char(Rec_RBS.MAX_EXTENTS)||
			 Chr(10)||'    Optimal     '||
			     To_Char(Rec_RBS.MIN_EXTENTS * 
				     Rec_RBS.NEXT_EXTENT/1024)||' K'||Chr(10)
			 ||'          )'||Chr(10)||'/'||Chr(10)
			 ;
	  dbms_output.put_line(L_LINE);

        End Loop;

	--
	-- Create all other tablespaces ...
	--

	For Rec_Tablespaces In C_Tablespaces Loop

	  L_LINE := 'Create Tablespace '||Rec_Tablespaces.TABLESPACE_NAME;

	  dbms_output.put_line(L_LINE);

	  FirstTime := TRUE;
	  For Rec_Datafiles In 
		C_Datafiles ( Rec_Tablespaces.TABLESPACE_NAME ) Loop

	    If FirstTime Then
	 	FirstTime := FALSE;
		L_LINE := ' Datafile ';
	    Else
	 	L_LINE := '	,';
 	    End If;

	    L_LINE := L_LINE||''''||Rec_Datafiles.FILE_NAME||''''||
			 ' Size '||
		         To_Char(Rec_Datafiles.BYTES/1024)||' K';
	    dbms_output.put_line(L_LINE);

	  End Loop;


	  For Rec_TS_Info In 
		C_Tablespace_Info( Rec_Tablespaces.TABLESPACE_NAME ) Loop

	    L_LINE :='    Default Storage ( '||
			Chr(10)||'    Initial     '||
			     To_Char(Rec_TS_Info.INITIAL_EXTENT/1024)||' K'||
			Chr(10)||'    Next        '||
			     To_Char(Rec_TS_Info.NEXT_EXTENT/1024)||' K'||
			Chr(10)||'    Minextents  '||
			     To_Char(Rec_TS_Info.MIN_EXTENTS)||
			Chr(10)||'    Maxextents  '||
			     To_Char(Rec_TS_Info.MAX_EXTENTS)||
			Chr(10)||'    Pctincrease '||
			     To_Char(Rec_TS_Info.PCT_INCREASE)||
			Chr(10)||
			'                )'
			;
			
	    L_LINE := L_LINE||Chr(10)||' '||
			Rec_TS_Info.CONTENTS||Chr(10)||'/'||Chr(10)||Chr(10);
	    dbms_output.put_line(L_LINE);

	  End Loop;
	
	  -- 
	  -- Create all Rollback segments in the tablespace being created ...
	  --

	  For Rec_RBS In C_Rollback_Segs (Rec_Tablespaces.TABLESPACE_NAME) Loop

	    L_LINE := 'Create Rollback Segment '||Rec_RBS.SEGMENT_NAME||
		   	 Chr(10)||'  Tablespace '||
			 Rec_RBS.TABLESPACE_NAME||
			 Chr(10)||'  '||'Storage (';

	    L_LINE := L_LINE||Chr(10)||'    Initial     '||
			     To_Char(Rec_RBS.INITIAL_EXTENT/1024)||' K'||
			 Chr(10)||'    Next        '||
			     To_Char(Rec_RBS.NEXT_EXTENT/1024)||' K'||
			 Chr(10)||'    Minextents  '||
			     To_Char(Rec_RBS.MIN_EXTENTS)||
			 Chr(10)||'    Maxextents  '||
			     To_Char(Rec_RBS.MAX_EXTENTS)||
			 Chr(10)||'    Optimal     '||
			     To_Char(Rec_RBS.MIN_EXTENTS * 
				     Rec_RBS.NEXT_EXTENT/1024)||' K'||Chr(10)
			 ||'          )'||Chr(10)||'/'||Chr(10)
			 ;
	    dbms_output.put_line(L_LINE);

          End Loop;

	End Loop;

	L_LINE := 'Alter User SYS Temporary Tablespace TEMP'||
		   Chr(10)||'/'||Chr(10)||
	          'Alter User SYSTEM Default Tablespace TOOLS '||Chr(10)||
		  'Temporary Tablespace TEMP'||
		   Chr(10)||'/'||Chr(10)||Chr(10);

	dbms_output.put_line(L_LINE);

	L_LINE := 'Connect System/Manager'||Chr(10)||
		  'Set TERMOUT Off ECHO Off'||Chr(10)||
		  '@?/rdbms/admin/catdbsyn'||Chr(10)||
		  '@?/sqlplus/admin/pupbld'||Chr(10)||
		  'Set TERMOUT On ECHO On'||Chr(10);

	dbms_output.put_line(L_LINE);

	L_LINE := 'Connect Internal'||Chr(10)||
		  'Shutdown'||Chr(10)||
		  'Startup'||Chr(10)||Chr(10);

	dbms_output.put_line(L_LINE);

	If L_LOGMODE = 'ARCHIVELOG' Then
	  L_LINE := 'Shutdown immediate'||Chr(10)||
                    'Startup Mount'||Chr(10)||
                    'Alter Database ARCHIVELOG;'||Chr(10)||
                    'Alter Database Open;'||Chr(10);
	  dbms_output.put_line(L_LINE);
	End If;

	L_LINE := 'Create User OPS$ORACLE Identified Externally'||Chr(10)||
		  'Default Tablespace TOOLS'||Chr(10)||
		  'Temporary Tablespace TEMP'||Chr(10)||'/'||Chr(10)||
		  'Grant DBA To OPS$ORACLE'||Chr(10)||'/'||Chr(10)||Chr(10);

	dbms_output.put_line(L_LINE);

	L_LINE := 'Spool Off'||Chr(10)||'Exit'||Chr(10);

	dbms_output.put_line(L_LINE);
End;
/
Spool Off
Exit
