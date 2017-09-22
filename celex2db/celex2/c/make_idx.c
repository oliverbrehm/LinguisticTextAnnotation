#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ON 1
#define OFF 0

void Count_Index_Size(char *inputfile);
void Initialize_File(char *inputfile);
void Build_Index_File(char *inputfile,int column);
void Find_Column(char *string,int columnnumber, char *stringout);

long indexsize;

int main(int argc, char *argv[]){
  int column;

  if(argc != 3)
  {
     printf("USAGE !!!\n");
     printf("make_idx <lexicon> <columnnumber>\n");
     exit(1);
  }
  Count_Index_Size(argv[1]);
  Initialize_File(argv[1]);
  column = atoi(argv[2]);
  Build_Index_File(argv[1],column);
  return(1);
}

void Count_Index_Size(char *inputfile){
  FILE *fpin;
  char tmp[4000];

  indexsize = 0;
  fpin = fopen(inputfile,"r");
  if(fpin == NULL){
     printf("%s niet open\n",inputfile);
     exit(1);
  }
  else
    printf("%s opened for counting number of lines\n",inputfile);
  while(fgets(tmp,3999,fpin) != NULL){
    indexsize++;
  }
  printf("%ld lines scanned in %s\n",indexsize,inputfile);
  fclose(fpin);
}

void Initialize_File(char *inputfile){
FILE *fpout;
long i,c;
char filename[50];

   strcpy(filename,inputfile);
   *strchr(filename,'.') = '\0';
   strcat(filename,".idx");
   fpout = fopen(filename,"w+b");
   if(fpout == NULL){
      printf("%s niet open\n",filename);
      exit(1);
   }
   else
     printf("%s opened for initialisation\n",filename);

   c = '\0';
   for(i = 0; i <= indexsize; i++) 
   {
       fwrite(&c,sizeof(long),1,fpout);
   }
   fclose(fpout);
   printf("%s closed\n",filename);
}

void Build_Index_File(char *inputfile,int column){
  FILE *fpin,*fpout;
  char tmp[110],line[4000],filename[50];
  long x,i,j;

  fpin = fopen(inputfile,"r");
  if(fpin == NULL)
  {
     printf("UNABLE TO OPEN LEXICON: %s\n",inputfile);
     exit(1);
  }
  else
    printf("%s opened for reading\n",inputfile);

  strcpy(filename, inputfile);
  *strchr(filename,'.') = '\0';
  strcat(filename,".idx");
  fpout = fopen(filename,"r+b");
  if(fpin == NULL)
  {
     printf("UNABLE TO OPEN LEXICON: %s\n",filename);
     exit(1);
  }
  else
    printf("%s opened for writing\n",filename);
  j = 0;
  x = (long)ftell(fpin);
  while(fgets(line,3000,fpin) != NULL){
    j++;
    Find_Column(line,column,tmp);
    i = (long)atol(tmp);
    fseek(fpout,(i*4),SEEK_SET);
    fwrite(&x,sizeof(long),1,fpout);
/*	 printf("position %ld stored at %ld\n",x,i);*/
	 x = (long)ftell(fpin);
  }
  fclose(fpin);
  printf("\n%s closed\n",inputfile);
  fclose(fpout);
  printf("%s closed\n",filename);
}

void Find_Column(char *string,int columnnumber, char *stringout){
  int j;
  char element[8192];

  strcpy(element,string);
  for(j = 1; j < columnnumber; j++){
    strcpy(element,(strchr(element,'\\')+1));
  }
  if(strchr(element,'\\') != NULL)
    *strchr(element,'\\') = '\0';
  strcpy(stringout,element);
}


