#ifndef GETTIME_C
#define GETTIME_C

#include <sys/time.h>
#include <unistd.h>

/* returns current system time in seconds */
double gettime (void) {
	struct timeval tv;
	double time = 0;
	if (gettimeofday(&tv, NULL) != 0) {
		printf("gettimeofday() returned error\n");
		exit(3);
	}
	time = tv.tv_sec;
	time += ((double) tv.tv_usec) / 1000000;
	return time;
}

#endif

