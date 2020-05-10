#ifndef VISPROC_H
#define VISPROC_H

#include "commondatatypes.h"

Img *newimg(int w, int h);
unsigned char getimgr(Img *i, int x, int y);
unsigned char getimgg(Img *i, int x, int y);
unsigned char getimgb(Img *i, int x, int y);
void setimgrgb(Img *img, int x, int y, unsigned char r,
    unsigned char g, unsigned char b);
void freeimg(Img *img);
void storeimgppm(Img *img, char *fname);
Img *loadimgppm(char *fname);
static unsigned char rgbtoascii(Color r, Color g, Color b);
void printulcorner(Img *img, int ax, int ay, int aw, int ah);

/* img search */
int cmpimgarea(ImgCmpCfg *cfg);
PatsArray *loadpats(char *dir);
PatsArray *loadpat(char *fname, char *tmapname);
PatCoords *searchpats(Img *img, PatsArray *pats);
void hilightpats(Img *img, PatCoords *pcoords, ColorRGB *hlcolor);
void cfgpatalpha(Pat *pat, int mode);
void printpatcoords(PatCoords *pcoords);

#endif /* VISPROC_H */

