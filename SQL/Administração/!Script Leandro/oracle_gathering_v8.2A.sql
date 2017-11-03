-- =====================================================================================
-- Oracle Database Gathering Script v2 - Sep2010
--
-- Updated by Reinaldo on Oct2010 - Gather default passwords on 11g
-- Updated by Rodrigo on Nov2010  - Total Users in Profiles
-- =====================================================================================


SET SERVEROUTPUT ON

clear col


SET HEAD on
set feed off

set verify off
set termout off

set pages 50000

COL DATABASE NEW_VALUE INSTANCIA
SELECT INSTANCE_NAME DATABASE
FROM V$INSTANCE
/

COL HOST NEW_VALUE MAQUINA
SELECT HOST_NAME HOST
FROM V$INSTANCE
/

COL VER NEW_VALUE VERSAO
SELECT VERSION VER
FROM V$INSTANCE
/

COL DATA NEW_VALUE DATA
SELECT to_char(SYSDATE, 'DD-MON-YYYY') DATA
FROM DUAL
/


COLUMN ipaddr     	FORMAT A15 HEADING "IP Address"
COLUMN host_os       	FORMAT A30 HEADING "Host"
COLUMN netprtc    	FORMAT A12  HEADING "Network|Protocol"
COLUMN curruser   	FORMAT A20  HEADING "Current|User"
COLUMN currschema 	FORMAT A12  HEADING "Current|Schema"
COLUMN fgjob      	FORMAT A4  HEADING "FG|Job?"
COLUMN bgjob      	FORMAT A4  HEADING "BG|Job?"


set termout off
	prompt HOST: &MAQUINA.
	prompt 
	prompt INSTANCE: &INSTANCIA. 
	prompt 
	prompt VERSION: &VERSAO.
	prompt 
	PROMPT DATE: &DATA.
	prompt 

spool  &MAQUINA._&INSTANCIA..htm
	prompt <i>ver: 8.2</i>
	prompt <hr>
	prompt
	prompt
	prompt <html>
	prompt <a name=top></a>
	prompt 
	prompt <b> HOST: &MAQUINA. </b>
	prompt <hr>
	prompt <b> INSTANCE: &INSTANCIA. </b>
	prompt <hr>
	prompt <b> VERSION: &VERSAO. </b>
	prompt <hr>
	PROMPT <b> DATE: &DATA. </b>
	prompt <hr>

	prompt <pre>
	prompt 
	select banner from v$version;
	prompt 
	prompt

-- ======================================
-- =    VERSIONS COMPATIBILITY          =
-- ======================================


DECLARE

V_MACHINE varchar2(30);
V_USER varchar2(30);


	BEGIN

		select user into V_USER from dual;
		select distinct machine into V_MACHINE from v$session where username = (select user from dual) and rownum=1;
		
		
		dbms_output.put_line('.CLIENT_CONFIGURATION.');
		dbms_output.put_line('----------------------');
		dbms_output.put_line(rpad('CURRENT_USER',30,' ')||rpad('HOST',30,' '));
		dbms_output.put_line(rpad('-----------------------------',30,' ')||rpad('---------------------------',30,' '));
		dbms_output.put_line(rpad(V_USER,30,' ')||rpad(V_MACHINE,30,' '));

	END;
/
		prompt 
		prompt 
		prompt </pre>
		prompt <hr>
		prompt <hr>

--- =========================================
--- =========================================
--- =====        DEFAULT PASSWORDS    =======
--- =========================================
--- =========================================


-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting default passwords...
	prompt 
	prompt
set termout off

clear col

set linesize 50

set linesize 80
set serveroutput  on format wrapped size  1000000


	prompt <br>
	prompt
	prompt <b>.DEFAULT PASSWORDS.</b>
	prompt
	prompt <pre>



declare
	type user_tab is table of varchar2(30) index by binary_integer;
	type pwd_tab is table of varchar2(30) index by binary_integer;
	type sta_tab is table of varchar2(30) index by binary_integer;
	type hash_tab is table of varchar2(16) index by binary_integer;
	
	username user_tab;
	password pwd_tab;
	account_status sta_tab;
	hash hash_tab;
	
	tab_key binary_integer:=1;
	i binary_integer:=1;
	--
  	cursor  c_user is
		select 	dba_users.username, dba_users.account_status,case when (substr(v$instance.version,1,2))=11
                                            then user$.password
                                            else dba_users.password
                                            end as password
		 from	dba_users, user$, v$instance
     	where dba_users.username = user$.name;
     
	--
	found 	number:=0;
	--

