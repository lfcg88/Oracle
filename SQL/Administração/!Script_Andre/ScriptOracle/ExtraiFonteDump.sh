#exp userid=$1/$2 file=/tmp/struct compress=no full=y rows=n 
#imp userid=$1/$2 file=/tmp/struct full=y show=y 2> /tmp/contents.lst 
#
# The script takes 3 arguments username, password and SID.  
# The script SID.sql   Is generated. 
# If only grants are needed, change the line:
# ' fold -s -w75 /tmp/struct2 > $3.sql '       
# by        
# ' grep ^GRANT /tmp/struct2 | fold -s -w75 > $3.sql '        
# rm /tmp/struct.dmp        
#
awk '  BEGIN    { prev=";" }
       / \"CREATE /    { N=1; }               
       / \"ALTER /     { N=1; }   
       / \"ANALYZE /   { N=1; }               
       / \"GRANT /     { N=1; }   
       / \"REVOKE /    { N=1; }               
       / \"COMMENT /   { N=1; }   
       / \"AUDIT /     { N=1; }               
       N==1 { printf "\n/\n\n"; N++ } 
       /\"$/ { prev=""                       
               if (N==0) next;        
               s=index( $0, "\"" );                       
               if ( s!=0 ) {  
                  printf "%s",substr( $0,s+1,length( substr($0,s+1))-1 )	
                  prev=substr($0,length($0)-1,1 );                  
               }                
               if (length($0)<78) printf( "\n" );                    
         }' < /tmp/contents.lst > /tmp/struct1       
# rm /tmp/contents.lst        
sed /^$/d < /tmp/struct1 > /tmp/struct2        
rm /tmp/struct1 
fold -s -w75 /tmp/struct2 > $3.sql      
rm /tmp/struct2        