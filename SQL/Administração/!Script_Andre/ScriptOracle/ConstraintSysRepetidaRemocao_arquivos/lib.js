//-- lib.js: Core JS library for www.oracle.com
var orainfo_exists = false, otnnm_exists = false
var langjsLoad  = false, confirm_is_redirect  = false, survey_is_passthru = false
var dash 		= '<img src="http://oracleimg.com/admin/images/dash.gif" border=0 width=150 height=5 alt="">'
var r_arrow 	= '<img src="http://oracleimg.com/admin/images/r_arrow.gif" border=0 width=10 height=10 alt="">'
var d_arrow 	= '<img src="http://oracleimg.com/admin/images/d_arrow.gif" border=0 width=10 height=10 alt="">'
var tl_img		= '<img src="http://oracleimg.com/admin/images/tl_img.gif" border=0 width=4 height=18 alt="">'
var bl_img		= '<img src="http://oracleimg.com/admin/images/bl_img.gif" border=0 width=4 height=6 alt="">'
var tr_img		= '<img src="http://oracleimg.com/admin/images/tr_img.gif" border=0 width=4 height=18 alt="">'
var br_img		= '<img src="http://oracleimg.com/admin/images/br_img.gif" border=0 width=4 height=6 alt="">'
var l_crnr 		= '<img src="http://oracleimg.com/admin/images/rc_lft.gif" width=4 height=20 alt="">'
var r_crnr 		= '<img src="http://oracleimg.com/admin/images/rc_rt.gif" width=4 height=20 alt="">'
var see_image 	= '<img src="http://oracleimg.com/admin/images/see.gif" width=100 height=25 border=0 alt="">'
var try_image 	= '<img src="http://oracleimg.com/admin/images/try.gif" width=100 height=25 border=0 alt="">'
var buy_image 	= '<img src="http://oracleimg.com/admin/images/buy.gif" width=93 height=35 border=0 alt="">'
var block 		= ''

//-- Determine Frame status
var isFramed = false
if (parent.frames.length != 0) var isFramed = true

//-- Cookie Objects
var ORA_UCM_VER;
var ORA_UCM_INFO;
var ORA_UCM_SRVC;
var ORA_UCM_CMP;
var user_info = new Array()
var otn_info  = new Array()
// MW these constants represent array indexes for user_info array
var FNAME=0, LNAME=1, TITLE=2, EMAIL=3, UID=4
var ROLE=5, Q2=6, Q3=7, Q4=8, Q5=9, OWNER=10, ASCII=11
var OTN_UID=0, OTN_IP=1, OTN_LVL=2
var OPP_LVL=3, OPP_PIN=4

//-- Utility function defs
var min = (60 * 1000)
var hour = (60 * min)
var day = (24 * hour)
var year = (365 * day)

//-- Portlet Style defs
var PLAIN = 3, WWW = 2
var portlet_title1 = "", portlet_title2 = ""

// Campaign Style Defs
var INLINE = 2, WRAPPED = 4

//-- Internal/external Adjustments
if ((location.hostname.indexOf("us.oracle.com") != -1) && (location.hostname != "www-qa.us.oracle.com")) {
	var ora_host 	= "http://www-stage.us.oracle.com"
  var elog_host   = "http://www.oracle.com"
	var odp_host 	= "http://profile-stage.us.oracle.com"
	var auth_host 	= "http://profile-stage.us.oracle.com"
	var apps_host 	= "http://www-stage.oracle.com/appsnet"
	var oln_host 	= "http://www-stage.us.oracle.com/education/oln"
	var iln_host 	= "http://ilearning.oracle.com"
	var emkt_host  = "http://emarketing.oraclecorp.com/pls/cms/";
} else {
	var ora_host 	= "http://www.oracle.com"
  var elog_host   = "http://www.oracle.com"
	var odp_host 	= "https://profile.oracle.com"
	var auth_host 	= "https://profile.oracle.com"
	var apps_host 	= "http://www.oracle.com/appsnet"
	var oln_host 	= "http://www.oracle.com/education/oln"
	var iln_host 	= "http://ilearning.oracle.com"
	var emkt_host  = "http://www.oracle.com";
}