begin
----------------------
tab_key:=1;
username(tab_key):='!DEMO_USER';
password(tab_key):='!DEMO_USER';
hash(tab_key):='F5815FA39C791FED';
----------------------
tab_key:=2;
username(tab_key):='#INTERNAL';
password(tab_key):='ORACLE';
hash(tab_key):='87DADF57B623B777';
----------------------
tab_key:=3;
username(tab_key):='#INTERNAL';
password(tab_key):='SYS_STNT';
hash(tab_key):='38379FC3621F7DA2';
----------------------
tab_key:=4;
username(tab_key):='ABM';
password(tab_key):='ABM';
hash(tab_key):='D0F2982F121C7840';
----------------------
tab_key:=5;
username(tab_key):='ADAMS';
password(tab_key):='WOOD';
hash(tab_key):='72CDEF4A3483F60D';
----------------------
tab_key:=6;
username(tab_key):='ADAMS';
password(tab_key):='ADAMS';
hash(tab_key):='0CDB0D6C522BEF86';
----------------------
tab_key:=7;
username(tab_key):='ADLDEMO';
password(tab_key):='ADLDEMO';
hash(tab_key):='147215F51929A6E8';
----------------------
tab_key:=8;
username(tab_key):='ADMIN';
password(tab_key):='JETSPEED';
hash(tab_key):='CAC22318F162D597';
----------------------
tab_key:=9;
username(tab_key):='ADMIN';
password(tab_key):='ADMIN';
hash(tab_key):='95F3C64472751462';
----------------------
tab_key:=10;
username(tab_key):='ADMIN';
password(tab_key):='WELCOME';
hash(tab_key):='B8B15AC9A946886A';
----------------------
tab_key:=11;
username(tab_key):='ADMINISTRATOR';
password(tab_key):='ADMIN';
hash(tab_key):='F9ED601D936158BD';
----------------------
tab_key:=12;
username(tab_key):='ADMINISTRATOR';
password(tab_key):='ADMINISTRATOR';
hash(tab_key):='1848F0A31D1C5C62';
----------------------
tab_key:=13;
username(tab_key):='AHL';
password(tab_key):='AHL';
hash(tab_key):='7910AE63C9F7EEEE';
----------------------
tab_key:=14;
username(tab_key):='AHM';
password(tab_key):='AHM';
hash(tab_key):='33C2E27CF5E401A4';
----------------------
tab_key:=15;
username(tab_key):='AK';
password(tab_key):='AK';
hash(tab_key):='8FCB78BBA8A59515';
----------------------
tab_key:=16;
username(tab_key):='ALHRO';
password(tab_key):='XXX';
hash(tab_key):='049B2397FB1A419E';
----------------------
tab_key:=17;
username(tab_key):='ALHRW';
password(tab_key):='XXX';
hash(tab_key):='B064872E7F344CAE';
----------------------
tab_key:=18;
username(tab_key):='ALR';
password(tab_key):='ALR';
hash(tab_key):='BE89B24F9F8231A9';
----------------------
tab_key:=19;
username(tab_key):='AMS';
password(tab_key):='AMS';
hash(tab_key):='BD821F59270E5F34';
----------------------
tab_key:=20;
username(tab_key):='AMV';
password(tab_key):='AMV';
hash(tab_key):='38BC87EB334A1AC4';
----------------------
tab_key:=21;
username(tab_key):='ANDY';
password(tab_key):='SWORDFISH';
hash(tab_key):='B8527562E504BC3F';
----------------------
tab_key:=22;
username(tab_key):='ANONYMOUS';
password(tab_key):='ANONYMOUS';
hash(tab_key):='FE0E8CE7C92504E9';
----------------------
tab_key:=23;
username(tab_key):='AP';
password(tab_key):='AP';
hash(tab_key):='EED09A552944B6AD';
----------------------
tab_key:=24;
username(tab_key):='APPLMGR';
password(tab_key):='APPLMGR';
hash(tab_key):='CB562C240E871070';
----------------------
tab_key:=25;
username(tab_key):='APPLSYS';
password(tab_key):='FND';
hash(tab_key):='0F886772980B8C79';
----------------------
tab_key:=26;
username(tab_key):='APPLSYS';
password(tab_key):='APPLSYS';
hash(tab_key):='FE84888987A6BF5A';
----------------------
tab_key:=27;
username(tab_key):='APPLSYS';
password(tab_key):='APPS';
hash(tab_key):='E153FFF4DAE6C9F7';
----------------------
tab_key:=28;
username(tab_key):='APPLSYSPUB';
password(tab_key):='PUB';
hash(tab_key):='D2E3EF40EE87221E';
----------------------
tab_key:=29;
username(tab_key):='APPLSYSPUB';
password(tab_key):='APPLSYSPUB';
hash(tab_key):='D5DB40BB03EA1270';
----------------------
tab_key:=30;
username(tab_key):='APPLSYSPUB';
password(tab_key):='FNDPUB';
hash(tab_key):='78194639B5C3DF9F';
----------------------
tab_key:=31;
username(tab_key):='APPLYSYSPUB';
password(tab_key):='PUB';
hash(tab_key):='A5E09E84EC486FC9';
----------------------
tab_key:=32;
username(tab_key):='APPLYSYSPUB';
password(tab_key):='APPLYSYSPUB';
hash(tab_key):='315ECD223BB3DFA9';
----------------------
tab_key:=33;
username(tab_key):='APPLYSYSPUB';
password(tab_key):='FNDPUB';
hash(tab_key):='78194639B5C3DF9F';
----------------------
tab_key:=34;
username(tab_key):='APPLYSYSPUB';
password(tab_key):='<UNKNOWN>';
hash(tab_key):='D2E3EF40EE87221E';
----------------------
tab_key:=35;
username(tab_key):='APPS';
password(tab_key):='APPS';
hash(tab_key):='D728438E8A5925E0';
----------------------
tab_key:=36;
username(tab_key):='APPS_MRC';
password(tab_key):='APPS';
hash(tab_key):='2FFDCBB4FD11D9DC';
----------------------
tab_key:=37;
username(tab_key):='APPUSER';
password(tab_key):='APPPASSWORD';
hash(tab_key):='7E2C3C2D4BF4071B';
----------------------
tab_key:=38;
username(tab_key):='AQ';
password(tab_key):='AQ';
hash(tab_key):='2B0C31040A1CFB48';
----------------------
tab_key:=39;
username(tab_key):='AQDEMO';
password(tab_key):='AQDEMO';
hash(tab_key):='5140E342712061DD';
----------------------
tab_key:=40;
username(tab_key):='AQJAVA';
password(tab_key):='AQJAVA';
hash(tab_key):='8765D2543274B42E';
----------------------
tab_key:=41;
username(tab_key):='AQUSER';
password(tab_key):='AQUSER';
hash(tab_key):='4CF13BDAC1D7511C';
----------------------
tab_key:=42;
username(tab_key):='AR';
password(tab_key):='AR';
hash(tab_key):='BBBFE175688DED7E';
----------------------
tab_key:=43;
username(tab_key):='ASF';
password(tab_key):='ASF';
hash(tab_key):='B6FD427D08619EEE';
----------------------
tab_key:=44;
username(tab_key):='ASG';
password(tab_key):='ASG';
hash(tab_key):='1EF8D8BD87CF16BE';
----------------------
tab_key:=45;
username(tab_key):='ASL';
password(tab_key):='ASL';
hash(tab_key):='03B20D2C323D0BFE';
----------------------
tab_key:=46;
username(tab_key):='ASO';
password(tab_key):='ASO';
hash(tab_key):='F712D80109E3C9D8';
----------------------
tab_key:=47;
username(tab_key):='ASP';
password(tab_key):='ASP';
hash(tab_key):='CF95D2C6C85FF513';
----------------------
tab_key:=48;
username(tab_key):='AST';
password(tab_key):='AST';
hash(tab_key):='F13FF949563EAB3C';
----------------------
tab_key:=49;
username(tab_key):='ATM';
password(tab_key):='SAMPLEATM';
hash(tab_key):='7B83A0860CF3CB71';
----------------------
tab_key:=50;
username(tab_key):='AUDIOUSER';
password(tab_key):='AUDIOUSER';
hash(tab_key):='CB4F2CEC5A352488';
----------------------
tab_key:=51;
username(tab_key):='AURORA$JIS$UTILITY$';
password(tab_key):='invalid';
hash(tab_key):='E1BAE6D95AA95F1E';
----------------------
tab_key:=52;
username(tab_key):='AURORA$JIS$UTILITY$';
password(tab_key):='AURORA$JIS$UTILITY$';
hash(tab_key):='A150AF65C4F8F54B';
----------------------
tab_key:=53;
username(tab_key):='AURORA$ORB$UNAUTHENTICATED';
password(tab_key):='INVALID';
hash(tab_key):='80C099F0EADF877E';
----------------------
tab_key:=54;
username(tab_key):='AURORA$ORB$UNAUTHENTICATED';
password(tab_key):='AURORA$ORB$UNAUTHENTICATED';
hash(tab_key):='64A31D2239848B2D';
----------------------
tab_key:=55;
username(tab_key):='AX';
password(tab_key):='AX';
hash(tab_key):='0A8303530E86FCDD';
----------------------
tab_key:=56;
username(tab_key):='AZ';
password(tab_key):='AZ';
hash(tab_key):='AAA18B5D51B0D5AC';
----------------------
tab_key:=57;
username(tab_key):='BACKUP';
password(tab_key):='BACKUP';
hash(tab_key):='6E8300C33A27325E';
----------------------
tab_key:=58;
username(tab_key):='BC4J';
password(tab_key):='BC4J';
hash(tab_key):='EAA333E83BF2810D';
----------------------
tab_key:=59;
username(tab_key):='BEN';
password(tab_key):='BEN';
hash(tab_key):='9671866348E03616';
----------------------
tab_key:=60;
username(tab_key):='BIC';
password(tab_key):='BIC';
hash(tab_key):='E84CC95CBBAC1B67';
----------------------
tab_key:=61;
username(tab_key):='BIL';
password(tab_key):='BIL';
hash(tab_key):='BF24BCE2409BE1F7';
----------------------
tab_key:=62;
username(tab_key):='BIM';
password(tab_key):='BIM';
hash(tab_key):='6026F9A8A54B9468';
----------------------
tab_key:=63;
username(tab_key):='BIS';
password(tab_key):='BIS';
hash(tab_key):='7E9901882E5F3565';
----------------------
tab_key:=64;
username(tab_key):='BIV';
password(tab_key):='BIV';
hash(tab_key):='2564B34BE50C2524';
----------------------
tab_key:=65;
username(tab_key):='BIX';
password(tab_key):='BIX';
hash(tab_key):='3DD36935EAEDE2E3';
----------------------
tab_key:=66;
username(tab_key):='BLAKE';
password(tab_key):='PAPER';
hash(tab_key):='9435F2E60569158E';
----------------------
tab_key:=67;
username(tab_key):='BLAKE';
password(tab_key):='BLAKE';
hash(tab_key):='4B46E4AD436310D3';
----------------------
tab_key:=68;
username(tab_key):='BLEWIS';
password(tab_key):='BLEWIS';
hash(tab_key):='C9B597D7361EE067';
----------------------
tab_key:=69;
username(tab_key):='BOM';
password(tab_key):='BOM';
hash(tab_key):='56DB3E89EAE5788E';
----------------------
tab_key:=70;
username(tab_key):='BRIO_ADMIN';
password(tab_key):='BRIO_ADMIN';
hash(tab_key):='EB50644BE27DF70B';
----------------------
tab_key:=71;
username(tab_key):='BRUGERNAVN';
password(tab_key):='ADGANGSKODE';
hash(tab_key):='2F11631B6B4E0B6F';
----------------------
tab_key:=72;
username(tab_key):='BRUKERNAVN';
password(tab_key):='PASSWORD';
hash(tab_key):='652C49CDF955F83A';
----------------------
tab_key:=73;
username(tab_key):='BSC';
password(tab_key):='BSC';
hash(tab_key):='EC481FD7DCE6366A';
----------------------
tab_key:=74;
username(tab_key):='BUG_REPORTS';
password(tab_key):='BUG_REPORTS';
hash(tab_key):='E9473A88A4DD31F2';
----------------------
tab_key:=75;
username(tab_key):='CALVIN';
password(tab_key):='HOBBES';
hash(tab_key):='34200F94830271A3';
----------------------
tab_key:=76;
username(tab_key):='CATALOG';
password(tab_key):='CATALOG';
hash(tab_key):='397129246919E8DA';
----------------------
tab_key:=77;
username(tab_key):='CCT';
password(tab_key):='CCT';
hash(tab_key):='C6AF8FCA0B51B32F';
----------------------
tab_key:=78;
username(tab_key):='CDEMO82';
password(tab_key):='CDEMO83';
hash(tab_key):='67B891F114BE3AEB';
----------------------
tab_key:=79;
username(tab_key):='CDEMO82';
password(tab_key):='CDEMO82';
hash(tab_key):='7299A5E2A5A05820';
----------------------
tab_key:=80;
username(tab_key):='CDEMO82';
password(tab_key):='UNKNOWN';
hash(tab_key):='73EAE7C39B42EA15';
----------------------
tab_key:=81;
username(tab_key):='CDEMOCOR';
password(tab_key):='CDEMOCOR';
hash(tab_key):='3A34F0B26B951F3F';
----------------------
tab_key:=82;
username(tab_key):='CDEMORID';
password(tab_key):='CDEMORID';
hash(tab_key):='E39CEFE64B73B308';
----------------------
tab_key:=83;
username(tab_key):='CDEMOUCB';
password(tab_key):='CDEMOUCB';
hash(tab_key):='CEAE780F25D556F8';
----------------------
tab_key:=84;
username(tab_key):='CDOUGLAS';
password(tab_key):='CDOUGLAS';
hash(tab_key):='C35109FE764ED61E';
----------------------
tab_key:=85;
username(tab_key):='CE';
password(tab_key):='CE';
hash(tab_key):='E7FDFE26A524FE39';
----------------------
tab_key:=86;
username(tab_key):='CENTRA';
password(tab_key):='CENTRA';
hash(tab_key):='63BF5FFE5E3EA16D';
----------------------
tab_key:=87;
username(tab_key):='CENTRAL';
password(tab_key):='CENTRAL';
hash(tab_key):='A98B26E2F65CA4D3';
----------------------
tab_key:=88;
username(tab_key):='CIDS';
password(tab_key):='CIDS';
hash(tab_key):='AA71234EF06CE6B3';
----------------------
tab_key:=89;
username(tab_key):='CIS';
password(tab_key):='ZWERG';
hash(tab_key):='AA2602921607EE84';
----------------------
tab_key:=90;
username(tab_key):='CIS';
password(tab_key):='CIS';
hash(tab_key):='7653EBAF048F0A10';
----------------------
tab_key:=91;
username(tab_key):='CISINFO';
password(tab_key):='ZWERG';
hash(tab_key):='BEA52A368C31B86F';
----------------------
tab_key:=92;
username(tab_key):='CISINFO';
password(tab_key):='CISINFO';
hash(tab_key):='3AA26FC267C5F577';
----------------------
tab_key:=93;
username(tab_key):='CLARK';
password(tab_key):='CLOTH';
hash(tab_key):='7AAFE7D01511D73F';
----------------------
tab_key:=94;
username(tab_key):='CLARK';
password(tab_key):='CLARK';
hash(tab_key):='74DF527800B6D713';
----------------------
tab_key:=95;
username(tab_key):='CLKANA';
password(tab_key):='CLKANA';
hash(tab_key):='541F6C43BA6A452C';
----------------------
tab_key:=96;
username(tab_key):='CLKRT';
password(tab_key):='CLKRT';
hash(tab_key):='1AB4FB99AA8815A6';
----------------------
tab_key:=97;
username(tab_key):='CN';
password(tab_key):='CN';
hash(tab_key):='73F284637A54777D';
----------------------
tab_key:=98;
username(tab_key):='COMPANY';
password(tab_key):='COMPANY';
hash(tab_key):='402B659C15EAF6CB';
----------------------
tab_key:=99;
username(tab_key):='COMPIERE';
password(tab_key):='COMPIERE';
hash(tab_key):='E3D0DCF4B4DBE626';
----------------------
tab_key:=100;
username(tab_key):='CQSCHEMAUSER';
password(tab_key):='PASSWORD';
hash(tab_key):='04071E7EDEB2F5CC';
----------------------
tab_key:=101;
username(tab_key):='CQUSERDBUSER';
password(tab_key):='PASSWORD';
hash(tab_key):='0273F484CD3F44B7';
----------------------
tab_key:=102;
username(tab_key):='CRP';
password(tab_key):='CRP';
hash(tab_key):='F165BDE5462AD557';
----------------------
tab_key:=103;
username(tab_key):='CS';
password(tab_key):='CS';
hash(tab_key):='DB78866145D4E1C3';
----------------------
tab_key:=104;
username(tab_key):='CSC';
password(tab_key):='CSC';
hash(tab_key):='EDECA9762A8C79CD';
----------------------
tab_key:=105;
username(tab_key):='CSD';
password(tab_key):='CSD';
hash(tab_key):='144441CEBAFC91CF';
----------------------
tab_key:=106;
username(tab_key):='CSE';
password(tab_key):='CSE';
hash(tab_key):='D8CC61E8F42537DA';
----------------------
tab_key:=107;
username(tab_key):='CSF';
password(tab_key):='CSF';
hash(tab_key):='684E28B3C899D42C';
----------------------
tab_key:=108;
username(tab_key):='CSI';
password(tab_key):='CSI';
hash(tab_key):='71C2B12C28B79294';
----------------------
tab_key:=109;
username(tab_key):='CSL';
password(tab_key):='CSL';
hash(tab_key):='C4D7FE062EFB85AB';
----------------------
tab_key:=110;
username(tab_key):='CSMIG';
password(tab_key):='CSMIG';
hash(tab_key):='09B4BB013FBD0D65';
----------------------
tab_key:=111;
username(tab_key):='CSP';
password(tab_key):='CSP';
hash(tab_key):='5746C5E077719DB4';
----------------------
tab_key:=112;
username(tab_key):='CSR';
password(tab_key):='CSR';
hash(tab_key):='0E0F7C1B1FE3FA32';
----------------------
tab_key:=113;
username(tab_key):='CSS';
password(tab_key):='CSS';
hash(tab_key):='3C6B8C73DDC6B04F';
----------------------
tab_key:=114;
username(tab_key):='CTXDEMO';
password(tab_key):='CTXDEMO';
hash(tab_key):='CB6B5E9D9672FE89';
----------------------
tab_key:=115;
username(tab_key):='CTXSYS';
password(tab_key):='CTXSYS';
hash(tab_key):='24ABAB8B06281B4C';
----------------------
tab_key:=116;
username(tab_key):='CTXSYS';
password(tab_key):='ORACLE';
hash(tab_key):='D1D21CA56994CAB6';
----------------------
tab_key:=117;
username(tab_key):='CTXSYS';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='71E687F036AD56E5';
----------------------
tab_key:=118;
username(tab_key):='CTXSYS';
password(tab_key):='UNKNOWN';
hash(tab_key):='A13C035631643BA0';
----------------------
tab_key:=119;
username(tab_key):='CUA';
password(tab_key):='CUA';
hash(tab_key):='CB7B2E6FFDD7976F';
----------------------
tab_key:=120;
username(tab_key):='CUE';
password(tab_key):='CUE';
hash(tab_key):='A219FE4CA25023AA';
----------------------
tab_key:=121;
username(tab_key):='CUF';
password(tab_key):='CUF';
hash(tab_key):='82959A9BD2D51297';
----------------------
tab_key:=122;
username(tab_key):='CUG';
password(tab_key):='CUG';
hash(tab_key):='21FBCADAEAFCC489';
----------------------
tab_key:=123;
username(tab_key):='CUI';
password(tab_key):='CUI';
hash(tab_key):='AD7862E01FA80912';
----------------------
tab_key:=124;
username(tab_key):='CUN';
password(tab_key):='CUN';
hash(tab_key):='41C2D31F3C85A79D';
----------------------
tab_key:=125;
username(tab_key):='CUP';
password(tab_key):='CUP';
hash(tab_key):='C03082CD3B13EC42';
----------------------
tab_key:=126;
username(tab_key):='CUS';
password(tab_key):='CUS';
hash(tab_key):='00A12CC6EBF8EDB8';
----------------------
tab_key:=127;
username(tab_key):='CZ';
password(tab_key):='CZ';
hash(tab_key):='9B667E9C5A0D21A6';
----------------------
tab_key:=128;
username(tab_key):='DBI';
password(tab_key):='MUMBLEFRATZ';
hash(tab_key):='D8FF6ECEF4C50809';
----------------------
tab_key:=129;
username(tab_key):='DBI';
password(tab_key):='DBI';
hash(tab_key):='35C0679701A91877';
----------------------
tab_key:=130;
username(tab_key):='DBSNMP';
password(tab_key):='DBSNMP';
hash(tab_key):='E066D214D5421CCC';
----------------------
tab_key:=131;
username(tab_key):='DBVISION';
password(tab_key):='DBVISION';
hash(tab_key):='F74F7EF36A124931';
----------------------
tab_key:=132;
username(tab_key):='DCM';
password(tab_key):='DCM';
hash(tab_key):='D1D21CA56994CAB6';
----------------------
tab_key:=133;
username(tab_key):='DDIC';
password(tab_key):='199220706';
hash(tab_key):='4F9FFB093F909574';
----------------------
tab_key:=134;
username(tab_key):='DEMO';
password(tab_key):='DEMO';
hash(tab_key):='4646116A123897CF';
----------------------
tab_key:=135;
username(tab_key):='DEMO8';
password(tab_key):='DEMO9';
hash(tab_key):='565E954402719CAA';
----------------------
tab_key:=136;
username(tab_key):='DEMO8';
password(tab_key):='DEMO8';
hash(tab_key):='0E7260738FDFD678';
----------------------
tab_key:=137;
username(tab_key):='DEMO9';
password(tab_key):='DEMO9';
hash(tab_key):='EE02531A80D998CA';
----------------------
tab_key:=138;
username(tab_key):='DES';
password(tab_key):='DES';
hash(tab_key):='ABFEC5AC2274E54D';
----------------------
tab_key:=139;
username(tab_key):='DES2K';
password(tab_key):='DES2K';
hash(tab_key):='611E7A73EC4B425A';
----------------------
tab_key:=140;
username(tab_key):='DEV2000_DEMOS';
password(tab_key):='DEV2000_DEMOS';
hash(tab_key):='18A0C8BD6B13BEE2';
----------------------
tab_key:=141;
username(tab_key):='DIANE';
password(tab_key):='PASSWO1';
hash(tab_key):='46DC27700F2ADE28';
----------------------
tab_key:=142;
username(tab_key):='DIP';
password(tab_key):='DIP';
hash(tab_key):='CE4A36B8E06CA59C';
----------------------
tab_key:=143;
username(tab_key):='DISCOVERER_ADMIN';
password(tab_key):='DISCOVERER_ADMIN';
hash(tab_key):='5C1AED4D1AADAA4C';
----------------------
tab_key:=144;
username(tab_key):='DISCOVERER5';
password(tab_key):='DISCOVERER5';
hash(tab_key):='AF0EDB66D914B731';
----------------------
tab_key:=145;
username(tab_key):='DMSYS';
password(tab_key):='DMSYS';
hash(tab_key):='BFBA5A553FD9E28A';
----------------------
tab_key:=146;
username(tab_key):='DPF';
password(tab_key):='DPFPASS';
hash(tab_key):='E53F7C782FAA6898';
----------------------
tab_key:=147;
username(tab_key):='DSGATEWAY';
password(tab_key):='DSGATEWAY';
hash(tab_key):='6869F3CFD027983A';
----------------------
tab_key:=148;
username(tab_key):='DSSYS';
password(tab_key):='DSSYS';
hash(tab_key):='E3B6E6006B3A99E0';
----------------------
tab_key:=149;
username(tab_key):='DTSP';
password(tab_key):='DTSP';
hash(tab_key):='5A40D4065B3673D2';
----------------------
tab_key:=150;
username(tab_key):='EAA';
password(tab_key):='EAA';
hash(tab_key):='A410B2C5A0958CDF';
----------------------
tab_key:=151;
username(tab_key):='EAM';
password(tab_key):='EAM';
hash(tab_key):='CE8234D92FCFB563';
----------------------
tab_key:=152;
username(tab_key):='EARLYWATCH';
password(tab_key):='SUPPORT';
hash(tab_key):='8AA1C62E08C76445';
----------------------
tab_key:=153;
username(tab_key):='EAST';
password(tab_key):='EAST';
hash(tab_key):='C5D5C455A1DE5F4D';
----------------------
tab_key:=154;
username(tab_key):='EC';
password(tab_key):='EC';
hash(tab_key):='6A066C462B62DD46';
----------------------
tab_key:=155;
username(tab_key):='ECX';
password(tab_key):='ECX';
hash(tab_key):='0A30645183812087';
----------------------
tab_key:=156;
username(tab_key):='EJB';
password(tab_key):='EJB';
hash(tab_key):='69CB07E2162C6C93';
----------------------
tab_key:=157;
username(tab_key):='EJSADMIN';
password(tab_key):='EJSADMIN_PASSWORD';
hash(tab_key):='313F9DFD92922CD2';
----------------------
tab_key:=158;
username(tab_key):='EJSADMIN';
password(tab_key):='EJSADMIN';
hash(tab_key):='4C59B97125B6641A';
----------------------
tab_key:=159;
username(tab_key):='EMP';
password(tab_key):='EMP';
hash(tab_key):='B40C23C6E2B4EA3D';
----------------------
tab_key:=160;
username(tab_key):='ENG';
password(tab_key):='ENG';
hash(tab_key):='4553A3B443FB3207';
----------------------
tab_key:=161;
username(tab_key):='ENI';
password(tab_key):='ENI';
hash(tab_key):='05A92C0958AFBCBC';
----------------------
tab_key:=162;
username(tab_key):='ESTOREUSER';
password(tab_key):='ESTORE';
hash(tab_key):='51063C47AC2628D4';
----------------------
tab_key:=163;
username(tab_key):='ESTOREUSER';
password(tab_key):='ESTOREUSER';
hash(tab_key):='0AB4F4864F7B4525';
----------------------
tab_key:=164;
username(tab_key):='EVENT';
password(tab_key):='EVENT';
hash(tab_key):='7CA0A42DA768F96D';
----------------------
tab_key:=165;
username(tab_key):='EVM';
password(tab_key):='EVM';
hash(tab_key):='137CEDC20DE69F71';
----------------------
tab_key:=166;
username(tab_key):='EXAMPLE';
password(tab_key):='EXAMPLE';
hash(tab_key):='637417B1DC47C2E5';
----------------------
tab_key:=167;
username(tab_key):='EXFSYS';
password(tab_key):='EXFSYS';
hash(tab_key):='66F4EF5650C20355';
----------------------
tab_key:=168;
username(tab_key):='EXTDEMO';
password(tab_key):='EXTDEMO';
hash(tab_key):='BAEF9D34973EE4EC';
----------------------
tab_key:=169;
username(tab_key):='EXTDEMO2';
password(tab_key):='EXTDEMO2';
hash(tab_key):='6A10DD2DB23880CB';
----------------------
tab_key:=170;
username(tab_key):='FA';
password(tab_key):='FA';
hash(tab_key):='21A837D0AED8F8E5';
----------------------
tab_key:=171;
username(tab_key):='FEM';
password(tab_key):='FEM';
hash(tab_key):='BD63D79ADF5262E7';
----------------------
tab_key:=172;
username(tab_key):='FII';
password(tab_key):='FII';
hash(tab_key):='CF39DE29C08F71B9';
----------------------
tab_key:=173;
username(tab_key):='FINANCE';
password(tab_key):='FINANCE';
hash(tab_key):='6CBBF17292A1B9AA';
----------------------
tab_key:=174;
username(tab_key):='FINPROD';
password(tab_key):='FINPROD';
hash(tab_key):='8E2713F53A3D69D5';
----------------------
tab_key:=175;
username(tab_key):='FLM';
password(tab_key):='FLM';
hash(tab_key):='CEE2C4B59E7567A3';
----------------------
tab_key:=176;
username(tab_key):='FND';
password(tab_key):='FND';
hash(tab_key):='0C0832F8B6897321';
----------------------
tab_key:=177;
username(tab_key):='FOO';
password(tab_key):='BAR';
hash(tab_key):='707156934A6318D4';
----------------------
tab_key:=178;
username(tab_key):='FPT';
password(tab_key):='FPT';
hash(tab_key):='73E3EC9C0D1FAECF';
----------------------
tab_key:=179;
username(tab_key):='FRM';
password(tab_key):='FRM';
hash(tab_key):='9A2A7E2EBE6E4F71';
----------------------
tab_key:=180;
username(tab_key):='FROSTY';
password(tab_key):='SNOWMAN';
hash(tab_key):='2ED539F71B4AA697';
----------------------
tab_key:=181;
username(tab_key):='FROSTY';
password(tab_key):='FROSTY';
hash(tab_key):='A2BED55A8AAF0CCD';
----------------------
tab_key:=182;
username(tab_key):='FTE';
password(tab_key):='FTE';
hash(tab_key):='2FB4D2C9BAE2CCCA';
----------------------
tab_key:=183;
username(tab_key):='FV';
password(tab_key):='FV';
hash(tab_key):='907D70C0891A85B1';
----------------------
tab_key:=184;
username(tab_key):='GL';
password(tab_key):='GL';
hash(tab_key):='CD6E99DACE4EA3A6';
----------------------
tab_key:=185;
username(tab_key):='GMA';
password(tab_key):='GMA';
hash(tab_key):='DC7948E807DFE242';
----------------------
tab_key:=186;
username(tab_key):='GMD';
password(tab_key):='GMD';
hash(tab_key):='E269165256F22F01';
----------------------
tab_key:=187;
username(tab_key):='GME';
password(tab_key):='GME';
hash(tab_key):='B2F0E221F45A228F';
----------------------
tab_key:=188;
username(tab_key):='GMF';
password(tab_key):='GMF';
hash(tab_key):='A07F1956E3E468E1';
----------------------
tab_key:=189;
username(tab_key):='GMI';
password(tab_key):='GMI';
hash(tab_key):='82542940B0CF9C16';
----------------------
tab_key:=190;
username(tab_key):='GML';
password(tab_key):='GML';
hash(tab_key):='5F1869AD455BBA73';
----------------------
tab_key:=191;
username(tab_key):='GMP';
password(tab_key):='GMP';
hash(tab_key):='450793ACFCC7B58E';
----------------------
tab_key:=192;
username(tab_key):='GMS';
password(tab_key):='GMS';
hash(tab_key):='E654261035504804';
----------------------
tab_key:=193;
username(tab_key):='GPFD';
password(tab_key):='GPFD';
hash(tab_key):='BA787E988F8BC424';
----------------------
tab_key:=194;
username(tab_key):='GPLD';
password(tab_key):='GPLD';
hash(tab_key):='9D561E4D6585824B';
----------------------
tab_key:=195;
username(tab_key):='GR';
password(tab_key):='GR';
hash(tab_key):='F5AB0AA3197AEE42';
----------------------
tab_key:=196;
username(tab_key):='HADES';
password(tab_key):='HADES';
hash(tab_key):='2485287AC1DB6756';
----------------------
tab_key:=197;
username(tab_key):='HCPARK';
password(tab_key):='HCPARK';
hash(tab_key):='3DE1EBA32154C56B';
----------------------
tab_key:=198;
username(tab_key):='HLW';
password(tab_key):='HLW';
hash(tab_key):='855296220C095810';
----------------------
tab_key:=199;
username(tab_key):='HR';
password(tab_key):='HR';
hash(tab_key):='4C6D73C3E8B0F0DA';
----------------------
tab_key:=200;
username(tab_key):='HR';
password(tab_key):='<UNKNOWN>';
hash(tab_key):='33EBE1C63D5B7FEF';
----------------------
tab_key:=201;
username(tab_key):='HR';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='6399F3B38EDF3288';
----------------------
tab_key:=202;
username(tab_key):='HR';
password(tab_key):='UNKNOWN';
hash(tab_key):='6E0C251EABE4EBB8';
----------------------
tab_key:=203;
username(tab_key):='HRI';
password(tab_key):='HRI';
hash(tab_key):='49A3A09B8FC291D0';
----------------------
tab_key:=204;
username(tab_key):='HVST';
password(tab_key):='HVST';
hash(tab_key):='5787B0D15766ADFD';
----------------------
tab_key:=205;
username(tab_key):='HXC';
password(tab_key):='HXC';
hash(tab_key):='4CEA0BF02214DA55';
----------------------
tab_key:=206;
username(tab_key):='HXT';
password(tab_key):='HXT';
hash(tab_key):='169018EB8E2C4A77';
----------------------
tab_key:=207;
username(tab_key):='IBA';
password(tab_key):='IBA';
hash(tab_key):='0BD475D5BF449C63';
----------------------
tab_key:=208;
username(tab_key):='IBE';
password(tab_key):='IBE';
hash(tab_key):='9D41D2B3DD095227';
----------------------
tab_key:=209;
username(tab_key):='IBP';
password(tab_key):='IBP';
hash(tab_key):='840267B7BD30C82E';
----------------------
tab_key:=210;
username(tab_key):='IBU';
password(tab_key):='IBU';
hash(tab_key):='0AD9ABABC74B3057';
----------------------
tab_key:=211;
username(tab_key):='IBY';
password(tab_key):='IBY';
hash(tab_key):='F483A48F6A8C51EC';
----------------------
tab_key:=212;
username(tab_key):='ICDBOWN';
password(tab_key):='ICDBOWN';
hash(tab_key):='76B8D54A74465BB4';
----------------------
tab_key:=213;
username(tab_key):='ICX';
password(tab_key):='ICX';
hash(tab_key):='7766E887AF4DCC46';
----------------------
tab_key:=214;
username(tab_key):='IDEMO_USER';
password(tab_key):='IDEMO_USER';
hash(tab_key):='739F5BC33AC03043';
----------------------
tab_key:=215;
username(tab_key):='IEB';
password(tab_key):='IEB';
hash(tab_key):='A695699F0F71C300';
----------------------
tab_key:=216;
username(tab_key):='IEC';
password(tab_key):='IEC';
hash(tab_key):='CA39F929AF0A2DEC';
----------------------
tab_key:=217;
username(tab_key):='IEM';
password(tab_key):='IEM';
hash(tab_key):='37EF7B2DD17279B5';
----------------------
tab_key:=218;
username(tab_key):='IEO';
password(tab_key):='IEO';
hash(tab_key):='E93196E9196653F1';
----------------------
tab_key:=219;
username(tab_key):='IES';
password(tab_key):='IES';
hash(tab_key):='30802533ADACFE14';
----------------------
tab_key:=220;
username(tab_key):='IEU';
password(tab_key):='IEU';
hash(tab_key):='5D0E790B9E882230';
----------------------
tab_key:=221;
username(tab_key):='IEX';
password(tab_key):='IEX';
hash(tab_key):='6CC978F56D21258D';
----------------------
tab_key:=222;
username(tab_key):='IFSSYS';
password(tab_key):='IFSSYS';
hash(tab_key):='1DF0D45B58E72097';
----------------------
tab_key:=223;
username(tab_key):='IGC';
password(tab_key):='IGC';
hash(tab_key):='D33CEB8277F25346';
----------------------
tab_key:=224;
username(tab_key):='IGF';
password(tab_key):='IGF';
hash(tab_key):='1740079EFF46AB81';
----------------------
tab_key:=225;
username(tab_key):='IGI';
password(tab_key):='IGI';
hash(tab_key):='8C69D50E9D92B9D0';
----------------------
tab_key:=226;
username(tab_key):='IGS';
password(tab_key):='IGS';
hash(tab_key):='DAF602231281B5AC';
----------------------
tab_key:=227;
username(tab_key):='IGW';
password(tab_key):='IGW';
hash(tab_key):='B39565F4E3CF744B';
----------------------
tab_key:=228;
username(tab_key):='IMAGEUSER';
password(tab_key):='IMAGEUSER';
hash(tab_key):='E079BF5E433F0B89';
----------------------
tab_key:=229;
username(tab_key):='IMC';
password(tab_key):='IMC';
hash(tab_key):='C7D0B9CDE0B42C73';
----------------------
tab_key:=230;
username(tab_key):='IMEDIA';
password(tab_key):='IMEDIA';
hash(tab_key):='8FB1DC9A6F8CE827';
----------------------
tab_key:=231;
username(tab_key):='IMT';
password(tab_key):='IMT';
hash(tab_key):='E4AAF998653C9A72';
----------------------
tab_key:=232;
username(tab_key):='INTERNAL';
password(tab_key):='ORACLE';
hash(tab_key):='AB27B53EDC5FEF41';
----------------------
tab_key:=233;
username(tab_key):='INTERNAL';
password(tab_key):='SYS_STNT';
hash(tab_key):='E0BF7F3DDE682D3B';
----------------------
tab_key:=234;
username(tab_key):='INV';
password(tab_key):='INV';
hash(tab_key):='ACEAB015589CF4BC';
----------------------
tab_key:=235;
username(tab_key):='IPA';
password(tab_key):='IPA';
hash(tab_key):='EB265A08759A15B4';
----------------------
tab_key:=236;
username(tab_key):='IPD';
password(tab_key):='IPD';
hash(tab_key):='066A2E3072C1F2F3';
----------------------
tab_key:=237;
username(tab_key):='IPLANET';
password(tab_key):='IPLANET';
hash(tab_key):='7404A12072F4E5E8';
----------------------
tab_key:=238;
username(tab_key):='ISC';
password(tab_key):='ISC';
hash(tab_key):='373F527DC0CFAE98';
----------------------
tab_key:=239;
username(tab_key):='ITG';
password(tab_key):='ITG';
hash(tab_key):='D90F98746B68E6CA';
----------------------
tab_key:=240;
username(tab_key):='JA';
password(tab_key):='JA';
hash(tab_key):='9AC2B58153C23F3D';
----------------------
tab_key:=241;
username(tab_key):='JAKE';
password(tab_key):='PASSWO4';
hash(tab_key):='1CE0B71B4A34904B';
----------------------
tab_key:=242;
username(tab_key):='JE';
password(tab_key):='JE';
hash(tab_key):='FBB3209FD6280E69';
----------------------
tab_key:=243;
username(tab_key):='JG';
password(tab_key):='JG';
hash(tab_key):='37A99698752A1CF1';
----------------------
tab_key:=244;
username(tab_key):='JILL';
password(tab_key):='PASSWO2';
hash(tab_key):='D89D6F9EB78FC841';
----------------------
tab_key:=245;
username(tab_key):='JL';
password(tab_key):='JL';
hash(tab_key):='489B61E488094A8D';
----------------------
tab_key:=246;
username(tab_key):='JMUSER';
password(tab_key):='JMUSER';
hash(tab_key):='063BA85BF749DF8E';
----------------------
tab_key:=247;
username(tab_key):='JOHN';
password(tab_key):='JOHN';
hash(tab_key):='29ED3FDC733DC86D';
----------------------
tab_key:=248;
username(tab_key):='JONES';
password(tab_key):='STEEL';
hash(tab_key):='B9E99443032F059D';
----------------------
tab_key:=249;
username(tab_key):='JONES';
password(tab_key):='JONES';
hash(tab_key):='5215700C08CDCF93';
----------------------
tab_key:=250;
username(tab_key):='JTF';
password(tab_key):='JTF';
hash(tab_key):='5C5F6FC2EBB94124';
----------------------
tab_key:=251;
username(tab_key):='JTM';
password(tab_key):='JTM';
hash(tab_key):='6D79A2259D5B4B5A';
----------------------
tab_key:=252;
username(tab_key):='JTS';
password(tab_key):='JTS';
hash(tab_key):='4087EE6EB7F9CD7C';
----------------------
tab_key:=253;
username(tab_key):='JWARD';
password(tab_key):='AIROPLANE';
hash(tab_key):='CF9CB787BD98DA7F';
----------------------
tab_key:=254;
username(tab_key):='KWALKER';
password(tab_key):='KWALKER';
hash(tab_key):='AD0D93891AEB26D2';
----------------------
tab_key:=255;
username(tab_key):='L2LDEMO';
password(tab_key):='L2LDEMO';
hash(tab_key):='0A6B2DF907484CEE';
----------------------
tab_key:=256;
username(tab_key):='LBACSYS';
password(tab_key):='LBACSYS';
hash(tab_key):='AC9700FD3F1410EB';
----------------------
tab_key:=257;
username(tab_key):='LIBRARIAN';
password(tab_key):='SHELVES';
hash(tab_key):='11E0654A7068559C';
----------------------
tab_key:=258;
username(tab_key):='LIBRARIAN';
password(tab_key):='LIBRARIAN';
hash(tab_key):='C308C88FC950DA82';
----------------------
tab_key:=259;
username(tab_key):='MANPROD';
password(tab_key):='MANPROD';
hash(tab_key):='F0EB74546E22E94D';
----------------------
tab_key:=260;
username(tab_key):='MARK';
password(tab_key):='PASSWO3';
hash(tab_key):='F7101600ACABCD74';
----------------------
tab_key:=261;
username(tab_key):='MASCARM';
password(tab_key):='MANAGER';
hash(tab_key):='4EA68D0DDE8AAC6B';
----------------------
tab_key:=262;
username(tab_key):='MASTER';
password(tab_key):='PASSWORD';
hash(tab_key):='9C4F452058285A74';
----------------------
tab_key:=263;
username(tab_key):='MASTER';
password(tab_key):='MASTER';
hash(tab_key):='76626E2F3790C349';
----------------------
tab_key:=264;
username(tab_key):='MDDATA';
password(tab_key):='MDDATA';
hash(tab_key):='DF02A496267DEE66';
----------------------
tab_key:=265;
username(tab_key):='MDDEMO';
password(tab_key):='MDDEMO';
hash(tab_key):='46DFFB4D08C33739';
----------------------
tab_key:=266;
username(tab_key):='MDDEMO_CLERK';
password(tab_key):='CLERK';
hash(tab_key):='564F871D61369A39';
----------------------
tab_key:=267;
username(tab_key):='MDDEMO_CLERK';
password(tab_key):='MGR';
hash(tab_key):='E5288E225588D11F';
----------------------
tab_key:=268;
username(tab_key):='MDDEMO_MGR';
password(tab_key):='MDDEMO_MGR';
hash(tab_key):='2E175141BEE66FF6';
----------------------
tab_key:=269;
username(tab_key):='MDDEMO_MGR';
password(tab_key):='MGR';
hash(tab_key):='B41BCD9D3737F5C4';
----------------------
tab_key:=270;
username(tab_key):='MDSYS';
password(tab_key):='MDSYS';
hash(tab_key):='72979A94BAD2AF80';
----------------------
tab_key:=271;
username(tab_key):='ME';
password(tab_key):='ME';
hash(tab_key):='E5436F7169B29E4D';
----------------------
tab_key:=272;
username(tab_key):='MFG';
password(tab_key):='MFG';
hash(tab_key):='FC1B0DD35E790847';
----------------------
tab_key:=273;
username(tab_key):='MGR';
password(tab_key):='MGR';
hash(tab_key):='9D1F407F3A05BDD9';
----------------------
tab_key:=274;
username(tab_key):='MGWUSER';
password(tab_key):='MGWUSER';
hash(tab_key):='EA514DD74D7DE14C';
----------------------
tab_key:=275;
username(tab_key):='MIGRATE';
password(tab_key):='MIGRATE';
hash(tab_key):='5A88CE52084E9700';
----------------------
tab_key:=276;
username(tab_key):='MILLER';
password(tab_key):='MILLER';
hash(tab_key):='D0EFCD03C95DF106';
----------------------
tab_key:=277;
username(tab_key):='MMO2';
password(tab_key):='MMO3';
hash(tab_key):='A0E2085176E05C85';
----------------------
tab_key:=278;
username(tab_key):='MMO2';
password(tab_key):='MMO2';
hash(tab_key):='AE128772645F6709';
----------------------
tab_key:=279;
username(tab_key):='MMO2';
password(tab_key):='UNKNOWN';
hash(tab_key):='62876B0382D5B550';
----------------------
tab_key:=280;
username(tab_key):='MODTEST';
password(tab_key):='YES';
hash(tab_key):='BBFF58334CDEF86D';
----------------------
tab_key:=281;
username(tab_key):='MOREAU';
password(tab_key):='MOREAU';
hash(tab_key):='CF5A081E7585936B';
----------------------
tab_key:=282;
username(tab_key):='MRP';
password(tab_key):='MRP';
hash(tab_key):='B45D4DF02D4E0C85';
----------------------
tab_key:=283;
username(tab_key):='MSC';
password(tab_key):='MSC';
hash(tab_key):='89A8C104725367B2';
----------------------
tab_key:=284;
username(tab_key):='MSD';
password(tab_key):='MSD';
hash(tab_key):='6A29482069E23675';
----------------------
tab_key:=285;
username(tab_key):='MSO';
password(tab_key):='MSO';
hash(tab_key):='3BAA3289DB35813C';
----------------------
tab_key:=286;
username(tab_key):='MSR';
password(tab_key):='MSR';
hash(tab_key):='C9D53D00FE77D813';
----------------------
tab_key:=287;
username(tab_key):='MTS_USER';
password(tab_key):='MTS_PASSWORD';
hash(tab_key):='E462DB4671A51CD4';
----------------------
tab_key:=288;
username(tab_key):='MTS_USER';
password(tab_key):='MTS_USER';
hash(tab_key):='2FB9DFDA1939943D';
----------------------
tab_key:=289;
username(tab_key):='MTSSYS';
password(tab_key):='MTSSYS';
hash(tab_key):='6465913FF5FF1831';
----------------------
tab_key:=290;
username(tab_key):='MWA';
password(tab_key):='MWA';
hash(tab_key):='1E2F06BE2A1D41A6';
----------------------
tab_key:=291;
username(tab_key):='MXAGENT';
password(tab_key):='MXAGENT';
hash(tab_key):='C5F0512A64EB0E7F';
----------------------
tab_key:=292;
username(tab_key):='NAMES';
password(tab_key):='NAMES';
hash(tab_key):='9B95D28A979CC5C4';
----------------------
tab_key:=293;
username(tab_key):='NEOTIX_SYS';
password(tab_key):='NEOTIX_SYS';
hash(tab_key):='05BFA7FF86D6EB32';
----------------------
tab_key:=294;
username(tab_key):='NNEUL';
password(tab_key):='NNEULPASS';
hash(tab_key):='4782D68D42792139';
----------------------
tab_key:=295;
username(tab_key):='NOM_UTILISATEUR';
password(tab_key):='MOT_DE_PASSE';
hash(tab_key):='FD621020564A4978';
----------------------
tab_key:=296;
username(tab_key):='NOME_UTILIZADOR';
password(tab_key):='SENHA';
hash(tab_key):='71452E4797DF917B';
----------------------
tab_key:=297;
username(tab_key):='NOMEUTENTE';
password(tab_key):='PASSWORD';
hash(tab_key):='8A43574EFB1C71C7';
----------------------
tab_key:=298;
username(tab_key):='NUME_UTILIZATOR';
password(tab_key):='PAROL';
hash(tab_key):='73A3AC32826558AE';
----------------------
tab_key:=299;
username(tab_key):='OAIHUB902';
password(tab_key):='OAIHUB902';
hash(tab_key):='09128818DB415317';
----------------------
tab_key:=300;
username(tab_key):='OAS_PUBLIC';
password(tab_key):='OAS_PUBLIC';
hash(tab_key):='A8116DB6E84FA95D';
----------------------
tab_key:=301;
username(tab_key):='OAS_PUBLIC';
password(tab_key):='<UNKNOWN>';
hash(tab_key):='9300C0977D7DC75E';
----------------------
tab_key:=302;
username(tab_key):='OCITEST';
password(tab_key):='OCITEST';
hash(tab_key):='C09011CB0205B347';
----------------------
tab_key:=303;
username(tab_key):='OCM_DB_ADMIN';
password(tab_key):='OCM_DB_ADMIN';
hash(tab_key):='2C3A5DEF1EE57E92';
----------------------
tab_key:=304;
username(tab_key):='ODM';
password(tab_key):='ODM';
hash(tab_key):='C252E8FA117AF049';
----------------------
tab_key:=305;
username(tab_key):='ODM_MTR';
password(tab_key):='MTRPW';
hash(tab_key):='A7A32CD03D3CE8D5';
----------------------
tab_key:=306;
username(tab_key):='ODS';
password(tab_key):='ODS';
hash(tab_key):='89804494ADFC71BC';
----------------------
tab_key:=307;
username(tab_key):='ODS_SERVER';
password(tab_key):='ODS_SERVER';
hash(tab_key):='C6E799A949471F57';
----------------------
tab_key:=308;
username(tab_key):='ODSCOMMON';
password(tab_key):='ODSCOMMON';
hash(tab_key):='59BBED977430C1A8';
----------------------
tab_key:=309;
username(tab_key):='OE';
password(tab_key):='OE';
hash(tab_key):='D1A2DFC623FDA40A';
----------------------
tab_key:=310;
username(tab_key):='OE';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='9C30855E7E0CB02D';
----------------------
tab_key:=311;
username(tab_key):='OE';
password(tab_key):='UNKNOWN';
hash(tab_key):='62FADF01C4DC1ED4';
----------------------
tab_key:=312;
username(tab_key):='OE';
password(tab_key):='OE';
hash(tab_key):='D1A2DFC623FDA40A';
----------------------
tab_key:=313;
username(tab_key):='OEM_REPOSITORY';
password(tab_key):='<UNKNOWN>';
hash(tab_key):='1FF89109F7A16FEF';
----------------------
tab_key:=314;
username(tab_key):='OEMADM';
password(tab_key):='OEMADM';
hash(tab_key):='9DCE98CCF541AAE6';
----------------------
tab_key:=315;
username(tab_key):='OEMREP';
password(tab_key):='OEMREP';
hash(tab_key):='7BB2F629772BF2E5';
----------------------
tab_key:=316;
username(tab_key):='OKB';
password(tab_key):='OKB';
hash(tab_key):='A01A5F0698FC9E31';
----------------------
tab_key:=317;
username(tab_key):='OKC';
password(tab_key):='OKC';
hash(tab_key):='31C1DDF4D5D63FE6';
----------------------
tab_key:=318;
username(tab_key):='OKE';
password(tab_key):='OKE';
hash(tab_key):='B7C1BB95646C16FE';
----------------------
tab_key:=319;
username(tab_key):='OKI';
password(tab_key):='OKI';
hash(tab_key):='991C817E5FD0F35A';
----------------------
tab_key:=320;
username(tab_key):='OKO';
password(tab_key):='OKO';
hash(tab_key):='6E204632EC7CA65D';
----------------------
tab_key:=321;
username(tab_key):='OKR';
password(tab_key):='OKR';
hash(tab_key):='BB0E28666845FCDC';
----------------------
tab_key:=322;
username(tab_key):='OKS';
password(tab_key):='OKS';
hash(tab_key):='C2B4C76AB8257DF5';
----------------------
tab_key:=323;
username(tab_key):='OKX';
password(tab_key):='OKX';
hash(tab_key):='F9FDEB0DE52F5D6B';
----------------------
tab_key:=324;
username(tab_key):='OLAPDBA';
password(tab_key):='OLAPDBA';
hash(tab_key):='1AF71599EDACFB00';
----------------------
tab_key:=325;
username(tab_key):='OLAPSVR';
password(tab_key):='INSTANCE';
hash(tab_key):='AF52CFD036E8F425';
----------------------
tab_key:=326;
username(tab_key):='OLAPSVR';
password(tab_key):='OLAPSVR';
hash(tab_key):='3B3F6DB781927D0F';
----------------------
tab_key:=327;
username(tab_key):='OLAPSYS';
password(tab_key):='MANAGER';
hash(tab_key):='3FB8EF9DB538647C';
----------------------
tab_key:=328;
username(tab_key):='OLAPSYS';
password(tab_key):='OLAPSYS';
hash(tab_key):='C1510E7AC8F0D90D';
----------------------
tab_key:=329;
username(tab_key):='OMWB_EMULATION';
password(tab_key):='ORACLE';
hash(tab_key):='54A85D2A0AB8D865';
----------------------
tab_key:=330;
username(tab_key):='ONT';
password(tab_key):='ONT';
hash(tab_key):='9E3C81574654100A';
----------------------
tab_key:=331;
username(tab_key):='OO';
password(tab_key):='OO';
hash(tab_key):='2AB9032E4483FAFC';
----------------------
tab_key:=332;
username(tab_key):='OPENSPIRIT';
password(tab_key):='OPENSPIRIT';
hash(tab_key):='D664AAB21CE86FD2';
----------------------
tab_key:=333;
username(tab_key):='OPI';
password(tab_key):='OPI';
hash(tab_key):='1BF23812A0AEEDA0';
----------------------
tab_key:=334;
username(tab_key):='ORACACHE';
password(tab_key):='ORACACHE';
hash(tab_key):='5A4EEC421DE68DDD';
----------------------
tab_key:=335;
username(tab_key):='ORACLE';
password(tab_key):='ORACLE';
hash(tab_key):='38E38619A12E0257';
----------------------
tab_key:=336;
username(tab_key):='ORADBA';
password(tab_key):='ORADBAPASS';
hash(tab_key):='C37E732953A8ABDB';
----------------------
tab_key:=337;
username(tab_key):='ORANGE';
password(tab_key):='<UNKNOWN>';
hash(tab_key):='3D9B7E34A4F7D4E9';
----------------------
tab_key:=338;
username(tab_key):='ORAPROBE';
password(tab_key):='ORAPROBE';
hash(tab_key):='2E3EA470A4CA2D94';
----------------------
tab_key:=339;
username(tab_key):='ORAREGSYS';
password(tab_key):='ORAREGSYS';
hash(tab_key):='28D778112C63CB15';
----------------------
tab_key:=340;
username(tab_key):='ORASSO';
password(tab_key):='ORASSO';
hash(tab_key):='F3701A008AA578CF';
----------------------
tab_key:=341;
username(tab_key):='ORASSO_DS';
password(tab_key):='ORASSO_DS';
hash(tab_key):='17DC8E02BC75C141';
----------------------
tab_key:=342;
username(tab_key):='ORASSO_PA';
password(tab_key):='ORASSO_PA';
hash(tab_key):='133F8D161296CB8F';
----------------------
tab_key:=343;
username(tab_key):='ORASSO_PS';
password(tab_key):='ORASSO_PS';
hash(tab_key):='63BB534256053305';
----------------------
tab_key:=344;
username(tab_key):='ORASSO_PUBLIC';
password(tab_key):='ORASSO_PUBLIC';
hash(tab_key):='C6EED68A8F75F5D3';
----------------------
tab_key:=345;
username(tab_key):='ORASTAT';
password(tab_key):='ORASTAT';
hash(tab_key):='6102BAE530DD4B95';
----------------------
tab_key:=346;
username(tab_key):='ORCLADMIN';
password(tab_key):='WELCOME';
hash(tab_key):='7C0BE475D580FBA2';
----------------------
tab_key:=347;
username(tab_key):='ORDCOMMON';
password(tab_key):='ORDCOMMON';
hash(tab_key):='9B616F5489F90AD7';
----------------------
tab_key:=348;
username(tab_key):='ORDPLUGINS';
password(tab_key):='ORDPLUGINS';
hash(tab_key):='88A2B2C183431F00';
----------------------
tab_key:=349;
username(tab_key):='ORDSYS';
password(tab_key):='ORDSYS';
hash(tab_key):='7EFA02EC7EA6B86F';
----------------------
tab_key:=350;
username(tab_key):='OSE$HTTP$ADMIN';
password(tab_key):='invalid';
hash(tab_key):='05327CD9F6114E21';
----------------------
tab_key:=351;
username(tab_key):='OSE$HTTP$ADMIN';
password(tab_key):='OSE$HTTP$ADMIN';
hash(tab_key):='30F6C41397B5D73D';
----------------------
tab_key:=352;
username(tab_key):='OSM';
password(tab_key):='OSM';
hash(tab_key):='106AE118841A5D8C';
----------------------
tab_key:=353;
username(tab_key):='OSP22';
password(tab_key):='OSP22';
hash(tab_key):='C04057049DF974C2';
----------------------
tab_key:=354;
username(tab_key):='OSSAQ_HOST';
password(tab_key):='OSSAQ_HOST';
hash(tab_key):='55626318CFB9E310';
----------------------
tab_key:=355;
username(tab_key):='OSSAQ_PUB';
password(tab_key):='OSSAQ_PUB';
hash(tab_key):='A495C7FF72D1F153';
----------------------
tab_key:=356;
username(tab_key):='OTA';
password(tab_key):='OTA';
hash(tab_key):='F5E498AC7009A217';
----------------------
tab_key:=357;
username(tab_key):='OUTLN';
password(tab_key):='OUTLN';
hash(tab_key):='4A3BA55E08595C81';
----------------------
tab_key:=358;
username(tab_key):='OWA';
password(tab_key):='OWA';
hash(tab_key):='CA5D67CD878AFC49';
----------------------
tab_key:=359;
username(tab_key):='OWA_PUBLIC';
password(tab_key):='OWA_PUBLIC';
hash(tab_key):='0D9EC1D1F2A37657';
----------------------
tab_key:=360;
username(tab_key):='OWF_MGR';
password(tab_key):='OWF_MGR';
hash(tab_key):='3CBED37697EB01D1';
----------------------
tab_key:=361;
username(tab_key):='OWNER';
password(tab_key):='OWNER';
hash(tab_key):='5C3546B4F9165300';
----------------------
tab_key:=362;
username(tab_key):='OZF';
password(tab_key):='OZF';
hash(tab_key):='970B962D942D0C75';
----------------------
tab_key:=363;
username(tab_key):='OZP';
password(tab_key):='OZP';
hash(tab_key):='B650B1BB35E86863';
----------------------
tab_key:=364;
username(tab_key):='OZS';
password(tab_key):='OZS';
hash(tab_key):='0DABFF67E0D33623';
----------------------
tab_key:=365;
username(tab_key):='PA';
password(tab_key):='PA';
hash(tab_key):='8CE2703752DB36D8';
----------------------
tab_key:=366;
username(tab_key):='PANAMA';
password(tab_key):='PANAMA';
hash(tab_key):='3E7B4116043BEAFF';
----------------------
tab_key:=367;
username(tab_key):='PATROL';
password(tab_key):='PATROL';
hash(tab_key):='0478B8F047DECC65';
----------------------
tab_key:=368;
username(tab_key):='PAUL';
password(tab_key):='PAUL';
hash(tab_key):='35EC0362643ADD3F';
----------------------
tab_key:=369;
username(tab_key):='PERFSTAT';
password(tab_key):='PERFSTAT';
hash(tab_key):='AC98877DE1297365';
----------------------
tab_key:=370;
username(tab_key):='PERSTAT';
password(tab_key):='PERSTAT';
hash(tab_key):='4D45555910EA2F3A';
----------------------
tab_key:=371;
username(tab_key):='PERSTAT';
password(tab_key):='PERSTAT';
hash(tab_key):='A68F56FBBCDC04AB';
----------------------
tab_key:=372;
username(tab_key):='PJM';
password(tab_key):='PJM';
hash(tab_key):='021B05DBB892D11F';
----------------------
tab_key:=373;
username(tab_key):='PLANNING';
password(tab_key):='PLANNING';
hash(tab_key):='71B5C2271B7CFF18';
----------------------
tab_key:=374;
username(tab_key):='PLEX';
password(tab_key):='PLEX';
hash(tab_key):='99355BF0E53FF635';
----------------------
tab_key:=375;
username(tab_key):='PLSQL';
password(tab_key):='SUPERSECRET';
hash(tab_key):='C4522E109BCF69D0';
----------------------
tab_key:=376;
username(tab_key):='PLSQL';
password(tab_key):='PLSQL';
hash(tab_key):='CF0AD27074D4AC82';
----------------------
tab_key:=377;
username(tab_key):='PM';
password(tab_key):='PM';
hash(tab_key):='C7A235E6D2AF6018';
----------------------
tab_key:=378;
username(tab_key):='PM';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='72E382A52E89575A';
----------------------
tab_key:=379;
username(tab_key):='PM';
password(tab_key):='UNKNOWN';
hash(tab_key):='F67E035BF8352CB4';
----------------------
tab_key:=380;
username(tab_key):='PMI';
password(tab_key):='PMI';
hash(tab_key):='A7F7978B21A6F65E';
----------------------
tab_key:=381;
username(tab_key):='PN';
password(tab_key):='PN';
hash(tab_key):='D40D0FEF9C8DC624';
----------------------
tab_key:=382;
username(tab_key):='PO';
password(tab_key):='PO';
hash(tab_key):='355CBEC355C10FEF';
----------------------
tab_key:=383;
username(tab_key):='PO7';
password(tab_key):='PO7';
hash(tab_key):='6B870AF28F711204';
----------------------
tab_key:=384;
username(tab_key):='PO8';
password(tab_key):='PO8';
hash(tab_key):='7E15FBACA7CDEBEC';
----------------------
tab_key:=385;
username(tab_key):='POA';
password(tab_key):='POA';
hash(tab_key):='2AB40F104D8517A0';
----------------------
tab_key:=386;
username(tab_key):='POM';
password(tab_key):='POM';
hash(tab_key):='123CF56E05D4EF3C';
----------------------
tab_key:=387;
username(tab_key):='PORTAL';
password(tab_key):='PORTAL';
hash(tab_key):='A96255A27EC33614';
----------------------
tab_key:=388;
username(tab_key):='PORTAL_APP';
password(tab_key):='PORTAL_APP';
hash(tab_key):='831A79AFB0BD29EC';
----------------------
tab_key:=389;
username(tab_key):='PORTAL_DEMO';
password(tab_key):='PORTAL_DEMO';
hash(tab_key):='A0A3A6A577A931A3';
----------------------
tab_key:=390;
username(tab_key):='PORTAL_PUBLIC';
password(tab_key):='PORTAL_PUBLIC';
hash(tab_key):='70A9169655669CE8';
----------------------
tab_key:=391;
username(tab_key):='PORTAL_SSO_PS';
password(tab_key):='PORTAL_SSO_PS';
hash(tab_key):='D1FB757B6E3D8E2F';
----------------------
tab_key:=392;
username(tab_key):='PORTAL30';
password(tab_key):='PORTAL31';
hash(tab_key):='D373ABE86992BE68';
----------------------
tab_key:=393;
username(tab_key):='PORTAL30';
password(tab_key):='PORTAL30';
hash(tab_key):='969F9C3839672C6D';
----------------------
tab_key:=394;
username(tab_key):='PORTAL30_ADMIN';
password(tab_key):='PORTAL30_ADMIN';
hash(tab_key):='7AF870D89CABF1C7';
----------------------
tab_key:=395;
username(tab_key):='PORTAL30_DEMO';
password(tab_key):='PORTAL30_DEMO';
hash(tab_key):='CFD1302A7F832068';
----------------------
tab_key:=396;
username(tab_key):='PORTAL30_PS';
password(tab_key):='PORTAL30_PS';
hash(tab_key):='333B8121593F96FB';
----------------------
tab_key:=397;
username(tab_key):='PORTAL30_PUBLIC';
password(tab_key):='PORTAL30_PUBLIC';
hash(tab_key):='42068201613CA6E2';
----------------------
tab_key:=398;
username(tab_key):='PORTAL30_SSO';
password(tab_key):='PORTAL30_SSO';
hash(tab_key):='882B80B587FCDBC8';
----------------------
tab_key:=399;
username(tab_key):='PORTAL30_SSO_ADMIN';
password(tab_key):='PORTAL30_SSO_ADMIN';
hash(tab_key):='BDE248D4CCCD015D';
----------------------
tab_key:=400;
username(tab_key):='PORTAL30_SSO_PS';
password(tab_key):='PORTAL30_SSO_PS';
hash(tab_key):='F2C3DC8003BC90F8';
----------------------
tab_key:=401;
username(tab_key):='PORTAL30_SSO_PUBLIC';
password(tab_key):='PORTAL30_SSO_PUBLIC';
hash(tab_key):='98741BDA2AC7FFB2';
----------------------
tab_key:=402;
username(tab_key):='POS';
password(tab_key):='POS';
hash(tab_key):='6F6675F272217CF7';
----------------------
tab_key:=403;
username(tab_key):='POWERCARTUSER';
password(tab_key):='POWERCARTUSER';
hash(tab_key):='2C5ECE3BEC35CE69';
----------------------
tab_key:=404;
username(tab_key):='PRIMARY';
password(tab_key):='PRIMARY';
hash(tab_key):='70C3248DFFB90152';
----------------------
tab_key:=405;
username(tab_key):='PSA';
password(tab_key):='PSA';
hash(tab_key):='FF4B266F9E61F911';
----------------------
tab_key:=406;
username(tab_key):='PSB';
password(tab_key):='PSB';
hash(tab_key):='28EE1E024FC55E66';
----------------------
tab_key:=407;
username(tab_key):='PSP';
password(tab_key):='PSP';
hash(tab_key):='4FE07360D435E2F0';
----------------------
tab_key:=408;
username(tab_key):='PUBLICO';
password(tab_key):='PUBLICO';
hash(tab_key):='037EDFC6A6EF5F6D';
----------------------
tab_key:=409;
username(tab_key):='PUBSUB';
password(tab_key):='PUBSUB';
hash(tab_key):='80294AE45A46E77B';
----------------------
tab_key:=410;
username(tab_key):='PUBSUB1';
password(tab_key):='PUBSUB1';
hash(tab_key):='D6DF5BBC8B64933E';
----------------------
tab_key:=411;
username(tab_key):='PV';
password(tab_key):='PV';
hash(tab_key):='76224BCC80895D3D';
----------------------
tab_key:=412;
username(tab_key):='QA';
password(tab_key):='QA';
hash(tab_key):='C7AEAA2D59EB1EAE';
----------------------
tab_key:=413;
username(tab_key):='QDBA';
password(tab_key):='QDBA';
hash(tab_key):='AE62CB8167819595';
----------------------
tab_key:=414;
username(tab_key):='QP';
password(tab_key):='QP';
hash(tab_key):='10A40A72991DCA15';
----------------------
tab_key:=415;
username(tab_key):='QS';
password(tab_key):='QS';
hash(tab_key):='4603BCD2744BDE4F';
----------------------
tab_key:=416;
username(tab_key):='QS';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='8B09C6075BDF2DC4';
----------------------
tab_key:=417;
username(tab_key):='QS';
password(tab_key):='UNKNOWN';
hash(tab_key):='ACBD635B3A25405D';
----------------------
tab_key:=418;
username(tab_key):='QS_ADM';
password(tab_key):='QS_ADM';
hash(tab_key):='3990FB418162F2A0';
----------------------
tab_key:=419;
username(tab_key):='QS_ADM';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='991CDDAD5C5C32CA';
----------------------
tab_key:=420;
username(tab_key):='QS_ADM';
password(tab_key):='UNKNOWN';
hash(tab_key):='BB424460EFEC9080';
----------------------
tab_key:=421;
username(tab_key):='QS_CB';
password(tab_key):='QS_CB';
hash(tab_key):='870C36D8E6CD7CF5';
----------------------
tab_key:=422;
username(tab_key):='QS_CB';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='CF9CFACF5AE24964';
----------------------
tab_key:=423;
username(tab_key):='QS_CB';
password(tab_key):='UNKNOWN';
hash(tab_key):='A2A1265A6BDC8F36';
----------------------
tab_key:=424;
username(tab_key):='QS_CBADM';
password(tab_key):='QS_CBADM';
hash(tab_key):='20E788F9D4F1D92C';
----------------------
tab_key:=425;
username(tab_key):='QS_CBADM';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='7C632AFB71F8D305';
----------------------
tab_key:=426;
username(tab_key):='QS_CBADM';
password(tab_key):='UNKNOWN';
hash(tab_key):='58C823BA7A2D3D7F';
----------------------
tab_key:=427;
username(tab_key):='QS_CS';
password(tab_key):='QS_CS';
hash(tab_key):='2CA6D0FC25128CF3';
----------------------
tab_key:=428;
username(tab_key):='QS_CS';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='91A00922D8C0F146';
----------------------
tab_key:=429;
username(tab_key):='QS_CS';
password(tab_key):='UNKNOWN';
hash(tab_key):='5D85C7E8FB28375F';
----------------------
tab_key:=430;
username(tab_key):='QS_ES';
password(tab_key):='QS_ES';
hash(tab_key):='9A5F2D9F5D1A9EF4';
----------------------
tab_key:=431;
username(tab_key):='QS_ES';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='E6A6FA4BB042E3C2';
----------------------
tab_key:=432;
username(tab_key):='QS_ES';
password(tab_key):='UNKNOWN';
hash(tab_key):='723007181C44715C';
----------------------
tab_key:=433;
username(tab_key):='QS_OS';
password(tab_key):='QS_OS';
hash(tab_key):='0EF5997DC2638A61';
----------------------
tab_key:=434;
username(tab_key):='QS_OS';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='FF09F3EB14AE5C26';
----------------------
tab_key:=435;
username(tab_key):='QS_OS';
password(tab_key):='UNKNOWN';
hash(tab_key):='7ABBCF4BEB7854B2';
----------------------
tab_key:=436;
username(tab_key):='QS_WS';
password(tab_key):='QS_WS';
hash(tab_key):='0447F2F756B4F460';
----------------------
tab_key:=437;
username(tab_key):='QS_WS';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='24ACF617DD7D8F2F';
----------------------
tab_key:=438;
username(tab_key):='QS_WS';
password(tab_key):='UNKNOWN';
hash(tab_key):='8CF13718CDC81090';
----------------------
tab_key:=439;
username(tab_key):='QUEST';
password(tab_key):='SPOTLIGHT';
hash(tab_key):='0B17DAAAEB6C9798';
----------------------
tab_key:=440;
username(tab_key):='QUEST';
password(tab_key):='SPOT';
hash(tab_key):='AC8D8CE933DBB2F5';
----------------------
tab_key:=441;
username(tab_key):='QUEST';
password(tab_key):='QUEST';
hash(tab_key):='E8A8AF58845EBCF7';
----------------------
tab_key:=442;
username(tab_key):='QUEST';
password(tab_key):='CENTRAL';
hash(tab_key):='54F612B047E4F779';
----------------------
tab_key:=443;
username(tab_key):='RE';
password(tab_key):='RE';
hash(tab_key):='933B9A9475E882A6';
----------------------
tab_key:=444;
username(tab_key):='REP_MANAGER';
password(tab_key):='DEMO';
hash(tab_key):='2D4B13A8416073A1';
----------------------
tab_key:=445;
username(tab_key):='REP_MANAGER';
password(tab_key):='REP_MANAGER';
hash(tab_key):='95BAF261774B369C';
----------------------
tab_key:=446;
username(tab_key):='REP_OWNER';
password(tab_key):='DEMO';
hash(tab_key):='88D8F06915B1FE30';
----------------------
tab_key:=447;
username(tab_key):='REP_OWNER';
password(tab_key):='REP_OWNER';
hash(tab_key):='BD99EC2DD84E3B5C';
----------------------
tab_key:=448;
username(tab_key):='REP_USER';
password(tab_key):='DEMO';
hash(tab_key):='57F2A93832685ADB';
----------------------
tab_key:=449;
username(tab_key):='REPADMIN';
password(tab_key):='REPADMIN';
hash(tab_key):='915C93F34954F5F8';
----------------------
tab_key:=450;
username(tab_key):='REPORTS';
password(tab_key):='REPORTS';
hash(tab_key):='0D9D14FE6653CF69';
----------------------
tab_key:=451;
username(tab_key):='REPORTS_USER';
password(tab_key):='OEM_TEMP';
hash(tab_key):='635074B4416CD3AC';
----------------------
tab_key:=452;
username(tab_key):='RG';
password(tab_key):='RG';
hash(tab_key):='0FAA06DA0F42F21F';
----------------------
tab_key:=453;
username(tab_key):='RHX';
password(tab_key):='RHX';
hash(tab_key):='FFDF6A0C8C96E676';
----------------------
tab_key:=454;
username(tab_key):='RLA';
password(tab_key):='RLA';
hash(tab_key):='C1959B03F36C9BB2';
----------------------
tab_key:=455;
username(tab_key):='RLM';
password(tab_key):='RLM';
hash(tab_key):='4B16ACDA351B557D';
----------------------
tab_key:=456;
username(tab_key):='RMAIL';
password(tab_key):='RMAIL';
hash(tab_key):='DA4435BBF8CAE54C';
----------------------
tab_key:=457;
username(tab_key):='RMAN';
password(tab_key):='RMAN';
hash(tab_key):='E7B5D92911C831E1';
----------------------
tab_key:=458;
username(tab_key):='RRS';
password(tab_key):='RRS';
hash(tab_key):='5CA8F5380C959CA9';
----------------------
tab_key:=459;
username(tab_key):='SAMPLE';
password(tab_key):='SAMPLE';
hash(tab_key):='E74B15A3F7A19CA8';
----------------------
tab_key:=460;
username(tab_key):='SAP';
password(tab_key):='SAPR3';
hash(tab_key):='BEAA1036A464F9F0';
----------------------
tab_key:=461;
username(tab_key):='SAP';
password(tab_key):='SAP';
hash(tab_key):='B8C55254778AE10B';
----------------------
tab_key:=462;
username(tab_key):='SAP';
password(tab_key):='ORACLE';
hash(tab_key):='DD38E8665E0825C2';
----------------------
tab_key:=463;
username(tab_key):='SAP';
password(tab_key):='6071992';
hash(tab_key):='B1344DC1B5F3D903';
----------------------
tab_key:=464;
username(tab_key):='SAPR3';
password(tab_key):='SAP';
hash(tab_key):='58872B4319A76363';
----------------------
tab_key:=465;
username(tab_key):='SCOTT';
password(tab_key):='TIGER';
hash(tab_key):='F894844C34402B67';
----------------------
tab_key:=466;
username(tab_key):='SCOTT';
password(tab_key):='SCOTT';
hash(tab_key):='CDC57F9E62A38D03';
----------------------
tab_key:=467;
username(tab_key):='SCOTT';
password(tab_key):='TIGGER';
hash(tab_key):='7AA1A84E31ED7771';
----------------------
tab_key:=468;
username(tab_key):='SDOS_ICSAP';
password(tab_key):='SDOS_ICSAP';
hash(tab_key):='C789210ACC24DA16';
----------------------
tab_key:=469;
username(tab_key):='SECDEMO';
password(tab_key):='SECDEMO';
hash(tab_key):='009BBE8142502E10';
----------------------
tab_key:=470;
username(tab_key):='SERVICECONSUMER1';
password(tab_key):='SERVICECONSUMER1';
hash(tab_key):='183AC2094A6BD59F';
----------------------
tab_key:=471;
username(tab_key):='SH';
password(tab_key):='SH';
hash(tab_key):='54B253CBBAAA8C48';
----------------------
tab_key:=472;
username(tab_key):='SH';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='9793B3777CD3BD1A';
----------------------
tab_key:=473;
username(tab_key):='SH';
password(tab_key):='UNKNOWN';
hash(tab_key):='1729F80C5FA78841';
----------------------
tab_key:=474;
username(tab_key):='SI_INFORMTN_SCHEMA';
password(tab_key):='SI_INFORMTN_SCHEMA';
hash(tab_key):='84B8CBCA4D477FA3';
----------------------
tab_key:=475;
username(tab_key):='SITEMINDER';
password(tab_key):='SITEMINDER';
hash(tab_key):='061354246A45BBAB';
----------------------
tab_key:=476;
username(tab_key):='SLIDE';
password(tab_key):='SLIDEPW';
hash(tab_key):='FDFE8B904875643D';
----------------------
tab_key:=477;
username(tab_key):='SLIDE';
password(tab_key):='SLIDE';
hash(tab_key):='C212C77247233C97';
----------------------
tab_key:=478;
username(tab_key):='SPIERSON';
password(tab_key):='SPIERSON';
hash(tab_key):='4A0A55000357BB3E';
----------------------
tab_key:=479;
username(tab_key):='SPOT';
password(tab_key):='SPOT';
hash(tab_key):='2DA4B45C505F6823';
----------------------
tab_key:=480;
username(tab_key):='SPOT';
password(tab_key):='SPOTLIGHT';
hash(tab_key):='F906E10B8E3E0900';
----------------------
tab_key:=481;
username(tab_key):='SPOT';
password(tab_key):='QUEST';
hash(tab_key):='24420ECAAAA57E76';
----------------------
tab_key:=482;
username(tab_key):='SPOT';
password(tab_key):='CENTRAL';
hash(tab_key):='5B69ED21A9A3D198';
----------------------
tab_key:=483;
username(tab_key):='SPOTLIGHT';
password(tab_key):='CENTRAL';
hash(tab_key):='77B5EB892B2582E9';
----------------------
tab_key:=484;
username(tab_key):='SPOTLIGHT';
password(tab_key):='SPOT';
hash(tab_key):='93C76FB5CC6CAB80';
----------------------
tab_key:=485;
username(tab_key):='SPOTLIGHT';
password(tab_key):='QUEST';
hash(tab_key):='0EE51D9428914896';
----------------------
tab_key:=486;
username(tab_key):='SPOTLIGHT';
password(tab_key):='SPOTLIGHT';
hash(tab_key):='4F541E3C312BCFC9';
----------------------
tab_key:=487;
username(tab_key):='SSP';
password(tab_key):='SSP';
hash(tab_key):='87470D6CE203FB4D';
----------------------
tab_key:=488;
username(tab_key):='STARTER';
password(tab_key):='STARTER';
hash(tab_key):='6658C384B8D63B0A';
----------------------
tab_key:=489;
username(tab_key):='STRAT_USER';
password(tab_key):='STRAT_PASSWD';
hash(tab_key):='AEBEDBB4EFB5225B';
----------------------
tab_key:=490;
username(tab_key):='STRAT_USER';
password(tab_key):='STRAT_USER';
hash(tab_key):='25952BD04E577A28';
----------------------
tab_key:=491;
username(tab_key):='SWPRO';
password(tab_key):='SWPRO';
hash(tab_key):='4CB05AA42D8E3A47';
----------------------
tab_key:=492;
username(tab_key):='SWUSER';
password(tab_key):='SWUSER';
hash(tab_key):='783E58C29D2FC7E1';
----------------------
tab_key:=493;
username(tab_key):='SYMPA';
password(tab_key):='SYMPA';
hash(tab_key):='E7683741B91AF226';
----------------------
tab_key:=494;
username(tab_key):='SYS';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='D4C5016086B2DC6A';
----------------------
tab_key:=495;
username(tab_key):='SYS';
password(tab_key):='SYS';
hash(tab_key):='4DE42795E66117AE';
----------------------
tab_key:=496;
username(tab_key):='SYS';
password(tab_key):='SYSTEM';
hash(tab_key):='75800913E1B66343';
----------------------
tab_key:=497;
username(tab_key):='SYS';
password(tab_key):='MANAGER';
hash(tab_key):='5638228DAF52805F';
----------------------
tab_key:=498;
username(tab_key):='SYS';
password(tab_key):='SYSDBA';
hash(tab_key):='D439F7EED8D7F5C7';
----------------------
tab_key:=499;
username(tab_key):='SYS';
password(tab_key):='0RACLE8';
hash(tab_key):='1FA22316B703EBDD';
----------------------
tab_key:=500;
username(tab_key):='SYS';
password(tab_key):='0RACLE9';
hash(tab_key):='12CFB5AE1D087BA3';
----------------------
tab_key:=501;
username(tab_key):='SYS';
password(tab_key):='0RACLE8I';
hash(tab_key):='380E3D3AD5CE32D4';
----------------------
tab_key:=502;
username(tab_key):='SYS';
password(tab_key):='0RACL38';
hash(tab_key):='2563EFAAE44E785A';
----------------------
tab_key:=503;
username(tab_key):='SYS';
password(tab_key):='0RACL39';
hash(tab_key):='E7686462E8CD2F5E';
----------------------
tab_key:=504;
username(tab_key):='SYS';
password(tab_key):='0RACL38I';
hash(tab_key):='691C5E7E424B821A';
----------------------
tab_key:=505;
username(tab_key):='SYS';
password(tab_key):='D_SYSPW';
hash(tab_key):='43BE121A2A135FF3';
----------------------
tab_key:=506;
username(tab_key):='SYS';
password(tab_key):='ORACLE';
hash(tab_key):='8A8F025737A9097A';
----------------------
tab_key:=507;
username(tab_key):='SYS';
password(tab_key):='SYSPASS';
hash(tab_key):='66BC3FF56063CE97';
----------------------
tab_key:=508;
username(tab_key):='SYS';
password(tab_key):='MANAG3R';
hash(tab_key):='57D7CFA12BB5BABF';
----------------------
tab_key:=509;
username(tab_key):='SYS';
password(tab_key):='ORACL3';
hash(tab_key):='A9A57E819B32A03D';
----------------------
tab_key:=510;
username(tab_key):='SYS';
password(tab_key):='0RACLE';
hash(tab_key):='2905ECA56A830226';
----------------------
tab_key:=511;
username(tab_key):='SYS';
password(tab_key):='0RACL3';
hash(tab_key):='64074AF827F4B74A';
----------------------
tab_key:=512;
username(tab_key):='SYS';
password(tab_key):='ORACLE8';
hash(tab_key):='41B328CA13F70713';
----------------------
tab_key:=513;
username(tab_key):='SYS';
password(tab_key):='ORACLE9';
hash(tab_key):='0B4409DDD5688913';
----------------------
tab_key:=514;
username(tab_key):='SYS';
password(tab_key):='ORACLE8I';
hash(tab_key):='6CFF570939041278';
----------------------
tab_key:=515;
username(tab_key):='SYS';
password(tab_key):='ORACLE9I';
hash(tab_key):='3522F32DD32A9706';
----------------------
tab_key:=516;
username(tab_key):='SYS';
password(tab_key):='0RACLE9I';
hash(tab_key):='BE29E31B2B0EDA33';
----------------------
tab_key:=517;
username(tab_key):='SYS';
password(tab_key):='0RACL39I';
hash(tab_key):='5AC333703DE0DBD4';
----------------------
tab_key:=518;
username(tab_key):='SYSADM';
password(tab_key):='SYSADM';
hash(tab_key):='BA3E855E93B5B9B0';
----------------------
tab_key:=519;
username(tab_key):='SYSADMIN';
password(tab_key):='SYSADMIN';
hash(tab_key):='DC86E8DEAA619C1A';
----------------------
tab_key:=520;
username(tab_key):='SYSMAN';
password(tab_key):='OEM_TEMP';
hash(tab_key):='639C32A115D2CA57';
----------------------
tab_key:=521;
username(tab_key):='SYSMAN';
password(tab_key):='SYSMAN';
hash(tab_key):='447B729161192C24';
----------------------
tab_key:=522;
username(tab_key):='SYSTEM';
password(tab_key):='MANAGER';
hash(tab_key):='D4DF7931AB130E37';
----------------------
tab_key:=523;
username(tab_key):='SYSTEM';
password(tab_key):='SYSTEM';
hash(tab_key):='970BAA5B81930A40';
----------------------
tab_key:=524;
username(tab_key):='SYSTEM';
password(tab_key):='SYS';
hash(tab_key):='8877FF8306EF558B';
----------------------
tab_key:=525;
username(tab_key):='SYSTEM';
password(tab_key):='SYSDBA';
hash(tab_key):='9D7B7F58544DAC8D';
----------------------
tab_key:=526;
username(tab_key):='SYSTEM';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='8BF0DA8E551DE1B9';
----------------------
tab_key:=527;
username(tab_key):='SYSTEM';
password(tab_key):='D_SYSPW';
hash(tab_key):='1B9F1F9A5CB9EB31';
----------------------
tab_key:=528;
username(tab_key):='SYSTEM';
password(tab_key):='ORACLE';
hash(tab_key):='2D594E86F93B17A1';
----------------------
tab_key:=529;
username(tab_key):='SYSTEM';
password(tab_key):='SYSTEMPASS';
hash(tab_key):='4861C2264FB17936';
----------------------
tab_key:=530;
username(tab_key):='SYSTEM';
password(tab_key):='MANAG3R';
hash(tab_key):='135176FFB5BA07C9';
----------------------
tab_key:=531;
username(tab_key):='SYSTEM';
password(tab_key):='ORACL3';
hash(tab_key):='E4519FCD3A565446';
----------------------
tab_key:=532;
username(tab_key):='SYSTEM';
password(tab_key):='0RACLE';
hash(tab_key):='66A490AEAA61FF72';
----------------------
tab_key:=533;
username(tab_key):='SYSTEM';
password(tab_key):='0RACL3';
hash(tab_key):='10B0C2DA37E11872';
----------------------
tab_key:=534;
username(tab_key):='SYSTEM';
password(tab_key):='ORACLE8';
hash(tab_key):='D5DD57A09A63AA38';
----------------------
tab_key:=535;
username(tab_key):='SYSTEM';
password(tab_key):='ORACLE9';
hash(tab_key):='69C27FA786BA774C';
----------------------
tab_key:=536;
username(tab_key):='SYSTEM';
password(tab_key):='ORACLE9I';
hash(tab_key):='86FDB286770CD4B9';
----------------------
tab_key:=537;
username(tab_key):='SYSTEM';
password(tab_key):='0RACLE9I';
hash(tab_key):='B171042374D7E6A2';
----------------------
tab_key:=538;
username(tab_key):='SYSTEM';
password(tab_key):='0RACL39I';
hash(tab_key):='D7C18B3B3F2A4D4B';
----------------------
tab_key:=539;
username(tab_key):='SYSTEM';
password(tab_key):='D_SYSTPW';
hash(tab_key):='4438308EE0CAFB7F';
----------------------
tab_key:=540;
username(tab_key):='SYSTEM';
password(tab_key):='ORACLE8I';
hash(tab_key):='FAAD7ADAF48B5F45';
----------------------
tab_key:=541;
username(tab_key):='SYSTEM';
password(tab_key):='0RACLE8';
hash(tab_key):='685657E9DC29E185';
----------------------
tab_key:=542;
username(tab_key):='SYSTEM';
password(tab_key):='0RACLE9';
hash(tab_key):='49B70B505DF0247F';
----------------------
tab_key:=543;
username(tab_key):='SYSTEM';
password(tab_key):='0RACLE8I';
hash(tab_key):='B49C4279EBD8D1A8';
----------------------
tab_key:=544;
username(tab_key):='SYSTEM';
password(tab_key):='0RACL38';
hash(tab_key):='604101D3AACE7E88';
----------------------
tab_key:=545;
username(tab_key):='SYSTEM';
password(tab_key):='0RACL39';
hash(tab_key):='02AB2DB93C952A8F';
----------------------
tab_key:=546;
username(tab_key):='SYSTEM';
password(tab_key):='0RACL38I';
hash(tab_key):='203CD8CF183E716C';
----------------------
tab_key:=547;
username(tab_key):='TAHITI';
password(tab_key):='TAHITI';
hash(tab_key):='F339612C73D27861';
----------------------
tab_key:=548;
username(tab_key):='TALBOT';
password(tab_key):='MT6CH5';
hash(tab_key):='905475E949CF2703';
----------------------
tab_key:=549;
username(tab_key):='TDOS_ICSAP';
password(tab_key):='TDOS_ICSAP';
hash(tab_key):='7C0900F751723768';
----------------------
tab_key:=550;
username(tab_key):='TEC';
password(tab_key):='TECTEC';
hash(tab_key):='9699CFD34358A7A7';
----------------------
tab_key:=551;
username(tab_key):='TEST';
password(tab_key):='TEST';
hash(tab_key):='7A0F2B316C212D67';
----------------------
tab_key:=552;
username(tab_key):='TEST';
password(tab_key):='PASSWD';
hash(tab_key):='26ED9DD4450DD33C';
----------------------
tab_key:=553;
username(tab_key):='TEST_USER';
password(tab_key):='TEST_USER';
hash(tab_key):='C0A0F776EBBBB7FB';
----------------------
tab_key:=554;
username(tab_key):='TESTE';
password(tab_key):='TESTE';
hash(tab_key):='864B0E03A5061B6D';
----------------------
tab_key:=555;
username(tab_key):='TESTPILOT';
password(tab_key):='TESTPILOT';
hash(tab_key):='DE5B73C964C7B67D';
----------------------
tab_key:=556;
username(tab_key):='THINSAMPLE';
password(tab_key):='THINSAMPLEPW';
hash(tab_key):='5DCD6E2E26D33A6E';
----------------------
tab_key:=557;
username(tab_key):='TIBCO';
password(tab_key):='TIBCO';
hash(tab_key):='ED4CDE954630FA82';
----------------------
tab_key:=558;
username(tab_key):='TIP37';
password(tab_key):='TIP37';
hash(tab_key):='B516D9A33679F56B';
----------------------
tab_key:=559;
username(tab_key):='TRACESVR';
password(tab_key):='TRACE';
hash(tab_key):='F9DA8977092B7B81';
----------------------
tab_key:=560;
username(tab_key):='TRACESVR';
password(tab_key):='TRACESVR';
hash(tab_key):='D749D821EADC7F72';
----------------------
tab_key:=561;
username(tab_key):='TRAVEL';
password(tab_key):='TRAVEL';
hash(tab_key):='97FD0AE6DFF0F5FE';
----------------------
tab_key:=562;
username(tab_key):='TSDEV';
password(tab_key):='TSDEV';
hash(tab_key):='29268859446F5A8C';
----------------------
tab_key:=563;
username(tab_key):='TSUSER';
password(tab_key):='TSUSER';
hash(tab_key):='90C4F894E2972F08';
----------------------
tab_key:=564;
username(tab_key):='TURBINE';
password(tab_key):='TURBINE';
hash(tab_key):='76F373437F33F347';
----------------------
tab_key:=565;
username(tab_key):='UDDISYS';
password(tab_key):='UDDISYS';
hash(tab_key):='BF5E56915C3E1C64';
----------------------
tab_key:=566;
username(tab_key):='ULTIMATE';
password(tab_key):='ULTIMATE';
hash(tab_key):='4C3F880EFA364016';
----------------------
tab_key:=567;
username(tab_key):='UM_ADMIN';
password(tab_key):='UM_ADMIN';
hash(tab_key):='F4F306B7AEB5B6FC';
----------------------
tab_key:=568;
username(tab_key):='UM_CLIENT';
password(tab_key):='UM_CLIENT';
hash(tab_key):='82E7FF841BFEAB6C';
----------------------
tab_key:=569;
username(tab_key):='USER';
password(tab_key):='USER';
hash(tab_key):='74085BE8A9CF16B4';
----------------------
tab_key:=570;
username(tab_key):='USER_NAME';
password(tab_key):='PASSWORD';
hash(tab_key):='96AE343CA71895DA';
----------------------
tab_key:=571;
username(tab_key):='USER0';
password(tab_key):='USER0';
hash(tab_key):='8A0760E2710AB0B4';
----------------------
tab_key:=572;
username(tab_key):='USER1';
password(tab_key):='USER1';
hash(tab_key):='BBE7786A584F9103';
----------------------
tab_key:=573;
username(tab_key):='USER2';
password(tab_key):='USER2';
hash(tab_key):='1718E5DBB8F89784';
----------------------
tab_key:=574;
username(tab_key):='USER3';
password(tab_key):='USER3';
hash(tab_key):='94152F9F5B35B103';
----------------------
tab_key:=575;
username(tab_key):='USER4';
password(tab_key):='USER4';
hash(tab_key):='2907B1BFA9DA5091';
----------------------
tab_key:=576;
username(tab_key):='USER5';
password(tab_key):='USER5';
hash(tab_key):='6E97FCEA92BAA4CB';
----------------------
tab_key:=577;
username(tab_key):='USER6';
password(tab_key):='USER6';
hash(tab_key):='F73E1A76B1E57F3D';
----------------------
tab_key:=578;
username(tab_key):='USER7';
password(tab_key):='USER7';
hash(tab_key):='3E9C94488C1A3908';
----------------------
tab_key:=579;
username(tab_key):='USER8';
password(tab_key):='USER8';
hash(tab_key):='D148049C2780B869';
----------------------
tab_key:=580;
username(tab_key):='USER9';
password(tab_key):='USER9';
hash(tab_key):='0487AFEE55ECEE66';
----------------------
tab_key:=581;
username(tab_key):='USUARIO';
password(tab_key):='CLAVE';
hash(tab_key):='1AB4E5FD2217F7AA';
----------------------
tab_key:=582;
username(tab_key):='UTILITY';
password(tab_key):='UTILITY';
hash(tab_key):='81F2423D6811246D';
----------------------
tab_key:=583;
username(tab_key):='UTLBSTATU';
password(tab_key):='UTLESTAT';
hash(tab_key):='C42D1FA3231AB025';
----------------------
tab_key:=584;
username(tab_key):='UTLBSTATU';
password(tab_key):='UTLBSTATU';
hash(tab_key):='860CAE203220650B';
----------------------
tab_key:=585;
username(tab_key):='VEA';
password(tab_key):='VEA';
hash(tab_key):='D38D161C22345902';
----------------------
tab_key:=586;
username(tab_key):='VEH';
password(tab_key):='VEH';
hash(tab_key):='72A90A786AAE2914';
----------------------
tab_key:=587;
username(tab_key):='VERTEX_LOGIN';
password(tab_key):='VERTEX_LOGIN';
hash(tab_key):='DEF637F1D23C0C59';
----------------------
tab_key:=588;
username(tab_key):='VIDEOUSER';
password(tab_key):='VIDEOUSER';
hash(tab_key):='29ECA1F239B0F7DF';
----------------------
tab_key:=589;
username(tab_key):='VIF_DEVELOPER';
password(tab_key):='VIF_DEV_PWD';
hash(tab_key):='9A7DCB0C1D84C488';
----------------------
tab_key:=590;
username(tab_key):='VIF_DEVELOPER';
password(tab_key):='VIF_DEVELOPER';
hash(tab_key):='2EA768BF437E4096';
----------------------
tab_key:=591;
username(tab_key):='VIRUSER';
password(tab_key):='VIRUSER';
hash(tab_key):='404B03707BF5CEA3';
----------------------
tab_key:=592;
username(tab_key):='VRR1';
password(tab_key):='VRR2';
hash(tab_key):='3D703795F61E3A9A';
----------------------
tab_key:=593;
username(tab_key):='VRR1';
password(tab_key):='VRR1';
hash(tab_key):='811C49394C921D66';
----------------------
tab_key:=594;
username(tab_key):='VRR1';
password(tab_key):='UNKNOWN';
hash(tab_key):='3DA1893A5FCA23BF';
----------------------
tab_key:=595;
username(tab_key):='VRR2';
password(tab_key):='VRR2';
hash(tab_key):='A0E2430735F331B2';
----------------------
tab_key:=596;
username(tab_key):='VRR2';
password(tab_key):='VRR2';
hash(tab_key):='7A699D5E19E26F4A';
----------------------
tab_key:=597;
username(tab_key):='WEBCAL01';
password(tab_key):='WEBCAL01';
hash(tab_key):='C69573E9DEC14D50';
----------------------
tab_key:=598;
username(tab_key):='WEBDB';
password(tab_key):='WEBDB';
hash(tab_key):='D4C4DCDD41B05A5D';
----------------------
tab_key:=599;
username(tab_key):='WEBREAD';
password(tab_key):='WEBREAD';
hash(tab_key):='F8841A7B16302DE6';
----------------------
tab_key:=600;
username(tab_key):='WEBSYS';
password(tab_key):='MANAGER';
hash(tab_key):='A97282CE3D94E29E';
----------------------
tab_key:=601;
username(tab_key):='WEBUSER';
password(tab_key):='YOUR_PASS';
hash(tab_key):='FD0C7DB4C69FA642';
----------------------
tab_key:=602;
username(tab_key):='WEST';
password(tab_key):='WEST';
hash(tab_key):='DD58348364219102';
----------------------
tab_key:=603;
username(tab_key):='WFADMIN';
password(tab_key):='WFADMIN';
hash(tab_key):='C909E4F104002876';
----------------------
tab_key:=604;
username(tab_key):='WH';
password(tab_key):='WH';
hash(tab_key):='91792EFFCB2464F9';
----------------------
tab_key:=605;
username(tab_key):='WIP';
password(tab_key):='WIP';
hash(tab_key):='D326D25AE0A0355C';
----------------------
tab_key:=606;
username(tab_key):='WIRELESS';
password(tab_key):='WIRELESS';
hash(tab_key):='EB9615631433603E';
----------------------
tab_key:=607;
username(tab_key):='WK_PROXY';
password(tab_key):='<UNKNOWN>';
hash(tab_key):='3F9FBD883D787341';
----------------------
tab_key:=608;
username(tab_key):='WK_SYS';
password(tab_key):='<UNKNOWN>';
hash(tab_key):='79DF7A1BD138CF11';
----------------------
tab_key:=609;
username(tab_key):='WK_TEST';
password(tab_key):='WK_TEST';
hash(tab_key):='29802572EB547DBF';
----------------------
tab_key:=610;
username(tab_key):='WKADMIN';
password(tab_key):='WKADMIN';
hash(tab_key):='888203D36F64C5F6';
----------------------
tab_key:=611;
username(tab_key):='WKPROXY';
password(tab_key):='WKPROXY';
hash(tab_key):='AA3CB2A4D9188DDB';
----------------------
tab_key:=612;
username(tab_key):='WKPROXY';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='B97545C4DD2ABE54';
----------------------
tab_key:=613;
username(tab_key):='WKPROXY';
password(tab_key):='UNKNOWN';
hash(tab_key):='18F0B0E50B9F7B12';
----------------------
tab_key:=614;
username(tab_key):='WKSYS';
password(tab_key):='WKSYS';
hash(tab_key):='545E13456B7DDEA0';
----------------------
tab_key:=615;
username(tab_key):='WKSYS';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='69ED49EE1851900D';
----------------------
tab_key:=616;
username(tab_key):='WKUSER';
password(tab_key):='WKUSER';
hash(tab_key):='8B104568E259B370';
----------------------
tab_key:=617;
username(tab_key):='WMS';
password(tab_key):='WMS';
hash(tab_key):='D7837F182995E381';
----------------------
tab_key:=618;
username(tab_key):='WMSYS';
password(tab_key):='WMSYS';
hash(tab_key):='7C9BA362F8314299';
----------------------
tab_key:=619;
username(tab_key):='WOB';
password(tab_key):='WOB';
hash(tab_key):='D27FA6297C0313F4';
----------------------
tab_key:=620;
username(tab_key):='WPS';
password(tab_key):='WPS';
hash(tab_key):='50D22B9D18547CF7';
----------------------
tab_key:=621;
username(tab_key):='WSH';
password(tab_key):='WSH';
hash(tab_key):='D4D76D217B02BD7A';
----------------------
tab_key:=622;
username(tab_key):='WSM';
password(tab_key):='WSM';
hash(tab_key):='750F2B109F49CC13';
----------------------
tab_key:=623;
username(tab_key):='WWW';
password(tab_key):='WWW';
hash(tab_key):='6DE993A60BC8DBBF';
----------------------
tab_key:=624;
username(tab_key):='WWWUSER';
password(tab_key):='WWWUSER';
hash(tab_key):='F239A50072154BAC';
----------------------
tab_key:=625;
username(tab_key):='XADEMO';
password(tab_key):='XADEMO';
hash(tab_key):='ADBC95D8DCC69E66';
----------------------
tab_key:=626;
username(tab_key):='XDB';
password(tab_key):='CHANGE_ON_INSTALL';
hash(tab_key):='88D8364765FCE6AF';
----------------------
tab_key:=627;
username(tab_key):='XDP';
password(tab_key):='XDP';
hash(tab_key):='F05E53C662835FA2';
----------------------
tab_key:=628;
username(tab_key):='XLA';
password(tab_key):='XLA';
hash(tab_key):='2A8ED59E27D86D41';
----------------------
tab_key:=629;
username(tab_key):='XNC';
password(tab_key):='XNC';
hash(tab_key):='BD8EA41168F6C664';
----------------------
tab_key:=630;
username(tab_key):='XNI';
password(tab_key):='XNI';
hash(tab_key):='F55561567EF71890';
----------------------
tab_key:=631;
username(tab_key):='XNM';
password(tab_key):='XNM';
hash(tab_key):='92776EA17B8B5555';
----------------------
tab_key:=632;
username(tab_key):='XNP';
password(tab_key):='XNP';
hash(tab_key):='3D1FB783F96D1F5E';
----------------------
tab_key:=633;
username(tab_key):='XNS';
password(tab_key):='XNS';
hash(tab_key):='FABA49C38150455E';
----------------------
tab_key:=634;
username(tab_key):='XPRT';
password(tab_key):='XPRT';
hash(tab_key):='0D5C9EFC2DFE52BA';
----------------------
tab_key:=635;
username(tab_key):='XTR';
password(tab_key):='XTR';
hash(tab_key):='A43EE9629FA90CAE';
----------------------
tab_key:=636;
username(tab_key):='SYSTEM';
password(tab_key):='MANAGER9IFS';
hash(tab_key):='46183074D7EA29A0';
----------------------
tab_key:=637;
username(tab_key):='SCOTT';
password(tab_key):='TIGER9IFS';
hash(tab_key):='A53ECFD6E124729D';
----------------------
tab_key:=638;
username(tab_key):='GUEST';
password(tab_key):='WELCOME9IFS';
hash(tab_key):='54CF6A9DC2276702';
----------------------

	for lv_user in c_user loop
		for i in 1..tab_key loop
			if lv_user.username=username(i) then
				if lv_user.password=hash(i) then
					dbms_output.put_line(username(i)||' / '||password(i)||'     ['||lv_user.account_status||']');
					exit;
				end if;
			end if;
		end loop;
	end loop;
