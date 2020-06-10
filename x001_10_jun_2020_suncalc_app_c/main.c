#include <stdlib.h>
#include <math.h>

#define PI (acos(-1))
#define rad (PI / 180)

/* comments, descriptions of vars. doesn't do anything */
#define _OUT_
#define _GLOBAL_

double arcctg (double x) {
  return PI / 2 - atan(x);
}

double day_ms = 1000 * 60 * 60 * 24; /* need? */
double day_sec = 60 * 60 * 24;
double J1970 = 2440588;
double J2000 = 2451545;

double to_julian (double unix_secs_date) {
  return unix_secs_date / day_sec - 0.5 + J1970;
}

double from_julian (double j) {
  return (j + 0.5 - J1970) * day_sec;
}

double to_days (double unix_secs_date) {
  return to_julian(unix_secs_date) - J2000;
}

/* general calculations for position */

#define e (rad * 23.4397) /* obliquity of the Earth */

double right_ascension (double l, double b) {
  return atan2(sin(l) * cos(e) - tan(b) * sin(e), cos(l));
}

double declination (double l, double b) {
  return asin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l));
}

double azimuth (double H, double phi, double dec) {
  return atan2(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi));
}

double altitude (double H, double phi, double dec) {
  return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H));
}

double sidereal_time (double d, double lw) {
  return rad * (280.16 + 360.9856235 * d) - lw;
}

double astro_refraction (double h) {
  if (h < 0) { /* the following formula works for positive altitudes only. */
    h = 0; /* if h = -0.08901179 a div/0 would occur. */
  }

  /* formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus
   * (Willmann-Bell, Richmond) 1998.
   * 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in
   * arc minutes -> converted to rad:
   */
  return 0.0002967 / tan(h + 0.00312536 / (h + 0.08901179));
}

/* general sun calculations */

double solar_mean_anomaly (double d) {
  return rad * (357.5291 + 0.98560028 * d);
}

double ecliptic_longitude (double M) {
  double C, P;

  /* equation of center */
  C = rad * (1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M));

  /* perihelion of the Earth */
  P = rad * 102.9372;

  return M + C + P + PI;
}

struct sun_coords {
  double dec;
  double ra;
};

void sun_coords (double d, _OUT_ struct sun_coords *sun) {
  double M, L;

  M = solar_mean_anomaly(d);
  L = ecliptic_longitude(M);

  sun->dec = declination(L, 0);
  sun->ra = right_ascension(L, 0);
}

/* calculates sun position for a given date and latitude/longitude */

struct sun_position {
  double azimuth;  /* - */
  double altitude; /* | */
};

void suncalc_get_position (double date, double lat, double lng,
    _OUT_ struct sun_position *pos) {

  double lw, phi, d, H;
  struct sun_coords c;

  lw  = rad * -lng;
  phi = rad * lat;
  d   = to_days(date);

  sun_coords(d, &c);
  H = sidereal_time(d, lw) - c.ra;

  pos->azimuth = azimuth(H, phi, c.dec);
  pos->altitude = altitude(H, phi, c.dec);
}

struct sun_time {
  double angle;
  char *rise_name;
  char *set_name;
};

struct sun_time default_sun_times[] = {
  {-0.833, "sunrise",         "sunset"        },
  {  -0.3, "sunrise_end",     "sunset_start"  },
  {    -6, "dawn",            "dusk"          },
  {   -12, "nautical_dawn",   "nautical_dusk" },
  {   -18, "night_end",       "night"         },
  {     6, "golden_hour_end", "golden_hour"   },
  {    15, "15_deg_am",       "15_deg_pm"     },
  {     0, NULL,              NULL            },
};

/* calculations for sun times */

double J0 = 0.0009;

double julian_cycle (double d, double lw) {
    return round(d - J0 - lw / (2 * PI));
}

double approx_transit (double Ht, double lw, double n) {
  return J0 + (Ht + lw) / (2 * PI) + n;
}

double solar_transit_j (double ds, double M, double L) {
  return J2000 + ds + 0.0053 * sin(M) - 0.0069 * sin(2 * L);
}

double hour_angle (double h, double phi, double d) {
  return acos((sin(h) - sin(phi) * sin(d)) / (cos(phi) * cos(d)));
}

/* returns set time for the given sun altitude */
double get_set_j (double h, double lw, double phi, double dec, double n,
    double M, double L) {
  double w, a;
  w = hour_angle(h, phi, dec);
  a = approx_transit(w, lw, n);
  return solar_transit_j(a, M, L);
}

/* calculates sun times for a given date and latitude/longitude */

struct time_result {
  char *name_ptr;
  double time;
};

char SOLAR_NOON_NAME[] = "solar_noon";
char NADIR_NAME[] = "nadir";
char *solar_noon_name_override = NULL;
char *nadir_name_override = NULL;

int time_result_cmp (void *va, void *vb) {
  struct time_result *a, *b;
  a = va;
  b = vb;
  /* nan cmp */
  if (isnan(a->time) && isnan(b->time)) return 0;
  if (isnan(a->time)) return 1;
  if (isnan(b->time)) return -1;
  /* normal cmp */
  if (a->time < b->time) return -1;
  if (a->time > b->time) return 1;
  return 0;
}

