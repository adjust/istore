#include "istore.h"
#include "avl.h"
#include <limits.h>

static inline int digits32(int32 num);
static inline int digits64(int64 num);

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
    BigIStorePair  *pairs;

    pairs  = FIRST_PAIR(istore, BigIStorePair);

    for(int i = 0; i < istore->len; i++)
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
    if(p == NULL)
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
    pairs->pairs   = palloc0(initial_size * sizeof(IStorePair));
    pairs->used    = 0;
    pairs->size    = initial_size;
    pairs->buflen  = 0;
}

/*
 * insert key value to IStorePairs
 */
void
istore_pairs_insert(IStorePairs *pairs, int32 key, int32 val)
{
    if (pairs->size == pairs->used) {
        if (pairs->used == PAIRS_MAX(IStorePair))
            elog(ERROR, "istore can't have more than %lu keys", PAIRS_MAX(IStorePair));

        pairs->size *= 2;
        // overflow check pairs->size should have been grown but not exceed PAIRS_MAX(IStorePair)
        if (pairs->size < pairs->used || pairs->size > PAIRS_MAX(IStorePair))
            pairs->size = PAIRS_MAX(IStorePair);

        pairs->pairs = repalloc(pairs->pairs, pairs->size * sizeof(IStorePair));
    }

    pairs->pairs[pairs->used].key  = key;
    pairs->pairs[pairs->used].val  = val;
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
    if(p == NULL)
        return ;
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
    pairs->pairs   = palloc0(initial_size * sizeof(BigIStorePair));
    pairs->used    = 0;
    pairs->size    = initial_size;
    pairs->buflen  = 0;
}



/*
 * insert key value to BigIStorePairs
 */
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

/*
 * return the number of digits
 */
static inline int
digits32(int32 num)
{
    int sign = 0;
    if (num < 0)
    {
        if (num == INT_MIN)
            // special case for -2^31 because 2^31 can't fit in a two's complement 32-bit integer
            return 12;
        sign = 1;
        num = -num;
    }

    if (num < 1e5)
    {
        if (num < 1e3)
        {
            if (num < 10)
                return 1 + sign;
            else if (num < 1e2)
                return 2 + sign;
            else
                return 3 + sign;
        }
        else
        {
            if (num < 1e4)
                return 4 + sign;
            else
                return 5 + sign;
        }
    }
    else
    {
        if (num < 1e7)
        {
            if (num < 1e6)
                return 6 + sign;
            else
                return 7 + sign;
        }
        else
        {
            if (num < 1e8)
                return 8 + sign;
            else if (num < 1e9)
                return 9 + sign;
            else
                return 10 + sign;
        }
    }
}

/*
 * return the number of digits
 */
static inline int
digits64(int64 num)
{
    int sign = 0;
    if (num < 0)
    {
        if (num == LLONG_MIN)
            // special case for -2^63 because 2^63 can't fit in a two's complement 64-bit integer
            return 19;
        sign = 1;
        num = -num;
    }

    if (num < 1e10)
    {
        if (num < 1e5)
        {
            if (num < 1e3)
            {
                if (num < 10)
                    return 1 + sign;
                else if (num < 1e2)
                    return 2 + sign;
                else
                    return 3 + sign;
            }
            else
            {
                if (num < 1e4)
                    return 4 + sign;
                else
                    return 5 + sign;
            }
        }
        else
        {
            if (num < 1e7)
            {
                if (num < 1e6)
                    return 6 + sign;
                else
                    return 7 + sign;
            }
            else
            {
                if (num < 1e8)
                    return 8 + sign;
                else if (num < 1e9)
                    return 9 + sign;
                else
                    return 10 + sign;
            }
        }
    }
    else
    {
        if (num < 1e15)
        {
            if (num < 1e12)
            {
                if (num < 1e11)
                    return 11 + sign;
                else
                    return 12 + sign;
            }
            else
            {
                if (num < 1e13)
                    return 13 + sign;
                else if (num < 1e14)
                    return 14 + sign;
                else
                    return 15 + sign;
            }
        }
        else
        {
            if (num < 1e17)
            {
                if (num < 1e16)
                    return 16 + sign;
                else
                    return 17 + sign;
            }
            else
            {
                if (num < 1e18)
                    return 18 + sign;
                else
                    return 19 + sign;
            }
        }
    }
}