end;
/
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>



clear col



--- =========================================
--- =========================================
--- =====   PASSWORDS IN DBLINKS      =======
--- =========================================
--- =========================================




-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting DBlinks...
	prompt 
	prompt
set termout off


clear col
col name format a40
col userid format a20
col password format a18
col host format a40

set linesize 121


	prompt <br>
	prompt
	prompt <b>.DBLINKS.</b>
	prompt
	prompt <pre>
	select name, userid, password, host from sys.link$;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>




--- =========================================
--- =========================================
--- ===== ACCESS TO RESTRICTED OBJECTS ======
--- =========================================
--- =========================================




-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting RESTRICTED OBJECTS ACCCESS...
	prompt 
	prompt
set termout off


clear col
col privilege for a20
col grantee for a25
col table_name for a40
set linesize 90



	prompt <br>
	prompt
	prompt <b>.RESTRICTED OBJECTS ACCESS.</b>
	prompt
	prompt 'ALL_USERS','AUD$','LINK$','ALL_DB_LINKS', 'DBMS_SYSTEM'
	prompt
	prompt <pre>
	select privilege, grantee, table_name from dba_tab_privs
	where OWNER = 'SYS'
	and table_name IN ('LINK$','AUD$','ALL_USERS','ALL_DB_LINKS', 'DBMS_SYSTEM')
	and grantee not like ('%_CATALOG_ROLE');
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>





