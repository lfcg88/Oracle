#include <sys/types.h>
#include <unistd.h>
#include <iostream>
#include <iomanip>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <ctime>
#include <sstream>
#include <pthread.h>
#include <fstream>
using namespace std;


bool bContinua;

void * Monitor(void *)
{


     time_t t ;
     struct tm *pt;
     FILE *fp;
     string sLogPath;
     ostringstream osLogPath;
     ofstream of ("CountConfAsap.stats");

     time(&t);

     pt = localtime(&t);

     osLogPath << getenv("LOGDIR");

     osLogPath << "/" << pt->tm_year+1900;

     if ((pt->tm_mon+1) < 10)
        osLogPath << "0";

     osLogPath << pt->tm_mon+1;

     if (pt->tm_mday < 10)
      osLogPath << "0";

     osLogPath << pt->tm_mday << "/";


     while (bContinua)
     {

         time (&t);

         pt = localtime(&t);

     	ostringstream os;

     	os << "FILE*_" ;

        if (pt->tm_hour < 10)
           os << "0";

        os << pt->tm_hour;

        if (pt->tm_min < 10)
            os << "0";

        os << pt->tm_min << "* | wc -l";

     	string s = "ls -1 ";

        s+= osLogPath.str();
     
        s+= os.str();

        cout << "Comando para o pipe: " << s << endl;

     	fp = popen(s.c_str(), "r");

     	if (!fp)
     	{
      		cerr << "Erro ao criar pipe " << s << endl;
      		return NULL;
     	}


     	char buffer[20];

     	if (fgets(buffer, sizeof buffer, fp) == NULL)
     	{
       		cerr << "Erro ao ler o pipe" << endl;
                pclose(fp);
       		return NULL;
     	}

        pclose(fp);


        cout << "Buffer lido do pipe: " << buffer << endl;

     	int nFilesInMinute = atoi(buffer);

        if (nFilesInMinute)
        {
     		float fRate = (float) nFilesInMinute / 60.0f;

     		of << "Hora atual: " << pt->tm_hour << ":" << pt->tm_min <<  ":" << pt->tm_sec;
                of << " Rate is: " << fRate << " processos conf_asap_sgbl por minuto em memoria"; 
                of << endl;
        }

        system("sleep 5");

     }


     return NULL;
}

void * Controle(void *)
{
    do
    {
       system("sleep 2");

       ifstream fin("ConfCount.cfg");

       if (fin.good())
       {
            char buffer[20]; 

            fin.read(buffer, sizeof buffer);

            string s = buffer;
            
            string::size_type pos = s.find("=");

            if (pos != string::npos)
               bContinua = (bool) atoi(s.substr(++pos,1).c_str()); 
        }

      } while (bContinua);

}
int main()
{

///////////////////////////////////////////////////////////
// Este codigo cria duas threads
// uma executa o codigo da funcao Monitor()
// e a outra executa o codigo da funcao Controle()
///////////////////////////////////////////////////////////


     bContinua = 1;

     pthread_t thr_id, thr_id2;

     pthread_create(&thr_id,NULL, Monitor, NULL);

     pthread_create(&thr_id2,NULL, Controle, NULL);


//////////////////////
// voce deve chamar pthread_join() para aguardar o termino de uma thread
// se voce nao fizer isso, a thread principal vai encerrar, mesmo quando
// as threads filhas estiverem executando
// isso vai fazer com que as threads filhas tambem parem de executar
// pthread_join() evita que isso aconteca
/////////////////////////////////////////////////////////////
     pthread_join(thr_id2,  NULL);


}

