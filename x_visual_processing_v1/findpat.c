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
  PatsArray *pat;
  char *patname, *infname, *outfname;

  if (argc == 3) {
    patname = argv[1];
    infname = argv[2];
    outfname = NULL;
  } else if (argc == 4) {
    patname = argv[1];
    infname = argv[2];
    outfname = argv[3];
  } else {
    crash("usage: findpat <pat.ppm> <input_img.ppm> [output_img.ppm]");
  }

	img = loadimgppm(infname);

  pat = loadpat(patname, NULL);

  pcoords = searchpats(img, pat);
  printpatcoords(pcoords);

  if (outfname) {
    hilightpats(img, pcoords, &hilightcolor);
    storeimgppm(img, outfname);
  }

	freeimg(img);

	return 0;
}

