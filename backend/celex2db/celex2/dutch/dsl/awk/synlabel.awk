# SYNLABEL.AWK

# DSL

# This script returns the label representations for all syntactic category
# and subcategory codes given in the User Guide, by converting the basic
# numeric codes into their string equivalents. 

BEGIN {
       if (ARGC%2 == 1) {
                printf "Incorrect number of arguments! (%d)\n", ARGC-1
                printf "USAGE !!\n awk -f synlabel.awk file LexField_file1 (CL|GE|DE|PR|AU|SV|SC|AD|CO|SP) [LexField_file1 (CL|GE...)]\n"
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

if (ARGC%2==0 && Colcode[colnr] !~ /^(CL|GE|DE|PR|AU|SV|SC|AD|CO|SP)$/) {
                printf "Incorrect LabelField argument given\n"
                printf "USAGE !!\n awk -f synlabel.awk file LexField_file1 (CL|GE|DE|PR|AU|SV|SC|AD|CO|SP) [LexField_file1 (CL|GE...)]\n"
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

  CLArray[0] = "EXP";
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
  GEArray[1] = "m.";
  GEArray[2] = "v.";
  GEArray[3] = "o.";
  GEArray[4] = "v.(m.)";
  GEArray[5] = "m.-v.";

  DEArray[0] = "?";
  DEArray[1] = "de";
  DEArray[2] = "het";

  PRArray[0] = "?";
  PRArray[1] = "geo.";
  PRArray[2] = "pers.";
  PRArray[3] = "merk.";
  PRArray[4] = "over.";

  AUArray[0] = "?";
  AUArray[1] = "hebben";
  AUArray[2] = "zijn";

  SVArray[0] = "?";
  SVArray[1] = "zelfst.";
  SVArray[2] = "hulp.";
  SVArray[3] = "koppel.";
  SVArray[4] = "onpers.";

  SCArray[0] = "?";
  SCArray[1] = "intrans.";
  SCArray[2] = "trans.";
  SCArray[3] = "wederk.";

  ADArray[0] = "?";
  ADArray[1] = "nonadv";
  ADArray[2] = "adv";

  COArray[0] = "?";
  COArray[1] = "hoofd";
  COArray[2] = "rang";

  SPArray[0] = "?";
  SPArray[1] = "pers.";
  SPArray[2] = "aanw.";
  SPArray[3] = "bez.";
  SPArray[4] = "betr.";
  SPArray[5] = "vraag.";
  SPArray[6] = "wknd.";
  SPArray[7] = "wkg.";
  SPArray[8] = "onbep.";
  SPArray[9] = "uitr.";

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
              TempString = TempString GEArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
       }
    }

  if (Conversion == "DE") {
     if (length(String) == 1) {
         String = DEArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString DEArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
       }
    }
  if (Conversion == "PR") {
     if (length(String) == 1) {
         String = PRArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString PRArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
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
              TempString = TempString SVArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
       }
    }
  if (Conversion == "SC") {
     if (length(String) == 1) {
         String = SCArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString SCArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
       }
    }
  if (Conversion == "AD") {
     if (length(String) == 1) {
         String =ADArray[String];
       }
     else if (length(String) > 1) {
          TempString = "";
          for (j=1; j<=length(String); j++) {
              TempString = TempString ADArray[substr(String,j,1)] "/";
	    }
         String = substr(TempString,1,length(TempString)-1);
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
