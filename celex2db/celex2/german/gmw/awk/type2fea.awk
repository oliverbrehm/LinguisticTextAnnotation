# TYPE2FEA.AWK

# GMW

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
    if (gsub("\/","&",String))               # Sepa
        Features = "Y\\";
    else
        Features = "N\\";

    if (gsub("S","&",String))                # Sing
        Features = Features "Y\\"; 
    else
        Features = Features "N\\";

    if (gsub("P","&",String))                # Plu
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("n","&",String))                # Nom
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("g","&",String))                # Gen
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("d","&",String))                # Dat
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("a","&",String))                # Acc
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("o","&",String))                # Pos
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("c","&",String))                # Comp
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("u","&",String))                # Sup
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("i","&",String))                # Inf
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("z","&",String))                # ZuInf
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("p","&",String))                # Part
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("E","&",String))                # Pres
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("A","&",String))                # Past
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub(/1[^,]*S/,"&",String))          # Sin1
        Features = Features "Y\\"; 
    else
        Features = Features "N\\"; 

    if (gsub(/2[^,]*S/,"&",String))          # Sin2
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub(/3[^,]*S/,"&",String))          # Sin3
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("13P","&",String))              # Plu13
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("2P","&",String))               # Plu2
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("I","&",String))                # Ind
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("K","&",String))                # Sub
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("r","&",String))                # Imp
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("4","&",String))                # Suff_e
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("5","&",String))                # Suff_en
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("6","&",String))                # Suff_er
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("7","&",String))                # Suff_em
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("8","&",String))                # Suff_es
        Features = Features "Y\\";
    else
        Features = Features "N\\";

    if (gsub("9","&",String))                # Suff_s
        Features = Features "Y";
    else
        Features = Features "N";

    return(Features);
}
