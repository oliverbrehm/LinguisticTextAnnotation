#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void Join(char *wordlex,char *lemmalex);
void Search(FILE *index,FILE *lemma,char *result, long lemmaid);
void Find_Column(char *string,int columnnumber, char *stringout);
void Parse_Fields(char * FieldsArrayWord, char *FieldsArrayLemma);
void Check_Input(char *wordlex, char *lemmalex);

int wordfields[100], lemmafields[100], wordcolumns,lemmacolumns;

int main(int argc, char *argv[])
{
	if(argc != 5)
	{
		printf("USAGE !!!\n");
		printf("joinwlle wordformlex lemmalex \"wordformcolumns\"\
 \"lemmacolumns\"\n");
		printf("Example\n\tjoinwlle dow.cd dol.cd \"1|2|8\" \"2|8\"\n");
		exit(1);
	}
	Check_Input(argv[1],argv[2]);
	Parse_Fields(argv[3],argv[4]);
	Join(argv[1],argv[2]);
	return(0);
}

void Check_Input(char *wordlex, char *lemmalex){
  int incorrect;
  char *cptr;

  incorrect = 0;
  cptr = strrchr(wordlex,'.');
  if(cptr != NULL){
     cptr--;
  if((*cptr != 'w') && (*cptr != 'W')){
	 printf("%s is not a wordform file!!\n",wordlex);
	 incorrect = 1;
       }
   }
  cptr = strrchr(lemmalex,'.');
  if(cptr != NULL){
     cptr--;
  if((*cptr != 'l') && (*cptr != 'L')){
	 printf("%s is not a lemma file!!\n",lemmalex);
	 incorrect = 1;
       }
  }
  if(incorrect){
	 printf("USAGE !!!\n");
		printf("joinwlle wordformlex lemmalex \"wordformcolumns\"\
 \"lemmacolumns\"\n");
		printf("Example\n\tjoinwlle dow.cd dol.cd \"1|2|8\" \"2|8\"\n");
		exit(1);
	}
}

