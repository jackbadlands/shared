#include <stdlib.h>
#include <stdio.h>
#include "pmalloc.h"

void *pmalloc (size_t size) {
	void *p;
	p = malloc(size);
	if (p == NULL) {
		fprintf(stderr, "pmalloc(): Not enough memory");
		exit(3);
	}
	return p;
}

void *prealloc (void *oldp, size_t size) {
	void *p;
	p = realloc(oldp, size);
	if (p == NULL) {
		fprintf(stderr, "prealloc(): Not enough memory");
		exit(3);
	}
	return p;
}

void pfree (void *oldp) {
	free(oldp);
}

void *pcalloc (size_t nobj, size_t size) {
	void *p;
	p = calloc(nobj, size);
	if (p == NULL) {
		fprintf(stderr, "pcalloc(): Not enough memory");
		exit(3);
	}
	return p;
}

