# SYNLABEL.AWK

# GSL

# This script returns the label representations for all syntactic category
# and subcategory codes given in the User Guide, by converting the basic
# numeric codes into their string equivalents. 

BEGIN {
       if (ARGC%2 == 1) {
                printf "Incorrect number of arguments! (%d)\n", ARGC-1
                printf "USAGE !!\n awk -f synlabel.awk file LexField_file1 (CL|GE|PR|AU|SV|CO|SP) [LexField_file1 (CL|GE...)]\n"
                exit(-1)
	      }

        FS="\\";
        OFS="\\";
        Maxcolnrs = 2;

        for (i=4; i <= ARGC; i+=2) {
             colnr = i/2+1;
             Colno[colnr] = ARGV[i-2];
             Colcode[colnr] = ARGV[i-1];
             Maxcolnrs++;

if (ARGC%2==0 && Colcode[colnr] !~ /^(CL|GE|PR|AU|SV|CO|SP)$/) {
                printf "Incorrect LabelField argument given\n"
                printf "USAGE !!\n awk -f synlabel.awk file LexField_file1 (CL|GE|PR|AU|SV|CO|SP) [LexField_file1 (CL|GE...)]\n"
                exit(-1)
	      }
	   }
     }

{
  while (getline < ARGV[1]) {
  Resultline = $1 OFS $2;
  for (i = 3; i <= Maxcolnrs; i++) {
       Incolno = Colno[i];
       Translate = Colcode[i];
       Resultline = Resultline OFS CatNumbersToCatLabels($Incolno,Translate);
      }
  print Resultline;
  }
exit;
}

function CatNumbersToCatLabels(String,Conversion) {

  CLArray[1] = "N";
  CLArray[2] = "A";   
  CLArray[3] = "NUM";   
  CLArray[4] = "V";   
  CLArray[5] = "ART";   
  CLArray[6] = "PRON";   
  CLArray[7] = "ADV";   
  CLArray[8] = "PREP";   
  CLArray[9] = "C";   
  CLArray[10] = "I";   

  GEArray[0] = "?";
  GEArray[1] = "M";
  GEArray[2] = "F";
  GEArray[3] = "N";

  PRArray[0] = "?";
  PRArray[1] = "G";
  PRArray[2] = "P";
  PRArray[3] = "B";

  AUArray[0] = "?";
  AUArray[1] = "haben";
  AUArray[2] = "sein";

  SVArray[0] = "?";
  SVArray[1] = "a";
  SVArray[2] = "c";
  SVArray[3] = "i";
  SVArray[4] = "m";
  SVArray[5] = "l";
  SVArray[6] = "r";

  COArray[0] = "?";
  COArray[1] = "cardinal";
  COArray[2] = "ordinal";
  COArray[3] = "fraction";
  COArray[4] = "classificatory";
  COArray[5] = "multiplicative";

  SPArray[0] = "?";
  SPArray[1] = "personal";
  SPArray[2] = "demonstrative";
  SPArray[3] = "possessive";
  SPArray[4] = "relative";
  SPArray[5] = "interrogative";
  SPArray[6] = "reflexive";
  SPArray[7] = "reciprocal";
  SPArray[8] = "indefinite";

  if (Conversion == "CL") {
      String = CLArray[String];
     }

  if (Conversion == "GE") {
     if (length(String) == 1) {
         String = GEArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString GEArray[substr(String,j,1)];
	    }
         String = TempString;
       }
    }

  if (Conversion == "PR") {
     if (length(String) == 1) {
         String = PRArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString PRArray[substr(String,j,1)];
	    }
         String = TempString;
       }
    }

  if (Conversion == "AU") {
     if (length(String) == 1) {
         String = AUArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString AUArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
       }
    }

  if (Conversion == "SV") {
     if (length(String) == 1) {
         String = SVArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString SVArray[substr(String,j,1)];
	    }
         String = TempString;
       }
    }

  if (Conversion == "CO") {
     if (length(String) == 1) {
         String = COArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString COArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
       }
    }

  if (Conversion == "SP") {
     if (length(String) == 1) {
         String = SPArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString SPArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
       }
    }

   return (String);
}
