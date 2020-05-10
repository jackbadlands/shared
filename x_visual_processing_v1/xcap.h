#ifndef XCAP_H
#define XCAP_H

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/X.h>

#include "pmalloc.h"
#include "commonmacros.h"
#include "commondatatypes.h"

typedef struct {
	int w;
	int h;
	// area x/y and w/h
	int ax;
	int ay;
	int aw;
	int ah;
	XImage *ximg;
} Screenshot;

void opendisplay(void);
void closedisplay(void);
void copyscrtoimg(Screenshot *s, Img *img);
void getrootwindims(int *width, int *height);
Screenshot *getscr(void);
Screenshot *getareascr(int x, int y, int w, int h);
Img *getareascrimg(int x, int y, int w, int h);
void freescr(Screenshot *s);

#endif /* XCAP_H */

