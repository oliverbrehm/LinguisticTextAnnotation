/* ----------------------------------------------------------------------- *
 *                                                                         *
 *      SYNLABEL.C                                                         *
 *                                                                         *
 * SYNLABEL can be used to convert a field with syntactic information      *
 * in a number-representation to a field with syntactic information        *
 * in a 'shortened label' form.                                            *
 *                                                                         *
 * What happens when a line in the inputfile is longer than MAXLINE (2048) *
 * is undefined! :-)                                                       *
 *                                                                         *
 * Hedderik van Rijn, 930702, Original Version.                            *
 *                    930816, Modified to support the german labels.       *
 *                                                                         *
 * ----------------------------------------------------------------------- */

#include "stdio.h"
#include "stdlib.h"
#include "string.h"

/* -[ General Defines ]--------------------------------------------------- */

typedef unsigned int UINT;

#define FALSE       0
#define TRUE        (!FALSE)

/* -[SYNLABEL-specific Defines ]------------------------------------------ */

#define MAXLINE     	2048

#define NOERROR     	0
#define ARGSERROR   	1
#define MEMERROR    	2

#define MAXCONV			10

#define NOCONVERTION	0
#define CLASS			1
#define GEND			2
#define PROP			3
#define AUX				4
#define SUBCLASSV		5
#define CARDORD			6
#define SUBCLASSP		7

/* -[ Global Vars ]------------------------------------------------------- */

char    Mapped[20];      /* Contains last mapping done. */

char   *Mapping[8][11] =
		{
				{ "",   "",    "",    "",   "",   "",   "",   "",
				  "",   "",    ""},
		/* CLASS */
				{ "#", "N", "A", "NUM", "V", "ART", "PRON", "ADV", "PREP",
				  "C", "I" },
		/* GEND */
				{ "#", "M",  "F", "N", "#", "#", "#", "#", "#", "#", "#" },
		/* PROP */
				{ "#", "G", "P", "B", "#", "#", "#", "#", "#", "#", "#" },
		/* AUX */
				{ "#", "haben", "sein", "#", "#", "#", "#", "#", "#", "#", "#" },
		/* SUBCLASSV */
				{ "#", "a", "c", "i", "m", "l", "r", "#", "#", "#", "#"},
		/* CARDORD */
				{ "#", "cardinal", "ordinal", "fraction", "classificatory", 
				  "multiplicative", "#", "#", "#", "#", "#"},
		/* SUBCLASSP */
				{ "#", "personal", "demonstrative", "possessive", "relative", 
				  "interrogative", "reflexive", "reciprocal", "indefinite", 
                  "#"}
		};

struct MapStruct_t {
	int 	FieldNo;
	int 	ConvertTo;
};

typedef struct MapStruct_t MapStruct;

MapStruct 	ToBeMapped[MAXCONV];
int 		NumOfFieldsToMap;

/* -[ Functions ]--------------------------------------------[ ReadLine ]- */

char *ReadLine(FILE *inFile, char *retStr)
{
    char *ptr;

    char endOfLine = FALSE;
    char endOfFile = FALSE;

    if (!retStr)                /* Maybe we have to allocate mem for storage. */
        retStr = (char *)calloc(1,MAXLINE);

    memset(retStr,0,MAXLINE);   /* Erase all previous contents of retStr. */

    if (retStr) {
        ptr = retStr;
        while (!endOfLine && !endOfFile) {
            if ((endOfFile = ( (fread(ptr,1,1,inFile)) ? FALSE : TRUE) ) == FALSE)
                endOfLine = (*ptr++ == '\n');
        }
    } else {
        printf("Error: Not enough memory!\n");
        exit(MEMERROR);
    }

        /* If nothing is read in, and we're at the end of the file,
           return NULL.                                             */

    if (endOfFile && (retStr[0] == '\0')) {
        free(retStr);
        retStr = NULL;
    } else
        if (endOfFile)          /* Something is read in, but no EOL */
            *(ptr++) = '\n';    /* mark... Add it ourselves.        */

    return(retStr);
}

/* -------------------------------------------------------------[ MapTo ]- */

char *MapTo(char **ch, UINT repr)
{
	if ((repr == CLASS) && (**ch == '1') && (*(*ch+1) == '0')) {
		strcpy(Mapped,Mapping[CLASS][10]);
		(*ch)++;
	} else {
		strcpy(Mapped,Mapping[repr][(**ch)-48]);
		if (repr == AUX) {
			if (*(*ch+1) != '\\') {
				strcat(Mapped,"/");
				(*ch)++;
				strcat(Mapped,Mapping[AUX][(**ch)-48]);
			}
		}
	}
	return(Mapped);
}

