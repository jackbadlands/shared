/* Compile this way:
 * 	gcc this_source.c $(pkg-config --cflags --libs x11) -o prog_name
 */

#include <stdio.h>
#include <netpbm/ppm.h>
#include <unistd.h>

#include "gettime.c"
#include "pmalloc.h"
#include "commonmacros.h"
#include "commondatatypes.h"
#include "visproc.h"
#include "utils.h"

Img *newimg (int w, int h) {
	Img *i;
	i = pmalloc(sizeof(*i));
	i->px = pmalloc(w * h * 3 + 1);
	i->w = w;
	i->h = h;
	return i;
}

/* get red value from x,y from img */
unsigned char getimgr (Img *img, int x, int y) {
	return R(img->px, x, y, img->w);
}

/* get green value --//-- */
unsigned char getimgg (Img *img, int x, int y) {
	return G(img->px, x, y, img->w);
}

/* get blue value --//-- */
unsigned char getimgb (Img *img, int x, int y) {
	return B(img->px, x, y, img->w);
}

void setimgrgb (Img *img, int x, int y, unsigned char r,
    unsigned char g, unsigned char b) {
	R(img->px, x, y, img->w) = r;
	G(img->px, x, y, img->w) = g;
	B(img->px, x, y, img->w) = b;
}

void freeimg (Img *i) {
	free(i->px);
	free(i);
}

/* store image to PPM file */
void storeimgppm (Img *img, char *fname) {

	FILE *fd;
	pixel **px;
	int x, y;

	fd = fopen(fname, "wb");
	if (!fd) {
		crash("storeimgppm(): cannot open ppm file");
	}
	px = ppm_allocarray(img->w, img->h);
	if (!px) {
		crash("storeimgppm(): cannot allocate pixels");
	}

	for (y = 0; y < img->h; y++) {
		for (x = 0; x < img->w; x++) {
			PPM_ASSIGN(px[y][x],
					getimgr(img, x, y),
					getimgg(img, x, y),
					getimgb(img, x, y));
		}
	}

	ppm_writeppm(fd, px, img->w, img->h, 255, 0);

	ppm_freearray(px, img->h);
	fclose(fd);
}

/* load image from PPM file */
Img *loadimgppm (char *fname) {

	FILE *fd;
	pixel **pxs;
  Img *img;
	int x, y, w, h;
  pixval maxval;

  // open fd
	fd = fopen(fname, "rb");
	if (!fd) {
		crash("loadimgppm(): cannot open ppm file");
	}

  // read pixels
  pxs = ppm_readppm(fd, &w, &h, &maxval);
	if (!pxs) {
		crash("loadimgppm(): cannot read pixels");
	}

	fclose(fd);

  // check maxval
  if (maxval != 255) {
		crash("loadimgppm(): color max value is not supported");
  }

  // allocate img
  img = newimg(w, h);
  if (!img) {
		crash("loadimgppm(): cannot allocate mem for img");
  }

  // copy pixels to img
	for (y = 0; y < h; y++) {
		for (x = 0; x < w; x++) {

      unsigned char r, g, b;

      r = PPM_GETR(pxs[y][x]);
      g = PPM_GETG(pxs[y][x]);
      b = PPM_GETB(pxs[y][x]);
      
      setimgrgb(img, x, y, r, g, b);
		}
	}

  // free pixels array
	ppm_freearray(pxs, h);

  return img;
}

static unsigned char rgbtoascii (Color r, Color g, Color b) {

	unsigned int gray;
	char c;

	gray = (r + g + b) / 3;
	c = ' ';
	if (gray > 50)  c = '.';
	if (gray > 100) c = '-';
	if (gray > 150) c = ':';
	if (gray > 200) c = '=';
	if (gray > 250) c = 'A';

	return c;
}

void printulcorner (Img *img, int ax, int ay, int aw, int ah) {

	int x, y;

	for (y = ay; y < ay + ah; y++) {
		for (x = ax; x < ax + aw; x++) {

			Color r, g, b;
			char c;

			r = getimgr(img, x, y);
			g = getimgg(img, x, y);
			b = getimgb(img, x, y);
			c = rgbtoascii(r, g, b);
			printf("%c%c", c, c);
		}
		printf("\n");
	}
	fflush(stdout);
}