//-- Function Library
function startPage() {
}


function stretch(w, h) {
	return '<img src="http://oracleimg.com/admin/images/stretch.gif" width=' + w + ' height=' + h + ' BORDER=0  alt="">';
}

//-- Window Types
var TOP = 0, NEWS = 1, OTHER = 2, FULL = 3
var warnMsg = "The channel you have selected is available to registered users only.\n\nPlease register or sign in."
var warnSrvc = "Service Required Message."
var warnURL = "/ebusinessnetwork/register.html"
var warnSrvcURL = "/admin/account/index.html"
function promptUser(msgID) {
	if (!msgID) msg = warnMsg;
	else if (msgID = 1){
		msg = warnMsg;
		wurl = warnURL;
	}
	else if (msgID = 2){
		msg = warnSrvc;
		wurl = warnSrvcURL;
	}
	if (confirm (msg))top.location = wurl;
	else return;
}

function goCheck(url, type, srvc) {
	if (!type || type == "") type = TOP;
	if (!orainfo_exists) promptUser(1);
	else {
		if (srvc){
			if (ORA_UCM_SRVC.services.indexOf("/" + srvc + "/") == -1) promptUser(2);
		}
		else {
			if (type == TOP) top.location = "./" + url
			else if (type == NEWS) window.open(url, "newsWin",  "resizable,scrollbars,width=460,height=575,top=0,screenY=0,left=0,screenX=0");
			else if (type == OTHER) window.open(url, "otherWin", "resizable,scrollbars,width=350,height=525,top=0,screenY=0,left=0,screenX=0");
			else if (type == FULL) window.open(url, "fullWin");
		}
	}
}

function goWin(url, type, w, h, scroll) {
	if (!type || type == "") type = 1;
	if (type == 1) top.location = "./" + url;
	else if (type == 2) window.open(url, "smallWin", "toolbar=0,location=0,directories=0,status=0,menubar=0,resizable=1,scrollbars=" + scroll + ",width=" + w + ",height=" + h + ",top=0,screenY=0,left=0,screenX=0");
	else if (type == 3) window.open(url, "fullWin");
}

function concierge(URL) {
  var w = 473;
  var h = 355;
	if (!URL) URL = '/admin/concierge/popup-us-en.html';
	mywin = window.open(URL, "smallWin", "toolbar=0,location=0,directories=0,status=0,menubar=0,resizable=1,scrollbars=0,width=" + w + ",height=" + h + ",top=0,screenY=0,left=0,screenX=0");
  mywin.focus();
}

function startPage() {
}



function goOLN() {
  ORA_UCM_VER   = top.ORA_UCM_VER;
  ORA_UCM_INFO  = top.ORA_UCM_INFO;
  ORA_UCM_SRVC  = top.ORA_UCM_SRVC;
  if (!isUCMRegistered()) {
    location = ora_host + "/admin/account/oln/oln_login.html";
	}
  else if (top.ORA_UCM_SRVC.services.indexOf("/OLN/") == -1) {
    if(top.ORA_UCM_SRVC.services.indexOf("/EMP/") == -1) {
      location = "/admin/account/oln/oln_msg.html";
    } else {
      top.location = iln_host;
      // var ilnwin = window.open(iln_host, "iln", "toolbar=1,location=1,directories=1,status=1,menubar=1,resizable=1,scrollbars=1,width=800,height=600");
      // top.location = ora_host + "/education/oln/index.html";
		  // ilnwin.focus();
    }
  } else {
      top.location = iln_host;
    // var ilnwin = window.open(iln_host, "iln", "toolbar=1,location=1,directories=1,status=1,menubar=1,resizable=1,scrollbars=1,width=800,height=600");
    // top.location = ora_host + "/education/oln/index.html";
    // ilnwin.focus();
  }
}


function fix_action(host, form, action){
	form.action = host + action;
	return true;
}