--- =========================================
--- =========================================
--- =====      ACCOUNT POLICIES       =======
--- =====                             =======
--- =====        VERIFY FUNCTION      =======       
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting Account/Passwords Policy ...
	prompt 
	prompt  
set termout off

clear col

column profile format a30;
column resource_name format a30;
column limit format a20;

set linesize 82


	prompt <br>
	prompt
	prompt <b>.USER PROFILES.</b>
	prompt
	prompt <pre>
	select profile, resource_name, limit from dba_profiles 
	where RESOURCE_TYPE <> 'KERNEL' order by profile;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>


--- =========================================
--- =========================================
--- =====      USERS IN PROFILES      =======
--- =========================================
--- =========================================

-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting users in profiles ...
	prompt 
	prompt  
set termout off

clear col

column profile format a30;
column resource_name format a30;
column limit format a20;

set linesize 82


	prompt <br>
	prompt
	prompt <b>.TOTAL USERS IN PROFILES.</b>
	prompt
	prompt <pre>
        select count(d.username)TOT_USERS, d.profile
          from dba_users d
         where d.profile in (select distinct(u.profile) from dba_users u)
         group by profile;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>


--- =========================================
--- =========================================
--- ===== os AUTHENTICATION PREFIX    =======
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting OS Authentications Prefix...
	prompt 
	prompt  
