#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void printint (FILE *fd, int size, char *outtypename) {
#define CHECK(origtype) \
  if (sizeof(origtype) == size) { \
    fprintf(fd, "typedef " #origtype " %s;\n", outtypename); \
    return; \
  }

  CHECK(signed long long int);
  CHECK(signed long int);
  CHECK(signed int);
  CHECK(signed short int);
  CHECK(signed char);

  fprintf(stderr, "no type for %s with size %d\n", outtypename, size);
  fclose(fd);
  remove("fixedsizetypes.h");
  exit(2);
}

void printuint (FILE *fd, int size, char *outtypename) {
#define CHECK(origtype) \
  if (sizeof(origtype) == size) { \
    fprintf(fd, "typedef " #origtype " %s;\n", outtypename); \
    return; \
  }

  CHECK(unsigned long long int);
  CHECK(unsigned long int);
  CHECK(unsigned int);
  CHECK(unsigned short int);
  CHECK(unsigned char);

  fprintf(stderr, "no type for %s with size %d\n", outtypename, size);
  fclose(fd);
  remove("fixedsizetypes.h");
  exit(2);
}

int main (int argc, char **argv)
{
  FILE *fd;
  int no64 = 0;
  int no32 = 0;

  if (argc > 1) {

    if (strcmp(argv[1],   "no64") == 0) { no64 = 1; }
    if (strcmp(argv[1],  "-no64") == 0) { no64 = 1; }
    if (strcmp(argv[1], "--no64") == 0) { no64 = 1; }
    if (strcmp(argv[1],   "32")   == 0) { no64 = 1; }
    if (strcmp(argv[1],  "-32")   == 0) { no64 = 1; }
    if (strcmp(argv[1], "--32")   == 0) { no64 = 1; }

    if (strcmp(argv[1],   "no32") == 0) { no64 = 1; no32 = 1; }
    if (strcmp(argv[1],  "-no32") == 0) { no64 = 1; no32 = 1; }
    if (strcmp(argv[1], "--no32") == 0) { no64 = 1; no32 = 1; }
    if (strcmp(argv[1],   "16")   == 0) { no64 = 1; no32 = 1; }
    if (strcmp(argv[1],  "-16")   == 0) { no64 = 1; no32 = 1; }
    if (strcmp(argv[1], "--16")   == 0) { no64 = 1; no32 = 1; }

  }

  fd = fopen("fixedsizetypes.h", "wb");
  if (fd == NULL) {
    fprintf(stderr, "cannot open fixedsizetypes.h for writing\n");
    exit(2);
  }

  fprintf(fd, "#ifndef FIXEDSIZETYPES_H\n");
  fprintf(fd, "#define FIXEDSIZETYPES_H\n");
  fprintf(fd, "\n");

  printint(fd, 1, "int8");
  printint(fd, 2, "int16");
  if (!no32) {
    printint(fd, 4, "int32");
  }
  if (!no64) {
    printint(fd, 8, "int64");
  }

  printuint(fd, 1, "uint8");
  printuint(fd, 2, "uint16");
  if (!no32) {
    printuint(fd, 4, "uint32");
  }
  if (!no64) {
    printuint(fd, 8, "uint64");
  }

  fprintf(fd, "\n");

  fprintf(fd, "#endif /* FIXEDSIZETYPES_H */\n");
  fprintf(fd, "\n");
  fclose(fd);

	return 0;
}