void Join(char *wordlex,char *lemmalex){
FILE *fpin1,*fpin2,*fpin3,*fpout;
char tmp[110],tmp2[110],filename[100],line[4000],line2[4000],
	  lemmaline[1000],wordline[1000],*cptr,*initpos,cropname[100];
int x,i;
long wordid, lemmaid, oldlemmaid;

	fpin1 = fopen(wordlex,"r");
	if(fpin1 == NULL)
	{
		printf("UNABLE TO OPEN LEXICON: %s\n",wordlex);
		exit(1);
	}
	else
	  printf("%s opened\n",wordlex);

	fpin2 = fopen(lemmalex,"r");
	if(fpin2 == NULL)
	{
		printf("UNABLE TO OPEN LEXICON: %s\n",lemmalex);
		exit(1);
	}
	else
	  printf("%s opened\n",lemmalex);

	strcpy(filename,lemmalex);
	*strrchr(filename,'.') = '\0';
	strcat(filename,".idx");
	fpin3 = fopen(filename,"r+b");
	if(fpin3 == NULL){
		printf("UNABLE TO OPEN INDEX FILE: %s\n",filename);
		printf("If it does not exist, create an index file with \"make_idx\"\n");
		exit(1);
	}
	else
	  printf("%s opened\n",filename);

	strcpy(cropname,wordlex);
        cptr = strrchr(cropname,'.');
        initpos = cptr-3;
	*strrchr(cropname,'.') = '\0';
        strcpy(cropname,initpos);
	strcat(cropname,".out");
	fpout = fopen(cropname,"w");
	if(fpout == NULL)
	{
		printf("UNABLE TO OPEN LEXICON: %s\n",cropname);
		exit(1);
	}
	else
	  printf("%s opened\n",cropname);
  x = 0;

  if((*(cptr-2) == 'f') || (*(cptr-2) == 'F')){
   while(fgets(line,4000,fpin1) != NULL)
   {
 	 x++;
 	 Find_Column(line,3,tmp);
 	 lemmaid = atol(tmp);
 	 strcpy(wordline,"");
	 for(i = 0; i <= wordcolumns; i++){
		Find_Column(line,wordfields[i],tmp);
		strcat(wordline,tmp);
		strcat(wordline,"\\");
	 }
	 i = 0;
	 fprintf(fpout,"%s",wordline);
	 if(lemmaid != oldlemmaid){
		Search(fpin3,fpin2,line2,lemmaid);
		strcpy(lemmaline,"");
		for(i = 0; i <= lemmacolumns; i++){
			Find_Column(line2,lemmafields[i],tmp);
			strcat(lemmaline,tmp);
			strcat(lemmaline,"\\");
		}
		i = 0;
		lemmaline[strlen(lemmaline)-1] = '\0';
	 }
	 fprintf(fpout,"%s\n",lemmaline);
	 oldlemmaid = lemmaid;
  }
       }  
  else {  
   while(fgets(line,4000,fpin1) != NULL)
   {
 	 x++;
 	 Find_Column(line,4,tmp);
 	 lemmaid = atol(tmp);
 	 strcpy(wordline,"");
	 for(i = 0; i <= wordcolumns; i++){
		Find_Column(line,wordfields[i],tmp);
		strcat(wordline,tmp);
		strcat(wordline,"\\");
	 }
	 i = 0;
	 fprintf(fpout,"%s",wordline);
	 if(lemmaid != oldlemmaid){
		Search(fpin3,fpin2,line2,lemmaid);
		strcpy(lemmaline,"");
		for(i = 0; i <= lemmacolumns; i++){
			Find_Column(line2,lemmafields[i],tmp);
			strcat(lemmaline,tmp);
			strcat(lemmaline,"\\");
		}
		i = 0;
		lemmaline[strlen(lemmaline)-1] = '\0';
	 }
	 fprintf(fpout,"%s\n",lemmaline);
	 oldlemmaid = lemmaid;
       }
  }  
  fclose(fpin1);
  fclose(fpout);
}


void Search(FILE *index,FILE *lemma,char *result, long lemmaid)
{
unsigned char b1,b2,b3,b4;
unsigned long c;
	fseek(index,(lemmaid*4),SEEK_SET);  
	fread(&b4,sizeof(unsigned char),1,index);
	fread(&b3,sizeof(unsigned char),1,index);
	fread(&b2,sizeof(unsigned char),1,index);
	fread(&b1,sizeof(unsigned char),1,index);
        c=b4;
        c<<=8;
        c+=b3;
        c<<=8;
        c+=b2;
        c<<=8;
        c+=b1;
	fseek(lemma,c,SEEK_SET);
        fgets(result,1000,lemma);
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
  else
	 *strchr(element,'\n') = '\0';
  strcpy(stringout,element);
}

void Parse_Fields(char * FieldsArrayWord, char *FieldsArrayLemma){
  int i;

  i = 0;
  while(strchr(FieldsArrayWord,'|') != NULL){
	 *strchr(FieldsArrayWord,'|') = '\0';
	 wordfields[i] = atoi(FieldsArrayWord);
	 strcpy(FieldsArrayWord,strchr(FieldsArrayWord,'\0')+1);
	 i++;
  }
  wordfields[i] = atoi(FieldsArrayWord);
  wordcolumns = i;

  i = 0;
  while(strchr(FieldsArrayLemma,'|') != NULL){
	 *strchr(FieldsArrayLemma,'|') = '\0';
	 lemmafields[i] = atoi(FieldsArrayLemma);
	 strcpy(FieldsArrayLemma,strchr(FieldsArrayLemma,'\0')+1);
	 i++;
  }
  lemmafields[i] = atoi(FieldsArrayLemma);
  lemmacolumns = i;
  printf("%d wordcolumns, %d lemmacolumns\n",wordcolumns +1,lemmacolumns+1);
}
