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
  char *patname, *pattname, *infname, *outfname;

  if (argc == 4) {
    patname = argv[1];
    pattname = argv[2];
    infname = argv[3];
    outfname = NULL;
  } else if (argc == 5) {
    patname = argv[1];
    pattname = argv[2];
    infname = argv[3];
    outfname = argv[4];
  } else {
    crash("usage: findpattm <pat.ppm> <pat_tmap.ppm> <input_img.ppm>"
        " [output_img.ppm]");
  }

	img = loadimgppm(infname);

  pat = loadpat(patname, pattname);

  pcoords = searchpats(img, pat);
  printpatcoords(pcoords);

  if (outfname) {
    hilightpats(img, pcoords, &hilightcolor);
    storeimgppm(img, outfname);
  }

	freeimg(img);

	return 0;
}

