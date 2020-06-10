/* Compile this way:
 * 	gcc this_source.c $(pkg-config --cflags --libs x11) -o prog_name
 */

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/X.h>

#include "pmalloc.h"
#include "dbgprints.h"
#include "commonmacros.h"
#include "commondatatypes.h"
#include "xcap.h"
#include "visproc.h"

// globals
static Display *display;

void opendisplay (void) {
	// update globals
	display = XOpenDisplay(NULL);
}

void closedisplay (void) {
	// update globals
	XCloseDisplay(display);
	display = NULL;
}

void copyscrtoimg (Screenshot *s, Img *img) {

	unsigned long int rmask, gmask, bmask;
	int x, y;

	rmask = s->ximg->red_mask;
	gmask = s->ximg->green_mask;
	bmask = s->ximg->blue_mask;

	for (y = 0; y < s->ah; y++) {
		for (x = 0; x < s->aw; x++) {
			unsigned long px;
			px = XGetPixel(s->ximg, x, y);
			B(img->px, x, y, s->aw) =  px & bmask;
			G(img->px, x, y, s->aw) = (px & gmask) >> 8;
			R(img->px, x, y, s->aw) = (px & rmask) >> 16;
		}
	}
}

/* get width/height of display's root window */
void getrootwindims (int *width, int *height) {
	XWindowAttributes gwa;
	Window root;
	root = DefaultRootWindow(display);
	XGetWindowAttributes(display, root, &gwa);
	*width = gwa.width;
	*height = gwa.height;
}

/* get screenshot of whole screen */
Screenshot *getscr (void) {
	int w, h;
	getrootwindims(&w, &h);
	return getareascr(0, 0, w, h);
}

/* get screenshot of screen area */
Screenshot *getareascr (int x, int y, int w, int h) {

	Screenshot *s;
	Window root;

	s = pmalloc(sizeof(*s));

	s->ax = x;
	s->ay = y;
	s->aw = w;
	s->ah = h;

	root = DefaultRootWindow(display);
	getrootwindims(&(s->w), &(s->h));
	s->ximg = XGetImage(display, root, x, y,
			w, h, AllPlanes, ZPixmap);

	return s;
}

/* get screenshot of screen area in Img format */
Img *getareascrimg (int x, int y, int w, int h) {

	Img *i;
	Screenshot *s;

	s = getareascr(x, y, w, h);
	i = newimg(w, h);
	copyscrtoimg(s, i);
	freescr(s);

  return i;
}

/* free screenshot structure */
void freescr (Screenshot *s) {
	XDestroyImage(s->ximg);
	free(s);
}

