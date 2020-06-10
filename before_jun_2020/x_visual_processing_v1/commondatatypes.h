#ifndef COMMONDATATYPES_H
#define COMMONDATATYPES_H

typedef unsigned char Color;

enum {
  PatCfgAlphaRUCorner,
  PatCfgAlphaLUCorner,
  PatCfgAlphaLast
};

typedef struct {
  Color r;
  Color g;
  Color b;
} ColorRGB;

typedef struct {
	int w;
	int h;
	unsigned char *px;
} Img;

typedef struct {
	int x;
	int y;
	int w;
	int h;
  int patno;
} PatCoord;

typedef struct {
  PatCoord *arr;
	int len;
} PatCoords;

typedef struct {

  struct {
    Img *img;
    int x;
    int y;
  } img1;

  struct {
    Img *img;
    int x;
    int y;
  } img2;

  struct {
    int used;
    ColorRGB color;
  } alpha2;

  struct {
    int used;
    Img *img;
  } tolerance;

  int w;
  int h;

  int pxcmpmode;
  unsigned int pxfailcount;
} ImgCmpCfg;

typedef struct {

  Img *img;

  struct {
    int used;
    ColorRGB color;
  } alpha;

  struct {
    int used;
    Img *img;
  } tolerance;

  unsigned int pxfailcount;

} Pat;

typedef struct {
  Pat *arr;
  unsigned int len;
} PatsArray;

#endif

