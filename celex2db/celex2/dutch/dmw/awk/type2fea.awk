# TYPE2FEA.AWK

# DMW

# This script converts a field containing the 'type of flection' information
# into a string containing twenty fields with inflectional features
# information. The order of these twenty fields is the same as they appear
# in the CELEX-guide.

BEGIN {

	if (ARGC != 3) {
		printf "insufficient number of arguments! (%d)\n", ARGC-1
		printf "USAGE !!\n awk -f type2fea.awk file LexField\n"
		exit(-1)
	      }

	FS="\\";
	while(getline < ARGV[1]){
	  LexInfo_1 = $ARGV[2];
	  LexInfo_1 = TypeToInflectionalFeatures(LexInfo_1);
	  printf("%d\\%s\\%s\n",$1,$2,LexInfo_1);
	}
}

function TypeToInflectionalFeatures(String)
{
    if (gsub("s","",String))                # Sepa
        Features = "Y\\";
    else
        Features = "N\\";

    if (gsub("e","",String))                # Sing
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("m","",String))                # Plu
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("d","",String))                # Dim
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("G","",String))                # Gen
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("D","",String))                # Dat
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("P","",String))                # Pos
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("C","",String))                # Comp
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("S","",String))                # Sup
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("E","",String))                # Suff_e
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("i","",String))                # Inf
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("p","",String))                # Part
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("t","",String))                # Pres
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("v","",String))                # Past
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("1","",String))                # Sin1
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("2","",String))                # Sin2
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("I","",String))                # Inv
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("3","",String))                # Sin3
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("g","",String))                # Imp
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("a","",String))                # Sub
        Features = Features "Y";
    else
        Features = Features "N";

    return(Features);
}
