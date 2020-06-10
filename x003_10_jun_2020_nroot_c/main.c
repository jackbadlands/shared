/* program searches n-root for target number value.
 * only positive numbers.
 *
 * USAGE:
 * I want to find x, where x^3==8.
 * then I will run command
 * ./nroot 3 8
 * result will be printed into console's stdout.

 * LICENSE:
 * License is public domain in countries that accepts public domain license.
 * or use most permissive license in other countries (use MIT for example.
 * honestly i don't care about mention me as author).
 *
 * my position: use for whatever you want. just don't take it from other
 * people or machines. let them use it too, if they want.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define READ_ARG_D(argno, var, err_msg) \
{ \
  int err; \
  err = sscanf(argv[(argno)], " %lf ", &(var)); \
  if (err != 1) { \
    fprintf(stderr, "cannot read arg #%d: %s\n", (argno), (err_msg)); \
    exit(2); \
  } \
}

int sign_differs (double a, double b) {
  if ((a >= 0 && b < 0)
  ||  (b >= 0 && a < 0)) {
    return 1;
  } else {
    return 0;
  }
}

int main (int argc, char **argv) {
  double n, target, acceptable_bias;
  double root, step, num, prev_diff;

  /* parse args:
   * 1) power of root that we find for (n)
   * 2) target value, that:
   *    root ^ n == target
   */
  if (argc >= 3) {
    READ_ARG_D(1, n, "n");
    n = fabs(n);
    READ_ARG_D(2, target, "target");
    target = fabs(target);
  } else {
    fprintf(stderr,
        "error: not enough arguments\n"
        "usage:\n"
        "  %s <power> <target_number> [acceptable_bias]\n"
        "examples:\n"
        "  %s 3 8\n"
        "  %s 3 8 0.00001\n",
        argv[0],
        argv[0],
        argv[0]
    );
    exit(2);
  }
  /* 3) acceptable_bias, default is 0.1, optional */
  if (argc == 4) {
    READ_ARG_D(3, acceptable_bias, "acceptable_bias");
  } else {
    acceptable_bias = 0.1;
  }

  root = 10; /* some random root for beginning */
  step = root * 0.99; /* some random step */
  num = pow(root, n); /* initial num calculation */
  prev_diff = 0; /* something (don't care in beginning) */

  /* "find root" loop */
  while (fabs(num - target) > acceptable_bias) {
    double diff;
    diff = num - target;

    /* make impossible root to be less than 1 */
    while (root - step < 1) {
      step = step / 2;
    }

    /* lower step if passed through sign change */
    if (sign_differs(diff, prev_diff)) {
      step = step / 2;
    }

    /* apply step depending of lower or greater result than target value */
    if (num < target) {
      root = root + step;
    } else {
      root = root - step;
    }

    /* save diff. recalculate num with new root (that will be checked
     * in "while")
     */
    prev_diff = diff;
    num = pow(root, n);
  }

  printf("%lf\n", root);

  return 0;
}

