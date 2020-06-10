/* Compile this way:
 * 	gcc this_source.c $(pkg-config --cflags --libs x11) -o prog_name
 */

#include <stdio.h>
#include <stdlib.h>

#include "commonmacros.h"
#include "utils.h"

void crash (char *msg) {
	fprintf(stderr, "%s\n", msg);
	exit(2);
}

