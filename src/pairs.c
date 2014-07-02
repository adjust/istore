#include "pairs.h"

void
Pairs_init(ISPairs *pairs, size_t initial_size)
{
    pairs->pairs = palloc(initial_size * sizeof(ISPair));
    pairs->used  = 0;
    pairs->size  = initial_size;
}

void
Pairs_insert(ISPairs *pairs, int key, long val, int key_len, int val_len)
{
    if (pairs->size == pairs->used) {
        /* TODO: palloc0! */
        pairs->size *= 2;
        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(ISPair));
    }
    pairs->pairs[pairs->used].key = key;
    pairs->pairs[pairs->used].val = val;
    pairs->pairs[pairs->used].key_len = key_len;
    pairs->pairs[pairs->used++].val_len = val_len;
}

int
Pairs_cmp(const void *a, const void *b)
{
    ISPair *_a = (ISPair *)a;
    ISPair *_b = (ISPair *)b;
    if (_a->key < _b->key)
        return -1;
    else if (_a->key > _b->key)
        return 1;
    else
        return 0;
}

void inline
Pairs_sort(ISPairs *pairs)
{
    qsort(pairs->pairs, pairs->used, sizeof(ISPair), Pairs_cmp);
}

void
Pairs_debug(ISPairs *pairs)
{
    int i;
    for (i = 0; i < pairs->used; ++i)
    {
        elog(INFO, "key: %ld, val: %ld", pairs->pairs[i].key, pairs->pairs[i].val);
    }
}
