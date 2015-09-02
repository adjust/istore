#include "bigistore.h"
#include "intutils.h"
#include "avl.h"
#include "utils/memutils.h"

int
bigistore_tree_to_pairs(AvlNode *p, BigIStorePairs *pairs, int n)
{
    if(p == NULL)
        return n;
    n = bigistore_tree_to_pairs(p->left, pairs, n);

    bigistore_pairs_insert(pairs, p->key, p->value);
    ++n;
    n = bigistore_tree_to_pairs(p->right, pairs, n);
    return n;
}

void
bigistore_pairs_init(BigIStorePairs *pairs, size_t initial_size)
{
    pairs->pairs   = palloc0(initial_size * sizeof(BigIStorePair));
    pairs->used    = 0;
    pairs->size    = initial_size;
    pairs->buflen  = 0;
}

void
bigistore_pairs_insert(BigIStorePairs *pairs, int32 key, int64 val)
{
    if (pairs->size == pairs->used) {
        if (pairs->used == PAIRS_MAX(BigIStorePair))
            elog(ERROR, "bigistore can't have more than %lu keys", PAIRS_MAX(BigIStorePair));

        pairs->size *= 2;
        // overflow check pairs->size should have been grown but not exceed PAIRS_MAX(BigIStorePair)
        if (pairs->size < pairs->used || pairs->size > PAIRS_MAX(BigIStorePair))
            pairs->size = PAIRS_MAX(BigIStorePair);

        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(BigIStorePair));
    }

    pairs->pairs[pairs->used].key  = key;
    pairs->pairs[pairs->used].val  = val;
    pairs->buflen += digits64(key) + digits64(val) + BUFLEN_OFFSET;

    if (pairs->buflen < 0)
        elog(ERROR, "bigistore buffer overflow");
    pairs->used++;
}

int
bigistore_pairs_cmp(const void *a, const void *b)
{
    BigIStorePair *_a = (BigIStorePair *)a;
    BigIStorePair *_b = (BigIStorePair *)b;

    if (_a->key < _b->key)
        return -1;
    else if (_a->key > _b->key)
        return 1;
    else
        return 0;
}