set termout off

clear col

column name format a28;
column value format a15;

set linesize 70


	prompt <br>
	prompt
	prompt <b>.AUTHENT PREFIX.</b>
	prompt
	prompt <pre>
	select name, value from sys.v_$parameter where name like '%remote_os_%' and upper(value) <> 'FALSE' ;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>



--- =========================================
--- =========================================
--- ===== PREFIX dblink_encrypt_login ======
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting parameter dblink_encrypt...
	prompt 
	prompt  
set termout off

clear col

column name format a28;
column value format a15;

set linesize 70


	prompt <br>
	prompt
	prompt <b>.DBLink_encrypt.</b>
	prompt
	prompt <pre>
	select name, value from sys.v_$parameter where name = 'dblink_encrypt_login' and upper(value) <> 'TRUE' ;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>




--- =========================================
--- =========================================
--- = PREFIX O7_DICTIONARY_ACCESSIBILITY  ===
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting Parameter O7_DICTIONARY...
	prompt 
	prompt  
set termout off

clear col

column name format a28;
column value format a15;

set linesize 70


	prompt <br>
	prompt
	prompt <b>.O7_DICTIONARY.</b>
	prompt
	prompt <pre>
	select name, value from sys.v_$parameter where upper(name) = 'O7_DICTIONARY_ACCESSIBILITY' and upper(value) <> 'FALSE' ;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>




