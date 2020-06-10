#include <stdlib.h>

/* Functions behaves as standard malloc.h functions,
 * except one: They aborts program if memory not allocated */
void *pmalloc(size_t size);
void *pcalloc(size_t nobj, size_t size);
void *prealloc(void *p, size_t size);
void pfree(void *p);

