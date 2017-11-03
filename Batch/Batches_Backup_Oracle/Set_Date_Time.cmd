set dt=%date:~4,10%
set aaaammdd=%dt:~6,4%%dt:~3,2%%dt:~0,2%
set hhmmss=%time:~0,8%
set hhmmss=%hhmmss:~0,2%%hhmmss:~3,2%%hhmmss:~6,2%
set hhmmss=%hhmmss: =0%
set hhmm=%hhmmss:~0,4%
set DTH=%aaaammdd%_%hhmmss%