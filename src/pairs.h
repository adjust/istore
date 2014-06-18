#ifndef ISTORE_PAIRS_H
#define ISTORE_PAIRS_H

#include "istore.h"

struct ISPair {
    int  key;
    long val;
    int  key_len;
    int  val_len;
};

typedef struct ISPair ISPair;

struct ISPairs {
    ISPair *pairs;
    size_t  size;
    int     used;
};

typedef struct ISPairs ISPairs;

void Pairs_init(ISPairs *pairs, size_t initial_size);
void Pairs_insert(ISPairs *pairs, int key, long val, int key_len, int val_len);
int  Pairs_cmp(const void *a, const void *b);
void Pairs_sort(ISPairs *pairs);
void Pairs_debug(ISPairs *pairs);

#endif // ISTORE_PAIRS_H
