#include <windows.h>  
#include <stdio.h>
#include <stdlib.h>
void __declspec(dllexport) sh(char *); 
void sh(char *cmd) 
    {
     system(cmd); 
    }  