#include <stdio.h>
#include <string.h>
#include "visproc.h"
#include "utils.h"

/*********************************************************************/

int main (int argc, char **argv) {

	Img *img;
  PatCoords *pcoords;
	int x, y, w, h;
  ColorRGB hilightcolor = {255, 0, 0};
  PatsArray *pats;
  char *pdir, *infname, *outfname;
  int verbose = 0;

  if (argc == 3) {
    pdir = argv[1];
    infname = argv[2];
    outfname = NULL;
  } else if (argc == 4) {
    pdir = argv[1];
    infname = argv[2];
    outfname = argv[3];
  } else if (argc == 5) {
    if (strcmp(argv[1], "-v") == 0) {
      verbose = 1;
    } else {
      crash("unknown keys");
    }
    pdir = argv[2];
    infname = argv[3];
    outfname = argv[4];
  } else {
    crash("usage: findpats [-v] <pats_dir> <input_img.ppm> [output_img.ppm]");
  }

	img = loadimgppm(infname);

  pats = loadpats(pdir);
  if (verbose) {
    fprintf(stderr, "%d patterns were loaded\n", pats->len);
  }

  // TEST
  //cfgpatpxfailcount(pats->arr + 8, 305);

  pcoords = searchpats(img, pats);
  if (verbose) {
    fprintf(stderr, "objects found: %d\n", pcoords->len);
  }
  printpatcoords(pcoords);
  if (outfname) {
    hilightpats(img, pcoords, &hilightcolor);
    storeimgppm(img, outfname);
  }

	freeimg(img);

	return 0;
}