--- =========================================
--- =========================================
--- == PASSWORDS FILE FOR  REMOTE ACCESS   ==
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting Remote Logins...
	prompt 
	prompt  
set termout off

clear col

column name format A28;
column value format A26;

set linesize 55


	prompt <br>
	prompt
	prompt <b>.REMOTE LOGINS.</b>
	prompt
	prompt <pre>
	select name, value from sys.v_$parameter where name = 'remote_login_passwordfile' and upper(value) <> 'NONE';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>







--- =========================================
--- =========================================
--- ==           DBA_SYS_PRIVS             ==
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting privileges "ADMIN OPTION"...
	prompt 
	prompt  
set termout off

clear col


COLUMN USERNAME FORMAT A40

set linesize 111


	prompt <br>
	prompt
	prompt <b>.ADMIN OPTION.</b>
	prompt
	prompt <pre>
select grantee, privilege,  ADMIN_OPTION
from dba_sys_privs
where grantee not in 
('SYS','SYSTEM','CONNECT','RESOURCE','DBA','MDSYS','RECOVERY_CATALOG_OWNER','IMP_FULL_DATABASE',
'EXP_FULL_DATABASE','SELECT_CATALOG_ROLE','OUTLN','SNMPAGENT','AQ_ADMINISTRATOR_ROLE','PERFSTAT', 'DATAPUMP_IMP_FULL_DATABASE')
and ADMIN_OPTION= 'YES'
order by grantee;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>





