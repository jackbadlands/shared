/*
 * bit order - big endian
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OUT /* mark for argument OUT (for programmer) */
#define IN /* mark for argument IN */

typedef unsigned char uchar;

void bitofst2args (int bitno, OUT int *charno, OUT uchar *mask) {
  int bit8;
  *charno = bitno / 8;
  bit8 = bitno % 8;
  *mask = 1 << (7 - bit8);
}

void longand2 (uchar *dest, uchar *arg2, int len) {
  int i;
  for (i = 0; i < len; i++) {
    dest[i] &= arg2[i];
  }
}

int getbit (uchar *bits, int flagno) {

#define BITS2EXPAND \
  int charno; \
  uchar mask; \
  bitofst2args(flagno, &charno, &mask);

  BITS2EXPAND;
  return (bits[charno] & mask) ? 1 : 0;
}

void setbit (uchar *bits, int flagno, int val) {
  BITS2EXPAND;
  if (val) {
    bits[charno] |= mask;
  } else {
    bits[charno] &= ~mask;
  }
}
#undef BITS2EXPAND

int printbits (uchar *bits, int len) {
  int i, j;
  for (i = 0; i < len; i++) {
    for (j = 7; j >= 0; j--) {
      if (bits[i] & (1 << j)) {
        printf("1");
      } else {
        printf("0");
      }
    }
    printf(" ");
  }
}

int main (int argc, char **argv)
{
#define REGLEN 6
 
  uchar a[REGLEN];
  uchar b[REGLEN];

  memset(a, 0, REGLEN);

  // set a, check
  setbit(a, 0,  1);
  setbit(a, 1,  1);
  setbit(a, 4,  1);
  setbit(a, 10, 1);
  printbits(a, REGLEN);
	printf("\n");

  // unset a, check
  setbit(a, 0,  0);
  setbit(a, 10, 0);
  setbit(a, 12, 1);
  printbits(a, REGLEN);
	printf("\n");

  // use longand2(), check
  memset(a, 0, REGLEN);
  memset(b, 0, REGLEN);
  //
  setbit(a, 0,  1);
  setbit(a, 1,  1);
  setbit(a, 4,  1);
  setbit(a, 10, 1);
  //
  setbit(b, 0,  0);
  setbit(b, 10, 1);
  setbit(b, 12, 0);
  printf("#\n");
  printbits(a, REGLEN); printf("\n");
  printbits(b, REGLEN); printf("\n");
  longand2(a, b, REGLEN);
  printbits(a, REGLEN); printf("\n");

#undef REGLEN

	return 0;
}