function getName(){
	// MW: modify to check if name is printable (ascii & not null)
	if (isUCMRegistered()) {
		if ( (ORA_UCM_INFO.ascii == 1) && (ORA_UCM_INFO.firstname != "null") && (ORA_UCM_INFO.lastname != "null")) {
			return ORA_UCM_INFO.firstname + " " + ORA_UCM_INFO.lastname;
		} else {
			return ORA_UCM_INFO.username;
		}
	} else {
		return "";
	}
}

function getUID(){
	if (isUCMRegistered()) return ORA_UCM_INFO.username;
	else return "";
}

function getArg(arg_name, str) {
	var value = "", tmpstr = "";
	if (!str) str = location.search.substring(1);
	if (!str) return value;
	else {
		var tmparray = str.split("&");
		for (i=0; i<tmparray.length; i++) {
			tmpstr = tmparray[i].toUpperCase();
			if (tmpstr.indexOf(arg_name.toUpperCase() + "=") != -1) {
				var tmp2array = tmparray[i].split("=");
				value = tmp2array[1];
			}
		}
	}
	return value;
}

function signout(url) {
/*
	var exp = new Date();
	exp.setYear(70);
	var exp_str = "expires=" + exp.toGMTString() + "; domain=.oracle.com; path=/;";
	document.cookie = "ORA_UCM_VER=;" + exp_str;
	document.cookie = "ORA_UCM_INFO=;" + exp_str;
	document.cookie = "ORA_UCM_SRVC=;" + exp_str;
	top.location = url;
*/
    rUrl = window.location.href; 
    window.location="http://profile.oracle.com/jsp/reg/signout.jsp?logouturl="+rUrl; //stage only
}

function signin(current) {
  var current = (current) ? current : top.location;
  var URL = auth_host + "/jsp/reg/register.jsp?act=5&src=1180588&nextURL=" + escape(current);
  top.location = URL;
}


//-- Get and Set Language based information
//-- This can be moved to lang.js file when ready
var language_root  	= "";
var print_label    	= "Printer View";

// UCM Cookie Libraries //
function existsUCMCookie(s) {
	if (s == "ORA_UCM_VER") {
		if ((ORA_UCM_VER.version != null) &&
			(ORA_UCM_VER.username != null) &&
			(ORA_UCM_VER.username_enc != null) &&
			(ORA_UCM_VER.ipaddress != null) &&
			(ORA_UCM_VER.ipaddress_enc != null) ) {
		return true;
		}
	}
	else if (s == "ORA_UCM_INFO") {
		//MW: reduce for v2 cookies
		if ((ORA_UCM_INFO.version != null) &&
			(ORA_UCM_INFO.guid != null) &&
			(ORA_UCM_INFO.username != null)) {
		return true;
		}
	}
	else if (s == "ORA_UCM_SRVC") {
		if ((ORA_UCM_SRVC.value != null) &&
			(ORA_UCM_SRVC.version != null)) {
		}
		return true;
	}
	// Added by cyappert
	else if (s == "ORA_UCM_CMP") {
		if ((ORA_UCM_CMP.value != null) &&
			(ORA_UCM_CMP.version != null)) {
		}
		return true;
	}

	return false;
}
function isUCMRegistered() {

	if (existsUCMCookie("ORA_UCM_INFO") == true) {
		orainfo_exists = true;
		otnnm_exists = true;
		return true;
	}
	return false;
}
function isUCMAnonymous() {

	if ( (ORA_UCM_INFO.version != null) &&
		(ORA_UCM_INFO.guid != null) &&
		(isUCMRegistered() == false) ) {
	return true;
	}
	return false;
}
function getUCMCookies() {
	ORA_UCM_VER   = new private_ORA_UCM_VER();
	ORA_UCM_INFO  = new private_ORA_UCM_INFO();
	ORA_UCM_SRVC  = new private_ORA_UCM_SRVC();
}
function private_ORA_UCM_VER () {

	this.value_enc = getCookieData("ORA_UCM_VER");
	this.value     = private_UCMCookieDecode(this.value_enc);
	this.array     = this.value.split("OR1:");

	this.version       = this.array[0];
	this.username      = this.array[1];
	this.username_enc  = this.array[2];
	this.ipaddress     = this.array[3];
	this.ipaddress_enc = this.array[4];
}
//-- Cookie Functions
//JB: moved checkCMP to reglet.js

