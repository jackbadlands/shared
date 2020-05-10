/* Compile this way:
 * 	gcc xlib_screenshot.c $(pkg-config --cflags --libs x11) -o xshot
 */

#include <stdio.h>
#include <stdlib.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/X.h>
#include "gettime.c"
#include <netpbm/ppm.h>
#include <unistd.h>

Display *display;
Window root;
int xdisplay_is_touched = 0;

void touch_xdisplay (void) {
	if (!xdisplay_is_touched) {
		// update globals
		display = XOpenDisplay(NULL);
		root = DefaultRootWindow(display);
		xdisplay_is_touched = 1;
	}
}

void get_display_dimensions (int *width, int *height) {
	touch_xdisplay();
	XWindowAttributes gwa;
	XGetWindowAttributes(display, root, &gwa);
	*width = gwa.width;
	*height = gwa.height;
}

XImage *get_display_screenshot (void) {

	int width, height;
	XImage *image = NULL;

	touch_xdisplay();
	get_display_dimensions(&width, &height);
	image = XGetImage(display, root, 0, 0,
			width, height, AllPlanes, ZPixmap);
	return image;
}

XImage *get_display_area_screenshot (int x, int y, int w, int h) {

	int width, height;
	XImage *image = NULL;

	touch_xdisplay();
	get_display_dimensions(&width, &height);
	image = XGetImage(display, root, x, y,
			w, h, AllPlanes, ZPixmap);
	return image;
}

void streaming_loop (void) {

	int width, height, i, x, y;
	XImage *image = NULL;
	unsigned long red_mask, green_mask, blue_mask;
	int area_x = 100, area_y = 50;
	int area_w = 640, area_h = 480;

	touch_xdisplay();
	get_display_dimensions(&width, &height);

	i = 1;
	while (1) {

		//image = get_display_screenshot();
		image = get_display_area_screenshot(area_x, area_y,
				area_w, area_h);

		red_mask = image->red_mask;
		green_mask = image->green_mask;
		blue_mask = image->blue_mask;

		for (y = 0; y < area_h; y++) {
			for (x = 0; x < area_w; x++) {
				
				unsigned long pixel;
				unsigned char rgb[3];

				pixel = XGetPixel(image, x, y);
				rgb[2] =  pixel & blue_mask;
				rgb[1] = (pixel & green_mask) >> 8;
				rgb[0] = (pixel & red_mask)   >> 16;
				fwrite(rgb, 1, 3, stdout);
			}
		}
		fflush(stdout);

		XDestroyImage(image);

		usleep(40000);

		fprintf(stderr, "desk_cap_frame %d\n", i);
		i++;
	}
}


int main (int argc, char **argv) {

	// init ppm lib
	ppm_init(&argc, argv);
	touch_xdisplay();
	streaming_loop();

	return 0;
}