--- =========================================
--- =========================================
--- ==              OLAP_DBA               ==
--- =========================================
--- =========================================



-- set termout on
	prompt 
	prompt     [&MAQUINA. / &INSTANCIA.] Collecting users with "OLAP_DBA"...
	prompt 
	prompt  
set termout off

clear col


COLUMN USERNAME FORMAT A40

set linesize 111


	prompt <br>
	prompt
	prompt <b>.OLAP_ADMIN.</b>
	prompt
	prompt <pre>
select grantee, granted_role from dba_role_privs
where granted_role = 'OLAP_DBA' and grantee not in 
('SYS', 'SYSTEM', 'DBA', 'OLAPSYS') order by grantee;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>





--- =========================================
--- =========================================
--- ==            SPECIAL PRIVS            ==
--- =========================================
--- =========================================




-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting "SPECIAL PRIVS"...
	prompt 
	prompt  
set termout off

clear col

col grantee format a25;
col privilege format a50;

set linesize 80


	prompt <br>
	prompt
	prompt <b>.SPECIAL PRIVS.</b>
	prompt
	prompt <pre>
	select grantee, privilege from dba_sys_privs 
	where privilege 
	in ('ADMINISTER DATABASE TRIGGER', 'ADMINISTER RESOURCE MANAGER', 'ALTER DATABASE', 'ALTER PROFILE', 'ALTER RESOURCE COST', 'ALTER SYSTEM', 'ALTER TABLESPACE', 'ALTER USER', 'AUDIT SYSTEM', 'BECOME USER', 'CREATE PUBLIC DATABASE LINK', 'CREATE PUBLIC SYNONYM', 'CREATE ROLLBACK SEGMENT', 'CREATE TABLESPACE', 'DROP PROFILE', 'DROP PUBLIC DATABASE LINK', 'DROP PUBLIC SYNONYM', 'DROP ROLLBACK SEGMENT', 'DROP TABLESPACE', 'DROP USER', 'MANAGE TABLESPACE', 'CREATE LIBRARY') 
