 path=%path%;c:\borland\bcc55\bin
 bcc32 -WD shell.c  
 implib shell.lib shell.dll 
 bcc32 shell_run.c shell.lib  