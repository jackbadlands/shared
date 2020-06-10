/*
 * SDL OpenGL Tutorial.
 * (c) Michael Vance, 2000
 * briareos@lokigames.com
 *
 * Distributed under terms of the LGPL. 
 */

#include <SDL/SDL.h>
#include <GL/gl.h>
#include <GL/glu.h>

#include <stdio.h>
#include <stdlib.h>


#define WIDTH 640
#define HEIGHT 480

static GLubyte pImage[WIDTH*HEIGHT*3];

static void quit_app (int code)
{
    /*
     * Quit SDL so we can release the fullscreen
     * mode and restore the previous video settings,
     * etc.
     */
    SDL_Quit();

    /* Exit program. */
    exit( code );
}

static void process_events( void )
{
    /* Our SDL event placeholder. */
    SDL_Event event;

    /* Grab all the events off the queue. */
    while( SDL_PollEvent( &event ) ) {

        switch( event.type ) {
        case SDL_KEYDOWN:
            /* Handle key presses. */
            break;
        case SDL_KEYUP:
            /* Handle key presses. */
            break;
        case SDL_QUIT:
            /* Handle quit requests (like Ctrl-c). */
            quit_app(0);
            break;
        }
    }
}

static void draw_screen( void )
{
	GLint iWidth = WIDTH, iHeight = HEIGHT;
	glClear(GL_COLOR_BUFFER_BIT);
	glRasterPos2i(-1, 1);
	glPixelZoom(1, -1);
	glDrawPixels(iWidth, iHeight, GL_RGB, GL_UNSIGNED_BYTE, pImage);
  SDL_GL_SwapBuffers();
}

static void setup_opengl( int width, int height )
{
	//glViewport(0, HEIGHT, WIDTH, 0);

	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
}

int main( int argc, char* argv[] )
{
    /* Information about the current video settings. */
    const SDL_VideoInfo* info = NULL;
    /* Dimensions of our window. */
    int width = 0;
    int height = 0;
    /* Color depth in bits of our window. */
    int bpp = 0;
    /* Flags we will pass into SDL_SetVideoMode. */
    int flags = 0;

    /* First, initialize SDL's video subsystem. */
    if( SDL_Init( SDL_INIT_VIDEO ) < 0 ) {
        /* Failed, exit. */
        fprintf( stderr, "Video initialization failed: %s\n",
             SDL_GetError( ) );
        quit_app(1);
    }

    /* Let's get some video information. */
    info = SDL_GetVideoInfo( );

    if( !info ) {
        /* This should probably never happen. */
        fprintf( stderr, "Video query failed: %s\n",
             SDL_GetError( ) );
        quit_app(1);
    }

    /*
     * Set our width/height to 640/480 (you would
     * of course let the user decide this in a normal
     * app). We get the bpp we will request from
     * the display. On X11, VidMode can't change
     * resolution, so this is probably being overly
     * safe. Under Win32, ChangeDisplaySettings
     * can change the bpp.
     */
    width = WIDTH;
    height = HEIGHT;
    bpp = info->vfmt->BitsPerPixel;

    /*
     * Now, we want to setup our requested
     * window attributes for our OpenGL window.
     * We want *at least* 5 bits of red, green
     * and blue. We also want at least a 16-bit
     * depth buffer.
     *
     * The last thing we do is request a double
     * buffered window. '1' turns on double
     * buffering, '0' turns it off.
     *
     * Note that we do not use SDL_DOUBLEBUF in
     * the flags to SDL_SetVideoMode. That does
     * not affect the GL attribute state, only
     * the standard 2D blitting setup.
     */
    SDL_GL_SetAttribute( SDL_GL_RED_SIZE, 5 );
    SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE, 5 );
    SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE, 5 );
    SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 16 );
    SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );

    /*
     * We want to request that SDL provide us
     * with an OpenGL window, in a fullscreen
     * video mode.
     *
     * EXERCISE:
     * Make starting windowed an option, and
     * handle the resize events properly with
     * glViewport.
     */
    //flags = SDL_OPENGL | SDL_FULLSCREEN;
    flags = SDL_OPENGL;

    /*
     * Set the video mode
     */
    if( SDL_SetVideoMode( width, height, bpp, flags ) == 0 ) {
        /* 
         * This could happen for a variety of reasons,
         * including DISPLAY not being set, the specified
         * resolution not being available, etc.
         */
        fprintf( stderr, "Video mode set failed: %s\n",
             SDL_GetError( ) );
        quit_app(1);
    }

    /*
     * At this point, we should have a properly setup
     * double-buffered window for use with OpenGL.
     */
    setup_opengl( width, height );

		{
			int x, y;
			for (y = 0; y < HEIGHT; y++) {
				for (x = 0; x < WIDTH; x++) {
					int r = 0, g = 1, b = 2;
					GLbyte *pxr, *pxg, *pxb;

					pxr = pImage + y * WIDTH * 3 + x * 3 + r;
					pxg = pImage + y * WIDTH * 3 + x * 3 + g;
					pxb = pImage + y * WIDTH * 3 + x * 3 + b;

					/* black at zero coord
					 * cyan at y-max
					 * red at x-max
					 * white at y-max and x-max
					 */
					*pxr = 255 * x / WIDTH;
					*pxb = 255 * y / HEIGHT;
					*pxg = 255 * y / HEIGHT;
				}
			}
		}

    /*
     * Now we want to begin our normal app process--
     * an event loop with a lot of redrawing.
     */
    while(1) {
				/* read image */
				fread(pImage, 1, 640 * 480 * 3, stdin);
        /* Process incoming events. */
        process_events();
        /* Draw the screen. */
        draw_screen();
    }

    /* Never reached. */
    return 0;
}