#define MAXPATN 1024
PatsArray *loadpats (char *dir) {

  int i, count;
  char fname[30];
  FILE *fd;
  Img *img;
  Pat *pats = NULL;
  int patsn = 0;
  PatsArray *patsarr;

  for (i = 0; i < MAXPATN; i++) {
    count = i + 1;
    sprintf(fname, "%s/%d.ppm", dir, i);
    if (access(fname, R_OK) == -1) {
      break;
    }
    img = loadimgppm(fname);
    pats = prealloc(pats, sizeof(*pats) * count);
    patsn = count;
    pats[i].img = img;
    pats[i].alpha.used = 0;
    pats[i].pxfailcount = 0;
    pats[i].tolerance.used = 0;

    // alpha cfg (if exist)
    sprintf(fname, "%s/%d.alphalu", dir, i);
    if (access(fname, R_OK) == 0) {
      cfgpatalpha(pats + i, PatCfgAlphaLUCorner);
    }
    sprintf(fname, "%s/%d.alpharu", dir, i);
    if (access(fname, R_OK) == 0) {
      cfgpatalpha(pats + i, PatCfgAlphaRUCorner);
    }

    // tolerance map (if exist)
    sprintf(fname, "%s/%d_tmap.ppm", dir, i);
    if (access(fname, R_OK) == 0) {
      pats[i].tolerance.used = 1;
      pats[i].tolerance.img = loadimgppm(fname);
    }
  }
  
  patsarr = pmalloc(sizeof(*patsarr));
  patsarr->arr = pats;
  patsarr->len = patsn;

  return patsarr;
}

PatsArray *loadpat (char *fname, char *tmapname) {

  FILE *fd;
  Img *img;
  Pat *pat = NULL;
  PatsArray *patsarr;

  img = loadimgppm(fname);
  pat = pmalloc(sizeof(*pat));
  pat->img = img;
  pat->alpha.used = 0;
  pat->pxfailcount = 0;
  pat->tolerance.used = 0;

  // tolerance map (if specified)
  if (tmapname) {
    pat->tolerance.used = 1;
    pat->tolerance.img = loadimgppm(tmapname);
  }

  patsarr = pmalloc(sizeof(*patsarr));
  patsarr->arr = pat;
  patsarr->len = 1;

  return patsarr;
}

void cfgpatalpha (Pat *pat, int mode) {

  if (mode == PatCfgAlphaRUCorner) {

    int x, y;

    x = pat->img->w - 1;
    y = 0;

    pat->alpha.used = 1;
    pat->alpha.color.r = getimgr(pat->img, x, y);
    pat->alpha.color.g = getimgg(pat->img, x, y);
    pat->alpha.color.b = getimgb(pat->img, x, y);

  } else if (mode == PatCfgAlphaLUCorner) {

    int x, y;

    x = 0;
    y = 0;

    pat->alpha.used = 1;
    pat->alpha.color.r = getimgr(pat->img, x, y);
    pat->alpha.color.g = getimgg(pat->img, x, y);
    pat->alpha.color.b = getimgb(pat->img, x, y);

  } else {
    crash("cfgpatalpha() unknown mode");
  }
}

void cfgpatpxfailcount (Pat *pat, unsigned int count) {
  pat->pxfailcount = count;
}

int cmpimgarea (ImgCmpCfg *c) {

  int x, y;
  int x1, x2;
  int y1, y2;
  int endx, endy;
  unsigned int pxfailsleft;

  pxfailsleft = c->pxfailcount;
  
  endx = c->w;
  endy = c->h;

  for (y = 0; y < endy; y++) {
    for (x = 0; x < endx; x++) {

      Color r1, g1, b1;
      Color r2, g2, b2;
      Color r3, g3, b3;
      int match;

      x1 = c->img1.x + x;
      y1 = c->img1.y + y;

      x2 = c->img2.x + x;
      y2 = c->img2.y + y;

      r1 = getimgr(c->img1.img, x1, y1);
      g1 = getimgg(c->img1.img, x1, y1);
      b1 = getimgb(c->img1.img, x1, y1);

      r2 = getimgr(c->img2.img, x2, y2);
      g2 = getimgg(c->img2.img, x2, y2);
      b2 = getimgb(c->img2.img, x2, y2);

      if (c->tolerance.used) {
        r3 = getimgr(c->tolerance.img, x2, y2);
        g3 = getimgg(c->tolerance.img, x2, y2);
        b3 = getimgb(c->tolerance.img, x2, y2);
      }

      /* skip img2 alpha regions */
      if (c->alpha2.used) {
        if (r2 == c->alpha2.color.r &&
            g2 == c->alpha2.color.g &&
            b2 == c->alpha2.color.b)
        {
          continue;
        }
      }

      match = 1;
      if (c->tolerance.used) {
        Color dr, dg, db;
        dr = DCOLOR(r1, r2);
        dg = DCOLOR(g1, g2);
        db = DCOLOR(b1, b2);
        if (dr > r3 || dg > g3 || db > b3) {
          match = 0;
        }
      } else {
        if (r1 != r2 || g1 != g2 || b1 != b2) {
          match = 0;
        }
      }

      if (!match) {
        if (pxfailsleft > 0) {
          // DBG printf("pxfail %d\n", pxfailsleft);
          pxfailsleft--;
        } else {
          // DBG printf("pxfail %d\n", pxfailsleft);
          return 0;
        }
      }
    }
  }
  return 1;
}

