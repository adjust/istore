#ifndef ISTORE_PAIRS_H
#define ISTORE_PAIRS_H

#include "istore.h"

struct ISPair {
    long  key;
    long val;
    int  keylen;
    int  vallen;
};

typedef struct ISPair ISPair;

struct ISPairs {
    ISPair *pairs;
    size_t  size;
    int     used;
    int     buflen;
};

typedef struct ISPairs ISPairs;

void Pairs_init(ISPairs *pairs, size_t initial_size);
void Pairs_insert(ISPairs *pairs, long key, long val);
int  Pairs_cmp(const void *a, const void *b);
void Pairs_sort(ISPairs *pairs);
void Pairs_debug(ISPairs *pairs);

#endif // ISTORE_PAIRS_H