/* --------------------------------------------------------[ HelpScreen ]- */

void HelpScreen(int errNum)
{
	puts("Usage:  <File> <LabelField> <Column> [<LabelField> <Column>...]");
	puts("");
	puts("SYNLABEL can be used to convert fields with syntactic information in a number-");
	puts("representation to a field with syntactic information in a 'shortened label'");
	puts("format.");
	puts("");
	puts(" Arguments:");
	puts("");
	puts(" <File>            : CD-Celex file.");
	puts(" <LabelField>      : Name of label-field to convert to.");
	puts("                     One of:");
	puts("                       CL : Class             GE : Gend");
	puts("                       PR : Prop              AU : Aux"); 
	puts("                       SV : SubClassV         CO : CardOrd");
	puts("                       SP : SubClassP");
	puts(" <Column>          : Number of column in <File> which contains");
	puts("                     'the information in numbers'. First column is 1.");
	puts("                     (Fields must be seperated by a '\\'.)");
	puts("");
	puts(" (A maximum of 10 fields can be converted in one call to SYNLABEL.)");
	exit(errNum);
}

/* ---------------------------------------------------[ NeedsToBeMapped ]- */

int NeedsToBeMapped(int fieldNo)
{
	int i;

	for (i=0;i<NumOfFieldsToMap;i++) {
		if (ToBeMapped[i].FieldNo == fieldNo)
			return(ToBeMapped[i].ConvertTo);
	}
	return(FALSE);
}

/* --------------------------------------------------[ ProcessArguments ]- */

void ProcessArguments(int argc, char *argv[])
{
	int 	i;
	char 	convertTo;
	int 	wantedField;

	NumOfFieldsToMap = 0;


	if (argc < 4)
		HelpScreen(ARGSERROR);      /* Display help, exit with errorcode */

	for (i=0;(i<(argc-2)) && (i<20);i+=2) {
		if (strcmp(argv[2+i],"CL"))       /* Representation to convert to... */
		if (strcmp(argv[2+i],"GE"))
		if (strcmp(argv[2+i],"PR"))
		if (strcmp(argv[2+i],"AU"))
		if (strcmp(argv[2+i],"SV"))
		if (strcmp(argv[2+i],"CO"))
		if (strcmp(argv[2+i],"SP"))   {
			printf("Error: FieldName '%s' unkown.\n\n",argv[2+i]);
			HelpScreen(ARGSERROR);
		}
		else convertTo = SUBCLASSP;
		else convertTo = CARDORD;
		else convertTo = SUBCLASSV;
		else convertTo = AUX;
		else convertTo = PROP;
		else convertTo = GEND;
		else convertTo = CLASS;
										/* Field to convert... */
		if ((wantedField = atoi(argv[3+i])) == 0) {
			printf("Error: <Field> can't be: %s.\n",argv[3+i]);
			HelpScreen(ARGSERROR);
		}
		ToBeMapped[NumOfFieldsToMap].FieldNo = wantedField-1;
		ToBeMapped[NumOfFieldsToMap++].ConvertTo = convertTo;
	}
}


/* -[ Body ]-----------------------------------------------------[ main ]- */

int main(int argc, char *argv[])
{
	FILE *inFile;                   /* Inputfile Handle. */
	char *actLine = NULL;           /* Last line read. */
	char *ptr;                      /* Used when processing read line. */
	UINT  fieldNo;                  /* Current field. */
	UINT  convertTo;                /* Representation to convert to. */

	ProcessArguments(argc,argv);

				/* Open input file. -------------------------------------- */

	if ((inFile = fopen(argv[1],"rb")) == NULL) {
		printf("Error: Couldn't open input-file: %s \n",argv[1]);
		exit(ARGSERROR);
	}

                /* Read & process all lines in file. --------------------- */

	while ((actLine = (char *)ReadLine(inFile,actLine)) != NULL) {
		ptr = actLine;
		fieldNo = 0;
		do  {
			if (*ptr == '\\') {     /* Next field found! */
				fieldNo++;
				printf("%c",*ptr++);
			} else {                /* Necessary to map? */
				if (convertTo = NeedsToBeMapped(fieldNo)) {
					printf("%s",MapTo(&ptr,convertTo));
					ptr++;
				} else
					printf("%c",*ptr++);
			}
		} while (*ptr != '\n');
		printf("\n");
	}

	return(NOERROR);                /* Exit with 'errorcode' 0... */
}

/* ----------------------------------------------------------------------- */
