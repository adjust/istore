#ifndef ISTORECOMMON_H
#define ISTORECOMMON_H

#include "utils/memutils.h"

#define BUFLEN_OFFSET 8
#define MAX(_a, _b) ((_a > _b) ? _a : _b)
#define MIN(_a ,_b) ((_a < _b) ? _a : _b)

#define PAIRS_MAX(_pairtype) (MaxAllocSize / sizeof(_pairtype))
#define PAYLOAD_SIZE(_pairs, _pairtype) (_pairs->used * sizeof(_pairtype))
#define ISHDRSZ VARHDRSZ + sizeof(int32) + sizeof(int32)

#define ISTORE_SIZE(x, _pairtype) (ISHDRSZ + x->len * sizeof(_pairtype))
#define FIRST_PAIR(x, _pairtype) ((_pairtype*)((char*) x + ISHDRSZ))

#endif // ISTORECOMMON_H
