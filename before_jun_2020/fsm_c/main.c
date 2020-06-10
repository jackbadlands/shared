/*
 * Finite state machine (FSM) + scheduler module.
 * use after() and main_loop() to control FSM.
 *
 * what is it for:
 *   It is yet another way to perform many tasks simultaneously.
 *   you can write functions "callbacks" that will call each
 *   other using after(). small portions of code will give control
 *   to each other during time (with or without delay). There are
 *   another callbacks will be executed in case of other one is idle.
 *   FSM is single-threaded. It is probably NOT good replacement
 *   for threads/processes.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

#include "pmalloc.h"
#include "pmalloc.c"

typedef void (*FSMCb)(int idata, void *pdata);

struct fsmrec {
	FSMCb cb;
	void *pdata;
	int idata;
	double waketime;
};

struct fsm_rec_array {
	struct fsmrec *recs;
	size_t allocated;
	size_t size;
};

struct fsm_rec_array *curarray = NULL;
struct fsm_rec_array *nextarray = NULL;
struct fsm_rec_array *delayarray = NULL;

#define NOT_IMPLEMENTED { printf("not implemented\n"); exit(2); }
#define DBGLINE printf("line #%d\n", __LINE__)

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

/* init FSM before use at program startup */
void fsm_init (void) {

	curarray   = pmalloc(sizeof(struct fsm_rec_array));
	nextarray  = pmalloc(sizeof(struct fsm_rec_array));
	delayarray = pmalloc(sizeof(struct fsm_rec_array));

#define DFLT_SIZE 50

	curarray->recs   = pmalloc(sizeof(struct fsmrec) * DFLT_SIZE);
	nextarray->recs  = pmalloc(sizeof(struct fsmrec) * DFLT_SIZE);
	delayarray->recs = pmalloc(sizeof(struct fsmrec) * DFLT_SIZE);

	curarray->allocated   = DFLT_SIZE;
	nextarray->allocated  = DFLT_SIZE;
	delayarray->allocated = DFLT_SIZE;

#undef DFLT_SIZE

	curarray->size   = 0;
	nextarray->size  = 0;
	delayarray->size = 0;
}

/* internal. use it to allocate memory for record in array */
struct fsmrec *touch_array_rec (struct fsm_rec_array *arr, size_t recn) {
#define STEP 50
	if (recn >= arr->allocated) {
		size_t newsize = recn + STEP;
		arr->recs = prealloc(arr->recs,
				sizeof(struct fsmrec) * newsize);
		arr->allocated = newsize;
	}
#undef STEP
	return &(arr->recs[recn]);
}

/* creates record in array and increases ->size struct rec */
struct fsmrec *new_array_rec (struct fsm_rec_array *arr) {
	size_t recn;
	struct fsmrec *rec;
	recn = arr->size;
	rec = touch_array_rec(arr, recn);
	arr->size += 1;
	return rec;
}

/* swaps curarray and nextarray */
void swap_arrays (void) {
#define A curarray
#define B nextarray
#define TYPE struct fsm_rec_array
	TYPE *tmp;
	tmp = A;
	A = B;
	B = A;
#undef A
#undef B
#undef TYPE
}

/* API. use to schedule next callback */
void after (double delay, FSMCb cb, int idata, void *pdata) {
	struct fsmrec *rec;
	if (delay > 0) {
		double curtime;
		curtime = gettime();
		rec = new_array_rec(delayarray);
		rec->cb = cb;
		rec->idata = idata;
		rec->pdata = pdata;
		rec->waketime = curtime + delay;
	} else {
		rec = new_array_rec(nextarray);
		rec->cb = cb;
		rec->idata = idata;
		rec->pdata = pdata;
		rec->waketime = 0;
	}
}

/* API. FSM mainloop. use after() to add startup callbacks to FSM
 * and call main_loop() to start FSM */
void main_loop (void) {
	double curtime;
	size_t i;
	struct fsmrec *rec;
	while (1) {
		curtime = gettime();
		swap_arrays();
		for (i = 0; i < curarray->size; i++) {
			rec = &(curarray->recs[i]);
			(rec->cb)(rec->idata, rec->pdata);
		}
		curarray->size = 0;
		// call delayed callbacks
		i = 0;
		while (i < delayarray->size) {
			rec = &(delayarray->recs[i]);
			if (rec->waketime <= curtime) {
				size_t lastrecn;
				(rec->cb)(rec->idata, rec->pdata);
				lastrecn = delayarray->size - 1;
				delayarray->recs[i] = delayarray->recs[lastrecn];
				delayarray->size -= 1;
			} else {
				i++;
			}
		}
#define IDLE_DELAY 10000 /* usecs */
		if (nextarray->size == 0) {
			usleep(IDLE_DELAY);
			// printf("idle\n"); // DEBUG
		}
	}
}

/* example callbacks */

void notifyImmediately (int d, void *p) {
	printf("notify-imm! %d\n", d);
}

void notify2sec (int d, void *p) {
	printf("notify! %d nextsz = %d nextalc = %d\n", d, nextarray->size,
			nextarray->allocated);
	after(0, notifyImmediately, d + 1, NULL);
	after(2, notify2sec, d + 1, NULL);
}

/* example callbacks END */

/* FSM usage example */
int main (int argc, char **argv)
{
	fsm_init();
	after(0, notify2sec, 0, NULL);
	main_loop();
	return 0;
}