function readInfoCookie() {
//MW: Modify to support v2 cookie
	getUCMCookies();
	if (isUCMRegistered() == true) {
		orainfo_exists = true;
		user_info[FNAME] = ORA_UCM_INFO.firstname;
		user_info[LNAME] = ORA_UCM_INFO.lastname;
		user_info[TITLE] = ORA_UCM_INFO.title;
		user_info[EMAIL] = ORA_UCM_INFO.email;
		user_info[UID]   = ORA_UCM_INFO.username;
		user_info[ROLE]  = ORA_UCM_INFO.interest1;
		user_info[Q2]    = ORA_UCM_INFO.interest2;
		user_info[Q3]    = ORA_UCM_INFO.interest3;
		user_info[Q4]    = ORA_UCM_INFO.interest4;
		user_info[Q5]    = ORA_UCM_INFO.interest5;
		user_info[ASCII] = ORA_UCM_INFO.ascii;
	}
	return true;
}

function private_ORA_UCM_INFO() {
  this.value_enc   = getCookieData("ORA_UCM_INFO");

  // check for new or old cookie format
  if (this.value_enc.substr(0,4) == "/MP/") { // this is version 1

    this.value       = private_UCMCookieDecode(this.value_enc);
    this.array       = this.value.split("OR1:");

    this.version      = this.array[0];
    this.guid         = this.array[1];
    this.firstname    = this.array[2];
    this.lastname     = this.array[3];
    this.username     = this.array[4];
    this.email        = this.array[5];
    this.companyname  = this.array[6];
    this.title        = this.array[7];
    this.country      = this.array[8];
    this.language     = this.array[9];
    this.characterset = this.array[10];
    this.interest1    = this.array[11];
    this.interest2    = this.array[12];
    this.interest3    = this.array[13];
    this.interest4    = this.array[14];
    this.interest5    = this.array[15];
    // MW: old cookies only support ascii first and last name
    this.ascii		  = 1;


  } else { // this is version 2 or 3

    this.array       = this.value_enc.split("~");

    this.version      = this.array[0];
    this.guid         = this.array[1];
    this.firstname    = this.array[2];
    this.lastname     = this.array[3];
    this.username     = this.array[4];
    this.country      = this.array[5];
    this.language     = this.array[6];
    this.interest1    = this.array[7];
    this.interest2    = this.array[8];
    this.interest3    = this.array[9];
    this.interest4    = this.array[10];
    this.ascii        = this.array[11];
    this.email        = this.username;
    this.companyname  = null;
    this.title        = null;
    this.characterset = null;
    this.interest5    = null;
  }

  // upgrade from v2 to v3
  if (this.version == 2) {

    // interest 1
    var Jobs = new Array();
    Jobs["2"]  = "";
    Jobs["3"]  = "";
    Jobs["-1"] = "";
    Jobs["5"]  = "";
    Jobs["8"]  = "";
    Jobs["0"]  = "";
    Jobs["23"] = 33;
    Jobs["31"] = 22;
    Jobs["4"]  = 33;
    Jobs["1"]  = 33;
    if (Jobs[this.interest1]!=null)
      this.interest1 = Jobs[this.interest1];

    // interest 2
    if (this.interest2!=null) {
      var OldIndustries = this.interest2.split("/");
      for (i=1; i<OldIndustries.length; i++) {
        if (OldIndustries[i]!=null) {
          this.interest2 = OldIndustries[i];
          i = OldIndustries.length;
        }
      }
    }

    var Industries = new Array();
    Industries["1"]  = 40;
    Industries["3"]  = 13;
    Industries["5"]  = 13;
    Industries["7"]  = 40;
    Industries["9"]  = 10;
    Industries["12"] = 34;
    Industries["14"] = 13;
    Industries["15"] = 33;
    Industries["16"] = 34;
    Industries["18"] = 22;
    Industries["19"] = 19;
    Industries["22"] = 41;
    Industries["26"] = 27;
    Industries["28"] = 27;
    Industries["29"] = 10;
    Industries["30"] = 8;
    Industries["32"] = 34;
    Industries["41"] = 13;
    Industries["43"] = 20;
    if (Industries[this.interest2]!=null)
      this.interest2 = Industries[this.interest2];

    // interest 3
    var Relationships = new Array();
    Relationships["0"] = 6;
    Relationships["2"] = "";
    Relationships["3"] = "";
    Relationships["4"] = "";
    if (Relationships[this.interest3]!=null)
      this.interest3 = Relationships[this.interest3];

    var newCookie = [
      "3", this.guid, this.firstname,
      this.lastname, this.username, this.country,
      this.language, this.interest1, this.interest2,
      this.interest3, this.interest4, this.ascii,
      this.email, this.companyname, this.title,
      this.characterset, this.interest5
    ];

    var cookieData = newCookie.join("~");
    setCookie("ORA_UCM_INFO", cookieData, 1, "year");
  }
}

