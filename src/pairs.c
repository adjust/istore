#include "istore.h"
#include "intutils.h"
#include "avl.h"

void
istore_tree_to_pairs(AvlNode *p, IStorePairs *pairs)
{
    if(p == NULL)
        return;
    istore_tree_to_pairs(p->left, pairs);
    istore_pairs_insert(pairs, p->key, DirectFunctionCall1(int84, p->value));
    istore_tree_to_pairs(p->right, pairs);
}

void
istore_pairs_init(IStorePairs *pairs, size_t initial_size)
{
    pairs->pairs   = palloc0(initial_size * sizeof(IStorePair));
    pairs->used    = 0;
    pairs->size    = initial_size;
    pairs->buflen  = 0;
}

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
