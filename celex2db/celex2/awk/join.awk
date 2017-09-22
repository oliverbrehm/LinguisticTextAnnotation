# This script can be used to retrieve fields from two similarly ordered
# files of the same lexical status, i.e. either two lemma files or two 
# wordform files. IT CANNOT BE USED TO JOIN A WORDFORM AND A LEMMA FILE!
#
# usage: awk -f join.awk file1 file2 LexField_file1 LexField_file2

BEGIN {
    if (ARGC != 5) {
        printf "insufficient number of arguments! (%d)\n", ARGC-1
        printf "USAGE !!\n awk -f join.awk file1 file2 LexField_file1 LexField_file2\n"    
        exit(-1)
    }

    FS="\\";

    getline < ARGV[1];                  # Read first line of first file
    IdNum_key1 = $1                     # IdNum field number is assumed to be 1 
    LexInfo_1 = $ARGV[3];               # the field number of the lexical
                                        #  information in the first file
                                    
                                        # NOTE: if required, additional fields 
                                        # can be selected and stored in
                                        # in additional variables, e.g., 
                                        # LexInfo_1a, etc.

    while (getline < ARGV[2]) {         # Process new line from the second file.
        IdNum_key2 = $1;                # IdNum field number is assumed to be 1
        LexInfo_2 = $ARGV[4];           # the field number of the lexical
                                        #  information in the second file
                                    
                                        # NOTE: if required, additional fields 
                                        # can be selected and stored in
                                        # in additional variables, e.g., 
                                        # LexInfo_2a, etc.


                                        # Find first line in file1 which has
                                        # the same, or a higher, IdNum than
                                        # the line read from file2.
        while (IdNum_key2 > IdNum_key1) { 
            if (getline < ARGV[1] > 0) {
                IdNum_key1 = $1
                LexInfo_1 = $ARGV[3];
		                        # If additional fields from file1
                                        # are selected, these fields
                                        # should be assigned here

            } else {
                printf("Error: Unexpected EOF while searching IdNum #%d in %s!\n",
                        IdNum_key2, ARGV[1]);
                exit(-1);
            }
        }

        if (IdNum_key2 != IdNum_key1) {
            printf("Error: IdNum #%d is missing in %s!\n", IdNum_key2, ARGV[1]);
            exit(-1);
        } else
            printf("%d\\%s\t%s\n", IdNum_key1, LexInfo_1, LexInfo_2);
		                        # If additional fields from file1
                                        # and file2 have been selected
			                # they should also be printed

                                        # NOTE THAT THE MAIN FIELD SEPARATOR
                                        # IS THE BACKSLASH, AND THAT THE
                                        # TAB IS USED AS MINOR FIELD SEPARATOR
    }
}


