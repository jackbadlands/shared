#ifndef DBGPRINTS_H
#define DBGPRINTS_H

#define PC(comment) (fprintf(stderr, "***%s: line %d: %s\n", __FILE__, \
    __LINE__, (comment)))

#define P() (fprintf(stderr, "***%s: line %d passed\n", __FILE__, \
    __LINE__))

#define PF(fmt, ...) \
    fprintf(stderr, "***%s: line %d: " fmt, \
      __FILE__, __LINE__, ##__VA_ARGS__)

#endif /* #ifndef DBGPRINTS_H */