function private_ORA_UCM_SRVC () {
  this.value_enc = getCookieData("ORA_UCM_SRVC");
  var delimiter; // used to do the second split

  // check for encoded version
  if (this.value_enc.substr(0,4) == "/QT/") { // version 1
    this.value     = private_UCMCookieDecode(this.value_enc);
    this.array     = this.value.split("SV1:");
    delimiter = "OR1:";
  } else { // version 2
    this.array     = this.value_enc.split("*");
    delimiter = "~";
  }

  this.version    = this.array[0];
  this.services   = '/';

  for (i=1; i<this.array.length; i++) {
    this.srvc_pieces = this.array[i].split(delimiter);

    eval ('this.' + this.srvc_pieces[0] + ' = new Array();');
    eval ('this.' + this.srvc_pieces[0] + '.code   = this.srvc_pieces[0];');
    eval ('this.' + this.srvc_pieces[0] + '.member = this.srvc_pieces[1];');
    eval ('this.' + this.srvc_pieces[0] + '.admin  = this.srvc_pieces[2];');
    eval ('this.' + this.srvc_pieces[0] + '.role   = this.srvc_pieces[3];');

    if (this.srvc_pieces[4] != null || this.srvc_pieces[4] != "") {
      eval ('this.' + this.srvc_pieces[0] + '.extra  = this.srvc_pieces[4].split("SE1:");');
    }
    this.services += this.srvc_pieces[0];
    this.services += '/';
  }
}

// MW: this is only used for v1 cookies
function private_UCMCookieDecode(value) {
	var asciiArray = " !\"#$&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~.";
	var urldecodevalue = unescape(value);
	var ucmdecodevalue = '';
	var ch = '';

	for (i=0; i<urldecodevalue.length; i++) {

		ch = urldecodevalue.charAt(i)
		j = asciiArray.indexOf(ch);
		if (j != -1) {

			j +=2;
			if( j > ( asciiArray.length - 1 ) ) {
				j -= asciiArray.length;
			}
			ucmdecodevalue += asciiArray.charAt( j );
		}
		else {
			ucmdecodevalue += ch;
		}
	}
	return ucmdecodevalue;
}

function getCookieData(label) {
	var labelLen = label.length
	var cLen = document.cookie.length
	var i = 0
	var cEnd
	while (i < cLen) {
	var j = i + labelLen
	if (document.cookie.substring(i,j) == label) {
		cEnd = document.cookie.indexOf(";",j)
		if (cEnd == -1) {
			cEnd = document.cookie.length
		}
	j++;
	return unescape(document.cookie.substring(j,cEnd))
	}

	i++
	}

	return "";
}