and grantee not in ('MDSYS', 'DBSNMP','DBA','EXP_FULL_DATABASE','IMP_FULL_DATABASE', 'SYS', 'CTXSYS', 'MTXSYS', 'ORDPLUGINS', 'ORDSYS', 'SYSTEM','WMSYS','PERFSTAT','DATAPUMP_IMP_FULL_DATABASE') order by 1,2;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>



--- =========================================
--- =========================================
--- ==            RISK PACKAGES            ==
--- =========================================
--- =========================================




-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting "RISK PACKAGES"...
	prompt 
	prompt  
set termout off

clear col


col privilege format a10;
col owner format a15;
col grantee format a25;
col table_name format a25;



set linesize 80


	prompt <br>
	prompt
	prompt <b>.RISK_PACKAGES.</b>
	prompt
	prompt <pre>

select privilege, owner, table_name, grantee from dba_tab_privs 
where (
(table_name = 'CATSEARCH' and grantee not in ('DBA', 'OUTLN', 'EXECUTE_CATALOG_ROLE')) or
(table_name = 'CTX_DOC') or
(table_name = 'CTX_OUTPUT' and grantee not in ('CTXAPP', 'XDB')) or
(table_name = 'CTX_QUERY') or 
(table_name = 'DBMS_APPLY_ADM_INTERNAL') or 
(table_name = 'DBMS_APPLY_PROCESS') or 
(table_name = 'DBMS_CDC_IMPDP') or 
(table_name = 'DBMS_CDC_IPUBLISH' and grantee not in ('EXECUTE_CATALOG_ROLE')) or  
(table_name = 'DBMS_CDC_ISUBSCRIBE') or 
(table_name = 'DBMS_CDC_PUBLISH' and grantee not in ('EXECUTE_CATALOG_ROLE')) or  
(table_name = 'DBMS_CDC_SUBSCRIBE') or 
(table_name = 'DBMS_CDC_UTILITY' and grantee not in ('SELECT_CATALOG_ROLE')) or  
(table_name = 'DBMS_DATAPUMP') or 
(table_name = 'DBMS_DBUPGRADE') or 
(table_name = 'DBMS_DDL') or 
(table_name = 'DBMS_EXPORT_EXTENSION') or 
(table_name = 'DBMS_FGA' and grantee not in ('EXECUTE_CATALOG_ROLE')) or
(table_name = 'DBMS_LOB' and grantee not in ('WMSYS', 'SYSMAN')) or 
(table_name = 'DBMS_LOGMNR_SESSION' and grantee not in ('EXECUTE_CATALOG_ROLE')) or
(table_name = 'DBMS_METADATA') or 
(table_name = 'DBMS_METADATA_BUILD' and grantee not in ('EXECUTE_CATALOG_ROLE')) or 
(table_name = 'DBMS_METADATA_DPBUILD' and grantee not in ('EXECUTE_CATALOG_ROLE')) or 
(table_name = 'DBMS_METADATA_INT' and grantee not in ('EXECUTE_CATALOG_ROLE')) or 
(table_name = 'DBMS_METADATA_UTIL' and grantee not in ('EXECUTE_CATALOG_ROLE')) or 
(table_name = 'DBMS_RANDOM') or 
(table_name = 'DBMS_REGISTRY' and grantee not in ('WMSYS','EXFSYS', 'DMSYS', 'CTXSYS', 'XDB', 'MDSYS', 'OLAPSYS', 'SYSMAN')) or  
(table_name = 'DBMS_REPCAT' and grantee not in ('EXECUTE_CATALOG_ROLE', 'SYSTEM')) or 
(table_name = 'DBMS_REPCAT_ADMIN' and grantee not in ('EXECUTE_CATALOG_ROLE')) or 
(table_name = 'DBMS_REPCAT_DECL' and grantee not in ('EXECUTE_CATALOG_ROLE')) or 
(table_name = 'DBMS_REPCAT_INSTANTIATE') or 
(table_name = 'DBMS_REPCAT_MIG' and grantee not in ('IMP_FULL_DATABASE')) or 
(table_name = 'DBMS_REPCAT_RGT') or 
(table_name = 'DBMS_REPCAT_RGT_EXP') or 
(table_name = 'DBMS_REPUTIL') or 
(table_name = 'DBMS_SCHEDULER') or 
(table_name = 'DBMS_STATS' and grantee not in ('OE', 'PM', 'IX', 'SH')) or  
(table_name = 'DBMS_SYS_SQL' and grantee not in ('XDB', 'MDSYS')) or  
(table_name = 'DBMS_SYSTEM' and grantee not in ('OEM_MONITOR', 'DMSYS', 'MDSYS')) or  
(table_name = 'DBMS_UPGRADE') or
(table_name = 'DBMS_XDBZ0') or 
(table_name = 'DBMS_XMLSCHEMA') or 
(table_name = 'DBMS_XMLSCHEMA_INT') or 
(table_name = 'DBMS_XRWMV') or 
(table_name = 'DRIDML') or 
(table_name = 'DRILOAD') or 
(table_name = 'DRVXMD') or 
(table_name = 'KUPF$FILE') or 
(table_name = 'KUPM$MCP') or 
(table_name = 'KUPW$WORKER') or 
(table_name = 'MD2') or
(table_name = 'ORDIMGIDXMETHODS') or 
(table_name = 'OUTLN_PKG' and grantee not in ('DBA', 'EXECUTE_CATALOG_ROLE', 'OUTLN')) or   
(table_name = 'OWA_OPT_LOCK') or 
(table_name = 'PRVT_IDX') or 
(table_name = 'PRVT_SAM') or 
(table_name = 'RTREE_IDX') or 
(table_name = 'SDO_CATALOG') or 
(table_name = 'SDO_GEOR_UTL') or 
(table_name = 'SDO_LRS_TRIG_INS') or 
(table_name = 'SDO_PRIDX GEN_RID_RANGE') or 
(table_name = 'SDO_RTREE_ADMIN') or 
(table_name = 'SDO_SAM') or 
(table_name = 'SDO_TUNE') or 
(table_name = 'SDO_UTIL') or 
(table_name = 'WK_SNAPSHOT')
);

	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>








-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting privileges "ANY"...
	prompt 
	prompt  
set termout off
col privilege for a30
col grantee for a50
set linesize 81


	prompt <br>
	prompt
	prompt <b>.PRIVILEGE_ANY.</b>
	prompt
	prompt <pre>
select grantee, privilege from dba_sys_privs
where privilege like '%ANY%'
and grantee not in ('SYS', 'DBA', 'SYSTEM', 'MDSYS', 'CTXSYS', 'IMP_FULL_DATABASE', 'EXP_FULL_DATABASE', 'OLAP_DBA',
'WKSYS', 'ODSYS', 'ODM', 'QS','AQ_ADMINISTRATOR_ROLE', 'OEM_MONITOR', 'OUTLN', 'SNMPAGENT', 'QS_ADM', 'OLAPSYS', 'ORDSYS', 'DBSNMP', 'XDB','QS_ES', 'QS_OS', 'QS_WS','WMSYS','PERFSTAT','ORDPLUGINS','DATAPUMP_IMP_FULL_DATABASE')
and privilege not in ('CREATE ANY OUTLINE','CREATE ANY OUTLINE','DROP ANY OUTLINE','ALTER ANY OUTLINE','ANALYZE ANY');
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting Default TableSpaces...
	prompt 
	prompt  
set termout off

clear col

column account_status format a18;
column default_tablespace format a18;
column temporary_tablespace format a20;

set linesize 105


	prompt <br>
	prompt
	prompt <b>.DEFAULT TABLESPACES.</b>
	prompt
	prompt <pre>
	select username, account_status, default_tablespace, temporary_tablespace 
		from sys.dba_users u
		where  (u.default_tablespace = 'SYSTEM' or 
		       	u.temporary_tablespace = 'SYSTEM') 
		and u.username not in ('SYS', 'SYSTEM', 'MDSYS', 'CTXSYS', 'ORDSYS', 'OUTLN', 'DBSNMP','OSE$HTTP$ADMIN','ORDPLUGINS','WMSYS','PERFSTAT','TRACESVR')
		and u.username not like '%AURORA$%';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>






-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting PUBLIC permission on system privileges...
	prompt 
	prompt  
set termout off

clear col


column grantee      format a32;
column privilege    format a32;
column admin_option format a10;

set linesize 78


	prompt <br>
	prompt
	prompt <b>.PUBLIC SYS.</b>
	prompt
	prompt <pre>
	select grantee, privilege, admin_option from dba_sys_privs 
		where upper(grantee) = 'PUBLIC';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>




--- ====================================================
--- ====================================================
--- ==              AUDITING    OPTIONS               ==
--- ====================================================
--- ====================================================




-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting AUDIT value...
	prompt 
	prompt  
set termout off

clear col

col name format a25;
col value format a50;

set linesize 80


	prompt <br>
	prompt
	prompt <b>.AUDITING CONFIGURATION OPTIONS.</b>
	prompt
	prompt <pre>
	select name, value from sys.v_$parameter where upper(name) like 'AUDIT_TRAIL'
	and upper(value) <> 'TRUE' and upper(value) <> 'DB';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>




-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting Auditing Configutation...
	prompt 
	prompt  
set termout off

clear col

col audit_option format a35;

set linesize 90


	prompt <br>
	prompt
	prompt <b>.AUDITING COMMANDS.</b>
	prompt
	prompt <pre>
	select USER_NAME, AUDIT_OPTION, SUCCESS, FAILURE from dba_stmt_audit_opts 
	where AUDIT_OPTION='CREATE SESSION';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>


-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting TABLESPACE_AUD$...
	prompt 
	prompt  
set termout off


clear col

col name format a25;
col value format a50;

set linesize 80


	prompt <br>
	prompt
	prompt <b>.TABLESPACE_AUD$.</b>
	prompt
	prompt <pre>
	set pages 999
	col TABLESPACE_NAME format a25;
	col SEGMENT_NAME format a25;
	SELECT TABLESPACE_NAME,SEGMENT_NAME FROM DBA_SEGMENTS
	WHERE SEGMENT_NAME IN ('AUD$','I_AUD1') and TABLESPACE_NAME='SYSTEM';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>





-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting public privileges on UTL_packages ...
	prompt 
	prompt  
set termout off


clear col


col privilege for a20
col grantee for a25
col table_name for a40
set linesize 90


	prompt <br>
	prompt
	prompt <b>.UTL_packages.</b>
	prompt
	prompt <pre>
	select privilege, grantee, table_name from dba_tab_privs 
	where table_name in ('UTL_SMTP', 'UTL_TCP', 'UTL_HTTP', 'UTL_FILE')
	and grantee = 'PUBLIC';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>


-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting users with DBA role...
	prompt 
	prompt  
set termout off


clear col
col default_role for a4
col grantee for a25
col admin_option for a4
set linesize 100


	prompt <br>
	prompt
	prompt <b>.USERS_DBA_ROLE.</b>
	prompt
	prompt <pre>
	select grantee, default_role, admin_option from dba_role_privs where granted_role = 'DBA'
	and grantee <> 'SYS' and grantee <> 'SYSTEM';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>

-- ======================================
-- =    VERSIONS COMPATIBILITY          =
-- ======================================

	prompt <br>
	prompt
	prompt <b>.SYSDBA AND SYSOPER USERS.</b>
	prompt
	prompt <pre>
	select * from v$pwfile_users where username <> 'SYS' and username <> 'SYSTEM' and username <> 'INTERNAL' order by 1;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>


-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting privileges "CATALOG_ROLE"...
	prompt 
	prompt  
set termout off

clear col
col granted_role for a30
col grantee for a30
set linesize 61


	prompt <br>
	prompt
	prompt <b>.CATALOG_ROLES.</b>
	prompt
	prompt <pre>
	select grantee, granted_role from dba_role_privs 
	where granted_role in ('SELECT_CATALOG_ROLE', 'EXECUTE_CATALOG_ROLE', 'DELETE_CATALOG_ROLE')
 	and grantee not in ('SYS', 'SYSTEM', 'DBA', 'OLAP_DBA', 'ODM', 'ODM_MTR', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE', 'SH', 'OEM_MONITOR');
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>




--- =========================================
--- =========================================
--- =====      Collect DBA_USERS      =======
--- =========================================
--- =========================================


-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting DBA Users...
	prompt 
	prompt
set termout off

clear col
set linesize 120
col username format a35
col profile format a17
col password format a18
col account_status format a18


	prompt <br>
	prompt
	prompt <b>.DBA_USERS.</b>
	prompt
	prompt <pre>
	-- select username, profile, password, account_status from dba_users;
	select username, profile,'*****************' as password, account_status from dba_users;

	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>


--- =========================================
--- =========================================
--- ===== Collecting Externally users =======
--- =========================================
--- =========================================


-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting externally users...
	prompt 
	prompt
set termout off

clear col
set linesize 120
col username format a35
col profile format a17
col password format a16
col account_status format a18


	prompt <br>
	prompt
	prompt <b>.Externally Users.</b>
	prompt
	prompt <pre>
	SELECT username, profile, password, account_status FROM DBA_USERS WHERE PASSWORD = 'EXTERNAL'
	UNION
	select username, profile,  '*************' as password,  account_status from dba_users where username like 'OPS$%';
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>



--- =========================================
--- =========================================
--- =====             ROLES           =======
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting Roles...
	prompt 
	prompt  
set termout off

clear col

column grantee format A25;
column admin_option format A6;
column default_role format A7;


set linesize 72


	prompt <br>
	prompt
	prompt <b>.ROLES.</b>
	prompt
	prompt <pre>
SELECT * fROM dba_role_privs
where grantee not in ('CTXSYS','DBA','DBSNMP','EXECUTE_CATALOG_ROLE','EXP_FULL_DATABASE',
'IMP_FULL_DATABASE','OEM_MONITOR','OUTLN','SELECT_CATALOG_ROLE','SYS','SYSTEM');
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>



--- =========================================
--- =========================================
--- =====       CPU VERSION           ======= 
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting CPU...
	prompt 
	prompt  
set termout off

clear col

column comments format a30;

set linesize 120


	prompt <br>
	prompt
	prompt <b>.CPU.</b>
	prompt
	prompt <pre>
	select comments, id from sys.registry$history;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>



--- =========================================
--- =========================================
--- =====          Parameter          =======
--- =========================================
--- =========================================



-- set termout on
	prompt 
prompt     [&MAQUINA. / &INSTANCIA.] Collecting Parameters...
	prompt 
	prompt  
set termout off

clear col

column name format a31;
column valor format a55;

set linesize 90


	prompt <br>
	prompt
	prompt <b>.PARAMETERS.</b>
	prompt
	prompt <pre>
	select name, upper(value) valor from sys.v_$parameter
		--where upper(value) in ('TRUE','FALSE') OR upper(name) like '%UTL%'
		order by upper(value), name;
	prompt
	prompt </pre>
	prompt <a HREF=#top><h6>Top</h6></a> 
	prompt <hr>







prompt
prompt
Prompt ----------------------  END OF DATA GATHERING FROM INSTANCE -------------------------
prompt
prompt ---------------------------------   &instancia   --------------------------------- 
prompt
prompt
prompt

set termout off
set feed on




exit
