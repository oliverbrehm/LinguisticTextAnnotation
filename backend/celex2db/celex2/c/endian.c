/****************************************************************************
 * Program written to test the way multi-byte data types are interpreted
 * on various machines. If your system is Little Endian, use joinwlle.c or
 * the DOS joinwlle.exe executable. If your system is Big Endian, use
 * joinwlbe.c or (for HP-UX only!) the joinwlbe binary. If neither, the join
 * programs cannot be used. Nor can the programs be used on machines with
 * 64-bit addresses.
 ***************************************************************************/

#include <stdio.h>

#define LITTLE_ENDIAN 1
#define BIG_ENDIAN 2
#define PDP_ENDIAN 3
#define STRANGE_ENDIAN 100

int endian(void);

main() {

    if (sizeof(long) != 4) {
        printf("Your system has set the size of long integers to %d bytes instead of the 4 bytes\nneeded to make the join program work! Sorry, but we cannot fix everything!!!\n",sizeof(long));
       exit(1);
      }

   switch(endian())
      {
         case LITTLE_ENDIAN:
            printf("Your machine seems to be Little Endian.\nUse the joinwlle.c program.\n");
            break;
         case BIG_ENDIAN:
            printf("Your machine seems to be Big Endian.\nUse the joinwlbe.c program.\n");
            break;
         default:
            printf("Your machine's Endian status could not be determined.\nSorry, but you cannot use a join program.\n");
      }
}

int endian(void)
{
  static unsigned char four[4] = {0x11,0x22,0x33,0x44};
  unsigned long temp;

  temp = *(unsigned long*) &four;

  if (temp == 0x44332211) return LITTLE_ENDIAN;
  if (temp == 0x11223344) return BIG_ENDIAN;

  return STRANGE_ENDIAN;
}