PatCoords *searchpats (Img *img, PatsArray *pats) {

  PatCoords *pco;
  int imgx, imgy, patx, paty, patno, patcount;
  double lastmsgtime, curtime;

  lastmsgtime = gettime();

  pco = pmalloc(sizeof(*pco));
  pco->arr = NULL;
  pco->len = 0;

  patcount = pats->len;

  for (imgy = 0; imgy < img->h; imgy++) {
    curtime = gettime();
    // verbocity
    if (curtime - lastmsgtime > 1) {
      double progress;
      progress = (double) imgy / (double) img->h;
      fprintf(stderr, "srchpats progress: %.2f%%\n", progress * 100);
      lastmsgtime = curtime;
    }
    for (imgx = 0; imgx < img->w; imgx++) {
      for (patno = 0; patno < patcount; patno++) {

        Img *patimg;
        ImgCmpCfg cfg;
        Pat *pat;
        int areaw, areah;

        pat = pats->arr + patno;
        patimg = pat->img;
        areaw = patimg->w;
        areah = patimg->h;

        /* correct area w/h for out of bounds
        if (imgx + areaw >= img->w) {
          areaw = img->w - imgx;
        }
        if (imgy + areah >= img->h) {
          areah = img->h - imgy;
        }
         */

        /* skip area w/h for out of bounds */
        if (imgx + areaw >= img->w) {
          continue;
        }
        if (imgy + areah >= img->h) {
          continue;
        }

        cfg.img1.img = img;
        cfg.img1.x = imgx;
        cfg.img1.y = imgy;

        cfg.img2.img = patimg;
        cfg.img2.x = 0;
        cfg.img2.y = 0;

        cfg.w = areaw;
        cfg.h = areah;

        cfg.alpha2.used = pat->alpha.used;
        cfg.pxfailcount = pat->pxfailcount;

        cfg.tolerance.used = pat->tolerance.used;
        cfg.tolerance.img = pat->tolerance.img;

        if (cmpimgarea(&cfg)) {

          int newpcolen, newpcoidx;

          newpcolen = pco->len + 1;
          newpcoidx = pco->len;

          pco->arr = prealloc(pco->arr, sizeof(pco->arr[0]) * newpcolen);

          pco->arr[newpcoidx].x = imgx;
          pco->arr[newpcoidx].y = imgy;
          pco->arr[newpcoidx].w = areaw;
          pco->arr[newpcoidx].h = areah;
          pco->arr[newpcoidx].patno = patno;

          pco->len = newpcolen;
        }
      } // patno
    } // imgx
  } // imgy

  return pco;
}

/* TODO declare */
void printpatcoords (PatCoords *pcoords) {

  int i;
  for (i = 0; i < pcoords->len; i++) {

    PatCoord *pc;
    pc = pcoords->arr + i;

    printf("patno:%d,x:%d,y:%d,w:%d,h:%d,endx:%d,endy:%d\n",
        pc->patno, pc->x, pc->y, pc->w, pc->h,
        pc->x + pc->w,
        pc->y + pc->h
    );
  }
}

void hilightpats (Img *img, PatCoords *pcoords, ColorRGB *hlcolor) {
  int i, x, y;
  for (i = 0; i < pcoords->len; i++) {

    PatCoord *pc;
    int endx, endy;

    pc = pcoords->arr + i;

    endx = pc->x + pc->w;
    endy = pc->y + pc->h;

#define HILIGHT() \
      R(img->px, x, y, img->w) = hlcolor->r;\
      G(img->px, x, y, img->w) = hlcolor->g;\
      B(img->px, x, y, img->w) = hlcolor->b;\

    for (x = pc->x; x < endx; x++) {

      y = pc->y;
      HILIGHT();

      y = endy - 1;
      HILIGHT();
    }

    for (y = pc->y; y < endy; y++) {

      x = pc->x;
      HILIGHT();

      x = endx - 1;
      HILIGHT();
    }
#undef HILIGHT
  }
}

