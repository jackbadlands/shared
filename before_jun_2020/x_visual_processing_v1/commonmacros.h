#ifndef COMMONMACROS_H
#define COMMONMACROS_H

#define STRINGIZE(x) STRINGIZE2(x)
#define STRINGIZE2(x) #x
#define NIMPLEMENTED crash("not implemented " __FILE__ STRINGIZE(__LINE__))

#define XYOFST3(x, y, w) ((y) * (w) * 3 + (x) * 3)

#define R(pxs, x, y, w) (pxs)[XYOFST3(x, y, w) + 0]

#define G(pxs, x, y, w) (pxs)[XYOFST3(x, y, w) + 1]

#define B(pxs, x, y, w) (pxs)[XYOFST3(x, y, w) + 2]

#define GRAY(pxs, x, y, w) \
(                          \
	(                        \
		R(pxs, x, y, w) +      \
		G(pxs, x, y, w) +      \
		B(pxs, x, y, w)        \
	) / 3                    \
)

#define DCOLOR(r1, r2) ( \
  (unsigned char)(r1) > (unsigned char)(r2) ? \
  (unsigned char)(r1) - (unsigned char)(r2) : \
  (unsigned char)(r2) - (unsigned char)(r1))

#endif /* COMMONMACROS_H */

