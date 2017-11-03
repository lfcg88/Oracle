// Core JS library for oracle.com
// Created by: Vivek Mehrotra

function goWin(url, x, w, h, scroll) {
 if (!x || x=="") x=1;
 if (x==1) top.location="./"+url
 else if (x==2) window.open(url,"smallWin","toolbar=0,location=0,directories=0,status=0,menubar=0,resizable=1,scrollbars="+scroll+",width="+w+",height="+h+",top=0,screenY=0,left=0,screenX=0")
 else if (x==3) window.open(url,"fullWin")
}
// elogger
var gUrl="http://www.oracle.com/elog/trackurl";
var baseUrl="http://"+location.hostname;
var fromUrl=escapeURL(document.URL);
var refUrl=escapeURL(document.referrer); 

function escapeURL(p_txt) {
 r1= /\&/gi;
 r2= / /gi;
 r3= /\+/gi;
 var t=p_txt;
 t=t.replace(r1,"%26");
 t=t.replace(r2,"%2B");
 t=t.replace(r3,"%2B");
 return t;
}
function trackURL(p_url, p_object_id, p_subobject_id) {
 var toUrl=escapeURL(p_url);
 var destUrl="";
 var srcUrl="";
 var trackbleUrl="";
 if (toUrl.indexOf("http")==-1) destUrl=baseUrl+toUrl;
 if (fromUrl.indexOf("http")==-1) srcUrl=baseUrl+fromUrl;
 trackbleUrl=gUrl+"?d="+destUrl+"&s="+srcUrl+"&di="+p_object_id ;
 return trackbleUrl;
}
function goURL(p_url, p_object_id, p_subobject_id) {
 location=trackURL(p_url,p_object_id,p_subobject_id);
}
function logURL(p_object_id, p_subobject_id ) {
 var destUrl="";
 var srcUrl="";
 var trackbleUrl="";
 if (fromUrl.indexOf("http")==-1) destUrl=baseUrl+fromUrl;
 if (refUrl.indexOf("http")==-1) srcUrl=baseUrl+refUrl;
 trackbleUrl=gUrl+"?d="+destUrl+"&s="+srcUrl+"&di="+p_object_id+"&a=image" ;
 document.write("<img src=\""+trackbleUrl+"\">");
}
// OTN leftnav
function dropdown(mySel)
{
 var myWin, mV;
 mV=mySel.options[mySel.selectedIndex].value;
 if(mV) {
  if(mySel.form.target) myWin=parent[mySel.form.target]; 
  else myWin=window;
  if (!myWin) return true;
  myWin.location=mV;
 }
 return false;
}
// viewlets
function isViewletCompliant()
{
 ans=true;
 version=Math.round(parseFloat(navigator.appVersion) * 1000);
 if (navigator.appName.substring(0,9)=="Microsoft")
  if(version<4000) ans=false;
 if (navigator.appName.substring(0,8)=="Netscape")
  if ((navigator.appVersion.indexOf("Mac")> 0)&&(version<5000)) ans=false;
   else if (version<4060) ans=false;
 plugins=navigator.plugins;
 if (!ans && plugins!=null)
  for(i=0;i!=plugins.length;i++)
   if((plugins[i].name.indexOf("Java Plug-in")>=0)&&(plugins[i].name.indexOf("1.0")<0)) ans=true;
 return ans;
}
function openViewlet(htmlFile,htmlWidth,htmlHeight)
{
 str = 'resizable=0,toolbar=0,menubar=0,scrollbars=0,status=0,location=0,directory=0,width=350,height=200';
 if(!isViewletCompliant())
  open("http://www.qarbon.com/warning/index.html",'Leelou',str);
 else
  window.open(htmlFile,'Leelou','width='+htmlWidth+',height='+htmlHeight+',top=10,left=20');
}

var USER = new getUserInfo();

function printWelcome()
{
  var loc= window.location.href;
  var tmp = '<span class="profile">';
  if ( USER.guid )
    tmp += 'Welcome ' + USER.firstname + ' ( <a class="profile" href="javascript:sso_sign_out();">' +
          'Sign Out'+ '</a> | <a class="profile" href="/admin/account/index.html?loc='+loc + '">' + 'Account' + '</a> )';
  else
    tmp += '<a href="' + '/admin/account/index.html?loc='+loc + '">' + '(Sign In / Register for a free Oracle Web account)'+ '</a>';

  tmp += '</span>';
  document.write(tmp);
  document.close();
}

function DrawPrinterView()
{
  var printTemplate = '/ocom/ocom_item_templates/print';

  var Str = window.location.pathname;
  Str = Str.substring( 1 );
  Str = Str.substring( 0, Str.indexOf( '/' ) );
  if ( Str.length == 2 || Str.length == 5 || Str == 'global' ) printTemplate = '/ocom/ocom_item_templates/global/global_print';

  var Str = '<A href="javascript:location=location.pathname+\'?_template='+printTemplate+'\';" target=""><IMG ';
  Str += 'height=15 alt="'+strings.print_label+'" src="/admin/images/print_17x15.gif" width=17 border=0></A> <A class=navlink ';
  Str += 'href="javascript:location=location.pathname+\'?_template='+printTemplate+'\';" target="">'+strings.print_label+'</A> ';
  document.write( Str );
  document.close();
}