function setCookie(name, value, time, ttype) {
	var exp = new Date();
	var cookieval = name + "=" + value + "; ";
	var date = exp.getTime();
	if (time > 0) {
      	if (ttype == "year") exp.setTime(date + (time * year));
		else if (ttype == "day") exp.setTime(date + (time * day));
		else if (ttype == "hour") exp.setTime(date + (time * hour));

      	cookieval += "expires=" + exp.toGMTString();
	}
    cookieval += "; domain=.oracle.com; path=/";
	document.cookie = cookieval;
}

function getCookie(foo) {
	return getCookieData(foo);
}

//-- Hipbone to Netcall mapping
//-- contact john burbridge to make changes!!
function startCallback(ichannel,tmp) {

  var netcall_url = "http://" + location.hostname + "/admin/netcall/";
  var w = 440;
  var h = 260;

  var codes = new Array();
  codes[0] = [ "Oracle.com", "0i2wzK12842", "321884", "0", "0", "1", "launcher.html", "thankyou.html", "error.html", "5:00am - 6:00pm PST"  ];
  codes[1] = [ "Oracle Education", "2WcKOh12631", "322065", "0", "0", "1", "launcher.html", "thankyou.html", "error.html", "5:00am - 5:00pm PST"  ];
  codes[2] = [ "Oracle Brazil", "QoEOxb13081", "344401", "0", "0", "55", "launcher-br.html", "thankyou-br.html", "error-br.html", "9h00 - 18h00"  ];
  codes[3] = [ "Oracle Consulting", "invalid", "379366", "0", "0", "1", "launcher.html", "thankyou.html", "error.html", " "  ];
  codes[4] = [ "Oracle Netherlands", "8StUfs2022", "365383", "0", "0", "31", "launcher.html", "thankyou.html", "error.html", " "  ];
  codes[5] = [ "Oracle UK", "EIKzPM13381", "365383", "0", "0", "44", "launcher.html", "thankyou.html", "error.html", "9:00am - 6:00pm"  ];
  codes[6] = [ "Oracle France", "Osyzdu3268", "365383", "0", "0", "33", "launcher-fr.html", "thankyou-fr.html", "error-fr.html", "9h à 18h CET"  ];
  codes[7] = [ "Oracle Portugal", "okWd3e3309", "365383", "0", "0", "351", "launcher.html", "thankyou.html", "error.html", "9:00am - 6:00pm"  ];
  codes[8] = [ "Oracle Spain", "1M4DJm3310", "365383", "0", "0", "34", "launcher.html", "thankyou.html", "error.html", " "  ];

	for (var i = 0; i < codes.length; i++) {
		if (ichannel == codes[i][1]) {

      // build url
      var url = netcall_url  + codes[i][6]+
        "?memberid=" + codes[i][2] +
        "&country=" + codes[i][5] +
        "&responseurl=" + netcall_url  + codes[i][7] +
        "&errorurl=" + netcall_url  + codes[i][8] +
        "&timezone=" + escape(codes[i][9]);

      // adjust window size if necessary
      width = ((codes[i][3] == 0) ? w : codes[i][3]);
      height = ((codes[i][4] == 0) ? h : codes[i][4]);

      win = window.open(url,'netcall',"width=" + width + ",height="+ height +",scrollbars=yes,resizable=yes,menubar=no,location=no");
      win.opener = self;
			break;
		}
	}
}

libjsLoad = true;

//-- elogger.js: JS library for the elogger
var g_url = elog_host + "/webapps/elog/trackurl";
var base_url	= "http://" + location.hostname;

function escapeURL(p_text) {
  re1 = /\&/gi;
  re2 = / /gi;
  re3 = /\+/gi;
 var  p_str = p_text;
  p_str = p_str.replace(re1,"%26");
  p_str = p_str.replace(re2,"%2B");
  p_str = p_str.replace(re3,"%2B");
  return p_str;
}

function goAURL(p_url,  p_object_id, p_subobject_id)  {
 	getUCMCookies();
  ORA_UCM_VER   = top.ORA_UCM_VER;
  ORA_UCM_INFO  = top.ORA_UCM_INFO;
  ORA_UCM_SRVC  = top.ORA_UCM_SRVC;

	if (!isUCMRegistered()) {
		alert("You don't appear to be signed in." + " Please sign-in or register to the upper right.");
	} else {
		goURL(p_url,  p_object_id, p_subobject_id);
	}

}

