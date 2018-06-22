#include "avl.h"
#include "istore.h"
#include <limits.h>
#include <math.h>

static inline int digits32(int32 num);
static inline int digits64(int64 num);

int
is_pair_buf_len(IStorePair *pair)
{
    return (digits32(pair->key) + digits32(pair->val) + BUFLEN_OFFSET);
}

int
bigis_pair_buf_len(BigIStorePair *pair)
{
    return (digits32(pair->key) + digits64(pair->val) + BUFLEN_OFFSET);
}

/*
 * copy *src_pairs to the IStorePair of *istore and add buflen to *istore
 */
void
istore_copy_and_add_buflen(IStore *istore, BigIStorePair *src_pairs)
{
    IStorePair *dest_pairs = FIRST_PAIR(istore, IStorePair);

    for (int i = 0; i < istore->len; ++i)
    {
        dest_pairs[i].key = src_pairs[i].key;
        dest_pairs[i].val = src_pairs[i].val;
        istore->buflen += digits32(dest_pairs[i].key) + digits32(dest_pairs[i].val) + BUFLEN_OFFSET;
    }

    if (istore->buflen < 0)
        elog(ERROR, "istore buffer overflow");
}

/*
 * add buflen to bigistore
 */
void
bigistore_add_buflen(BigIStore *istore)
{
    BigIStorePair *pairs;

    pairs = FIRST_PAIR(istore, BigIStorePair);

    for (int i = 0; i < istore->len; i++)
        istore->buflen += digits32(pairs[i].key) + digits64(pairs[i].val) + BUFLEN_OFFSET;

    if (istore->buflen < 0)
        elog(ERROR, "istore buffer overflow");
}

/*
 * adds a key/ value pair for each subnode to IStorePairs
 * due to the nature of the AVL tree the pairs will be ordered by key
 */
void
istore_tree_to_pairs(AvlNode *p, IStorePairs *pairs)
{
    if (p == NULL)
        return;
    istore_tree_to_pairs(p->left, pairs);
    istore_pairs_insert(pairs, p->key, DirectFunctionCall1(int84, p->value));
    istore_tree_to_pairs(p->right, pairs);
}

/*
 * initialize IStorePairs
 */
void
istore_pairs_init(IStorePairs *pairs, size_t initial_size)
{
    pairs->pairs  = palloc0(initial_size * sizeof(IStorePair));
    pairs->used   = 0;
    pairs->size   = initial_size;
    pairs->buflen = 0;
}

/*
 * insert key value to IStorePairs
 */
void
istore_pairs_insert(IStorePairs *pairs, int32 key, int32 val)
{
    if (pairs->size == pairs->used)
    {
        if (pairs->used == PAIRS_MAX(IStorePair))
            elog(ERROR, "istore can't have more than %lu keys", PAIRS_MAX(IStorePair));

        pairs->size *= 2;
        // overflow check pairs->size should have been grown but not exceed PAIRS_MAX(IStorePair)
        if (pairs->size < pairs->used || pairs->size > PAIRS_MAX(IStorePair))
            pairs->size = PAIRS_MAX(IStorePair);

        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(IStorePair));
    }

    pairs->pairs[pairs->used].key = key;
    pairs->pairs[pairs->used].val = val;
    pairs->buflen += digits32(key) + digits32(val) + BUFLEN_OFFSET;

    if (pairs->buflen < 0)
        elog(ERROR, "istore buffer overflow");
    pairs->used++;
}

/*
 * adds a key/ value pair for each subnode to BigIStorePairs
 * due to the nature of the AVL tree the pairs will be ordered by key
 */
void
bigistore_tree_to_pairs(AvlNode *p, BigIStorePairs *pairs)
{
    if (p == NULL)
        return;
    bigistore_tree_to_pairs(p->left, pairs);
    bigistore_pairs_insert(pairs, p->key, p->value);
    bigistore_tree_to_pairs(p->right, pairs);
}

/*
 * initialize BigIStorePairs
 */
void
bigistore_pairs_init(BigIStorePairs *pairs, size_t initial_size)
{
    pairs->pairs  = palloc0(initial_size * sizeof(BigIStorePair));
    pairs->used   = 0;
    pairs->size   = initial_size;
    pairs->buflen = 0;
}

/*
 * insert key value to BigIStorePairs
 */
void
bigistore_pairs_insert(BigIStorePairs *pairs, int32 key, int64 val)
{
    if (pairs->size == pairs->used)
    {
        if (pairs->used == PAIRS_MAX(BigIStorePair))
            elog(ERROR, "bigistore can't have more than %lu keys", PAIRS_MAX(BigIStorePair));

        pairs->size *= 2;
        // overflow check pairs->size should have been grown but not exceed PAIRS_MAX(BigIStorePair)
        if (pairs->size < pairs->used || pairs->size > PAIRS_MAX(BigIStorePair))
            pairs->size = PAIRS_MAX(BigIStorePair);

        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(BigIStorePair));
    }

    pairs->pairs[pairs->used].key = key;
    pairs->pairs[pairs->used].val = val;
    pairs->buflen += digits64(key) + digits64(val) + BUFLEN_OFFSET;

    if (pairs->buflen < 0)
        elog(ERROR, "bigistore buffer overflow");
    pairs->used++;
}

/*
 * return the number of digits
 *
 * See: https://math.stackexchange.com/questions/231742
 */
static inline int
digits32(int32 num)
{
    int digits = 1;

    if (num == 0)
        return 1;
    if (num < 0)
    {
        if (num == INT_MIN)
            // special case for -2^31 because 2^31 can't fit in a two's complement 32-bit integer
            return 11;
        digits++;
        num = -num;
    }

    digits += floor(log10(num));
    return digits;
}

static inline int
digits64(int64 num)
{
    int digits = 1;

    if (num == 0)
        return 1;
    if (num < 0)
    {
        if (num == LLONG_MIN)
            // special case for -2^63 because 2^63 can't fit in a two's complement 64-bit integer
            return 20;
        digits++;
        num = -num;
    }

    digits += floor(log10(num));
    return digits;
}