/*
function signout(url) {
  var exp = new Date();
  exp.setYear(70);
  var exp_str = "expires=" + exp.toGMTString() + "; domain=.oracle.com; path=/;";
  document.cookie = "ORA_UCM_VER=;" + exp_str;
  document.cookie = "ORA_UCM_INFO=;" + exp_str;
  document.cookie = "ORA_UCM_SRVC=;" + exp_str;
  top.location = url;
}
*/
function signout(url)
{
  rUrl = window.location.href; 
  window.location="http://profile.oracle.com/jsp/reg/signout.jsp?logouturl="+rUrl; //stage only
}
function getCookieData(label) {
  var labelLen = label.length
  var cLen = document.cookie.length
  var i = 0
  var cEnd
  while (i < cLen) {
    var j=i+labelLen;
    if (document.cookie.substring(i,j) == label) {
      cEnd=document.cookie.indexOf(";",j);
      if (cEnd==-1) {
      	cEnd=document.cookie.length;
      }
      j++;
      return unescape(document.cookie.substring(j,cEnd));
    }
    i++;
  }
  return "";
}
function getUserInfo() {
  var USER         = new Object();
  this.value_enc   = getCookieData("ORA_UCM_INFO");
  this.array       = this.value_enc.split("~");
  USER.version      = this.array[0];
  USER.guid         = this.array[1];
  USER.firstname    = this.array[2];
  USER.lastname     = this.array[3];
  USER.username     = this.array[4];
  USER.country      = this.array[5];
  USER.language     = this.array[6];
  USER.interest1    = this.array[7];
  USER.interest2    = this.array[8];
  USER.interest3    = this.array[9];
  USER.interest4    = this.array[10];
  USER.ascii        = this.array[11];	
  USER.email        = this.username;
  USER.companyname  = null;
  USER.title        = null;
  USER.characterset = null;
  USER.interest5    = null;
  return USER;
}

// Start of functions used by new Ocom search
function trim(value)
{
  s = new String(value);
  if (value != null) {
    var beginIndex = -1;
    var endIndex   = s.length;

    for (var i = 0; i < s.length; i++)
    {
      if (s.charAt(i) != " ") {
        beginIndex = i;
        break;
      }
    }
    if (beginIndex == -1) return "";

    for (var j = s.length -1; j > beginIndex; j--) {
      if (s.charAt(j) != " ") {
        endIndex = j;
        break;
      }
    }
    if (endIndex != s.length) return s.substring(beginIndex, endIndex);
    else return s.charAt(beginIndex);
  }
  return value;
}

function isNotNull(value)
{
  if (value == null || trim(value).length == 0)
  {
    alert('Please enter the keyword(s) to search for');
    return false;
  }
  else 
    return true;
}  

function checkSearch( value )
{
  if ( document.searchForm && document.searchForm.datasetId && typeof( langDataSetId ) != 'undefined' && langDataSetId )
  {
    document.searchForm.datasetId.value = langDataSetId;
  }

  if ( value == null || trim(value).length == 0 )
  {
    alert('Please enter the keyword(s) to search for');
    return false;
  }
  else 
  {
    if ( document.searchForm ) document.searchForm.submit();
    return true;
  }
}

function checkGlobalSearch( value )
{
  return checkSearch( value );
}

function sso_sign_out() 
{ 
    rUrl = window.location.href; 
    window.location="http://profile.oracle.com/jsp/reg/signout.jsp?logouturl="+rUrl; //stage only
} 

// Start of Live Edit Code - Dom Lindars, 28-JUL-2004
function GetCookie(sName)
{
  var aCookie = document.cookie.split("; ");
  for (var i=0; i < aCookie.length; i++)
  {
    var aCrumb = aCookie[i].split("=");
    if (sName == aCrumb[0]) return unescape(aCrumb[1]);
  }
  return null;
}

function LiveEditStatus()
{
  var Str = GetCookie( 'WOCPortalLiveEdit' );
  if ( Str == 'Enabled' || Str == 'Disabled' ) return Str;
  else return 'Not installed';
}

var LiveEdit = true;

function DrawLiveEditToolbar()
{
  if ( typeof( USER ) != 'undefined' && USER && USER.guid && USER.username && USER.username.indexOf( '@oracle.com' ) > -1 )
  {
    var Status = LiveEditStatus();

    if ( LiveEdit && Status == 'Enabled' )
    {
      var path = location.pathname
      path = path.substring(1,path.lastIndexOf("/") + 1);
  
      if ( ( location.host == 'www-portal-stage.oracle.com' || location.host == 'www.oracle.com' ) && 
           path.indexOf( 'wocportal' ) == -1 && path.indexOf( 'pls/' ) == -1 )
      {
        document.write( '<script language=Javascript src="/admin/jscripts/live_edit/live_edit.js"><'+'/script>' );
        document.close;
      }
    }
  }
}

DrawLiveEditToolbar();
// End of Live Edit Code 