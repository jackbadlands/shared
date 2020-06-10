#include <stdio.h>
#include "xcap.h"
#include "visproc.h"
#include "utils.h"

/*********************************************************************/

int main (int argc, char **argv) {

	Img *img;
	int w, h;
  char *fname;

  if (argc != 2) {
    crash("usage: capscreen <out_img_file.ppm>");
  }

  fname = argv[1];

	opendisplay();

  getrootwindims(&w, &h);
	img = getareascrimg(0, 0, w, h);
  storeimgppm(img, fname);
	freeimg(img);

	closedisplay();

	return 0;
}