function trackURL(p_url,  p_object_id, p_subobject_id)  {

  var from_url = escapeURL(document.URL);
  var to_url = escapeURL(p_url);
  var dest_url = "";
  var src_url = "";
  var trackable_url = "";

  dest_url = (to_url.indexOf("http") == -1) ? base_url + to_url : to_url;
  src_url = (from_url.indexOf("http") == -1) ? base_url + from_url : from_url;

  trackable_url = g_url + "?d=" + dest_url + "&s=" + src_url +  "&di="  + p_object_id ;
  return trackable_url;
}

function goURL(p_url, p_object_id, p_subobject_id)  {
  trackable_url = trackURL(p_url,p_object_id,p_subobject_id);
  location = trackable_url;
}

// for 1x1 images
function logURL(p_object_id, p_subobject_id ) {

 var from_url = escapeURL(document.referrer);
 var  to_url = escape(document.URL);
 var dest_url = "";
 var src_url = "";
 var trackable_url = "";
   if ( to_url.indexOf("http") == -1)   dest_url = base_url + to_url;
   if ( from_url.indexOf("http") == -1) src_url = base_url + from_url;

   trackable_url = g_url + "?d=" + dest_url + "&s=" + src_url +  "&di="  + p_object_id   + "&a=image" ;
   document.write("<img src=\"" + trackable_url + "\">");
}

//for ebn show the Ondemand window and show Quote window
function showOndemand(showid, cmsid, regsite, bitrate) {
  var v_regsite;
  var v_bitrate;
  if (!bitrate) v_bitrate = 'L150'; else v_bitrate = bitrate;
  if (!regsite) v_regsite = ''; else v_regsite = regsite;
	mywin = SpecialWin("onDemandWin", "popup.on_demand", showid, cmsid, v_regsite, v_bitrate, "N", 405, 675);
}
function showOndemand2(showid, cmsid, src, act, bitrate) {
  var v_bitrate;
  if (!bitrate) v_bitrate = 'L150'; else v_bitrate = bitrate;
	if(src && act) {
	  getUCMCookies();
  	if (!isUCMRegistered()) {
    	if ( confirm("This functionality is available to registered users only.\n\nWould you like to register or sign in?\n\n") ) {
      	top.location = auth_host + "/jsp/reg/register.jsp?src="+src+"&Act="+act;
	    }
  	  return;
	  }
	}
	mywin = SpecialWin("onDemandWin", "popup.on_demand", showid, cmsid, '', v_bitrate, "N", 405, 675);
}
function showISeminar(showid, cmsid, regsite, bitrate) {
  if(parseInt(showid)<=1546274) {
    var v_regsite;
    var v_bitrate;
    if (!bitrate) v_bitrate = 'L150'; else v_bitrate = bitrate;
    if (!regsite) v_regsite = ''; else v_regsite = regsite;
  	mywin = SpecialWin("ISeminarWin", "iseminar_viewer.ondemand", showid, cmsid, v_regsite, v_bitrate, "Y", 635, 450);
  } else {
    showLiveViewer(showid,cmsid,1180587,6);
  }
}