struct time_result *suncalc_get_times (double date, double lat, double lng,
    struct sun_time *times) {
  double lw, phi, d, n, ds, M, L, dec, j_noon, time, j_set, j_rise;
  int i;
  struct time_result *result = NULL;
  size_t times_count = 0;
  struct sun_time *sun_time_p;
  struct time_result *result_p;
  size_t result_items_count;

  lw = rad * -lng;
  phi = rad * lat;

  d = to_days(date);
  n = julian_cycle(d, lw);
  ds = approx_transit(0, lw, n);

  M = solar_mean_anomaly(ds);
  L = ecliptic_longitude(M);
  dec = declination(L, 0);

  j_noon = solar_transit_j(ds, M, L);

  /* count times */
  times_count = 0;
  for (sun_time_p = times; sun_time_p->rise_name != NULL; sun_time_p++) {
    times_count++;
  }

  /* allocate results array x 2 + 2 (nadir/noon) + 1 (terminator) */
  result_items_count = times_count * 2 + 2;
  result = malloc(sizeof(*result) * (result_items_count + 1));
  if (result == NULL) {
    return NULL;
  }
  result_p = result;

  if (solar_noon_name_override != NULL) {
    result_p->name_ptr = solar_noon_name_override;
  } else {
    result_p->name_ptr = SOLAR_NOON_NAME;
  }
  result_p->time = from_julian(j_noon);
  result_p++;

  if (nadir_name_override != NULL) {
    result_p->name_ptr = nadir_name_override;
  } else {
    result_p->name_ptr = NADIR_NAME;
  }
  result_p->time = from_julian(j_noon - 0.5);
  result_p++;

  for (sun_time_p = times; sun_time_p->rise_name != NULL; sun_time_p++) {
    double j_set, j_rise;

    j_set = get_set_j(sun_time_p->angle * rad, lw, phi, dec, n, M, L);
    j_rise = j_noon - (j_set - j_noon);

    result_p->name_ptr = sun_time_p->rise_name;
    result_p->time = from_julian(j_rise);
    result_p++;

    result_p->name_ptr = sun_time_p->set_name;
    result_p->time = from_julian(j_set);
    result_p++;
  }

  /* terminator */
  result_p->name_ptr = NULL;
  result_p->time = 0;

  /* sort results by time */
  qsort(result, result_items_count, sizeof(*result),
      (__compar_fn_t) time_result_cmp);

  return result;
}

void destroy_time_result (struct time_result *res) {
  free(res);
}

/* get_time() ***************************************************************/

#ifndef GETTIME_C
#define GETTIME_C

#include <sys/time.h>
#include <unistd.h>
#include <stdio.h>

/* returns current system time in seconds */
double get_time (void) {
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

/* main *********************************************************************/

#include <string.h>
#include <time.h>
#include <math.h>
#include <stdio.h>

struct sun_time my_sun_times[] = {
  {
    -0.833,
    "sunrise start",
    "sunset end    (Magrib)"
  },
  {
    -0.3,
    "sunrise end",
    "sunset start"
  },
  {
    -6,
    "dawn",
    "dusk"
  },
  {
    -12,
    "naut dawn     (Fajr)", 
    "naut dusk"
  },
  {
    -18,
    "night end",
    "night         (Isha)"
  },
  {
    15,
    "15 deg AM",
    "15 deg PM     (Asr)"
  },
  {0, NULL, NULL},
};

/* src: https://stackoverflow.com/questions/14920675/is-there-a-function-in-c-language-to-calculate-degrees-radians */
double to_degrees (double radians) {
  return radians * (180.0 / M_PI);
}

void report_sun_data (struct sun_position *pos, struct time_result *res) {
  struct time_result *res_p;
  time_t t;
  char l[352], passed;
  double cur_time;
  char sep[]  = "=====================================";
  double alt_deg, azi_deg;

  cur_time = get_time();
  t = cur_time;
  strftime(l, 350, "now is %H:%M, %a, %b %d", localtime(&t));
  printf("%s\n", sep);
  printf("%s\n", l);

  alt_deg = to_degrees(pos->altitude);
  azi_deg = to_degrees(pos->azimuth);
  printf("sun altitude [|] %6.2f deg\n", alt_deg);
  printf("sun azimuth  [-] %6.2f deg\n", azi_deg);
  printf("%s\n", sep);

  for (res_p = res; res_p->name_ptr != NULL; res_p++) {
    if (!isnan(res_p->time)) {
      t = res_p->time;
      passed = ' ';
      if (cur_time > res_p->time) {
        passed = 'X';
      }
      strftime(l, 350, "%a %H:%M", localtime(&t));
      printf("%c %-23s %-15s\n", passed, res_p->name_ptr, l);
    }
  }
}

int main (int argc, char **argv) {
  struct time_result *res, *res_p;
  double lat = 49.9388475;
  double lng = 36.21780396;
  double day;
  int i;
  int continuous = 0;
  struct sun_position pos;

  if (argc >= 2 && strcmp(argv[1], "-c") == 0) {
    continuous = 1;
  }

check_sun_times:

  day = get_time();
  solar_noon_name_override = "solar noon    (Zuhr)";
  res = suncalc_get_times(day, lat, lng, my_sun_times);
  if (res == NULL) {
    fprintf(stderr, "cannot get times\n");
    exit(1);
  }
  /*
  for (res_p = res; res_p->name_ptr != NULL; res_p++) {
    printf("%s: %.0f\n", res_p->name_ptr, res_p->time);
  }
  */
  suncalc_get_position(day, lat, lng, &pos);
  report_sun_data(&pos, res);
  destroy_time_result(res);

  if (continuous) {
    sleep(5);
    /* printf("\n\n\n\n\n\n\n\n\n\n\n\n\n"); */
    system("clear");
    goto check_sun_times;
  }

  return 0;
}

