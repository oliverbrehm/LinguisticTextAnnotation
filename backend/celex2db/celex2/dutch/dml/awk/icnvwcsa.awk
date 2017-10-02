# ICNVWCSA.AWK

# DML

# This script converts Immediate Class word class and affix labels into
# simple Stem and Affix labels.

BEGIN {

	if (ARGC != 3) {
		printf "insufficient number of arguments! (%d)\n", ARGC-1
		printf "USAGE !!\n awk -f icnvwcsa.awk file LexField\n"
		exit(-1)
	      }

	FS="\\";
	while(getline < ARGV[1]){
	  LexInfo_1 = $ARGV[2];
	  LexInfo_1 = ConvertWordClassToSAPattern(LexInfo_1);
	  printf("%s\n",LexInfo_1);
	}
}

function ConvertWordClassToSAPattern(String)
{
    gsub(/[^x]/,"S",String);
    gsub("x","A",String);
    return(String);
}