function showLiveViewer(showid,cmsid,src,act) {
    if(src && act) {
      getUCMCookies();
      if (!isUCMRegistered()) {
        if ( confirm("This functionality is available to registered users only.\n\nWould you like to register or sign in?\n\n") ) {
          top.location = auth_host + "/jsp/reg/register.jsp?src="+src+"&Act="+act;
        }
        return;
      }
    }

    var vWidth = 800;
    var vHeight = 600;
    var vTop = Math.ceil((screen.availHeight - vHeight)/2) - 25;
    var vLeft = Math.ceil((screen.availWidth - vWidth)/2);

    if(screen.width <= 800) {
      if(screen.width < 700) {
        alert("800x600 screen resolution or higher is recommended.");
      }
      vTop = 0;
      vLeft = 0;
      vWidth = screen.availWidth - 10;
      vHeight = screen.availHeight-46;
    }
    url = "http://www.oracle.com/pls/ebn/live_viewer.main?p_shows_id=" + showid + "&p_referred=" + cmsid;
    window.open(url,"liveWin","top="+vTop+",left="+vLeft+",width="+vWidth+",height="+vHeight+",status=yes,resizable=no");
}
function ISLive(showid, cmsid, regsite, bitrate) {
  var v_regsite;
  var v_bitrate;
  if (!bitrate) v_bitrate = 'L150'; else v_bitrate = bitrate;
  if (!regsite) v_regsite = ''; else v_regsite = regsite;
	mywin = SpecialWin("ISLiveWin", "iseminar_viewer.live", showid, cmsid, v_regsite, v_bitrate, "Y", 635, 600);
}
function screenWatch(showid, cmsid, regsite, bitrate) {
  var v_regsite;
  var v_bitrate;
  if (!bitrate) v_bitrate = ''; else v_bitrate = bitrate;
  if (!regsite) v_regsite = ''; else v_regsite = regsite;
	mywin = SpecialWin("ScreenWatchWin", "screenwatch.video", showid, cmsid, v_regsite, v_bitrate, "N", 812, 637);
}
function SpecialWin(name, purl, showid, cmsid, regsite, bitrate, reg, w, h) {
	mywin=window.open('http://www.oracle.com/pls/ebn/' + purl + '?p_shows_id='+ showid + '&p_regreq=' + reg  + '&p_referred=' + cmsid + '&p_regsite=' + regsite + '&p_win_size=' + bitrate, name,'toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=no,width=' + w + ',height=' + h );
	return mywin;
}
function showDemo(id,ref,vWidth,vHeight)
{
    if(!vHeight) vHeight = 600;
    if(!vWidth) vWidth = 800;
    var vTop = Math.ceil((screen.availHeight - vHeight)/2) - 25;
    var vLeft = Math.ceil((screen.availWidth - vWidth)/2);
    if(screen.width <= 800) {
      if(screen.width < 700) {
        alert("800x600 screen resolution or higher is recommended.");
      }
      vTop = 0;
      vLeft = 0;
      vWidth = screen.availWidth - 10;
      vHeight = screen.availHeight-46;
    }
  window.open("http://www.oracle.com/pls/ebn/swf_viewer.load?p_shows_id="+id+"&p_referred="+ref+"&p_width="+vWidth+"&p_height="+vHeight,"demoWin","width="+vWidth+",height="+vHeight+",resizable=0,top="+vTop+",left="+vLeft);
}

function open_window( Dest, Name )
{
  lov_win = window.open( Dest, Name, "width=470,height=170,scrollbars=yes,resizable=yes,menubar=yes,location=yes,status=yes,toolbar=yes" );
  lov_win.opener = self;
}

function Shwing(login, page, name, popup_width, popup_height) {
	var test = login.indexOf('%');
	if (test < 0) login = escape(login);
	page = page + '&args=' + login;
	window.open(page, name, 'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=no,copyhistory=no,scrollbars=yes,width=' + popup_width + ',height=' + popup_height);
}

function drawIdentBlock() {
	getUCMCookies();
	if (isUCMRegistered()) {
		// MW: must check ascii flag for v2 cookies
	    if (ORA_UCM_INFO.ascii == 1) {
			var uname = ORA_UCM_INFO.firstname + " " + ORA_UCM_INFO.lastname
		} else {
			var uname = ORA_UCM_INFO.username
		}
		block = '<font class="WelcomeOption">&nbsp;Welcome ' + uname + ' (';
		block += '<a class="WelcomeOption" href="javascript:signout(' + "'" + top.location + "'" + ')">Sign Out</A>)</font>\n'
	} else {
		block = '<font class="WelcomeOption">&nbsp;(<a class="WelcomeOption" href="/ebusinessnetwork/admin/register.html" target="_top">Click Here</a> to register for a free Oracle web account)</font>\n'
	}

	document.write(block)
	document.close()
}












