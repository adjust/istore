#include "istore.h"
#include "istore.h"

/*
 * summarize an array of istores
 */
Datum
istore_array_sum(Datum *data, int count, bool *nulls)
{
    BigIStore       *out;
    IStore          *istore;
    AvlNode         *tree;
    IStorePair      *payload;
    BigIStorePairs  *pairs;
    AvlNode         *position;
    int              i,
                     n,
                     index;


    tree = NULL;
    n    = 0;

    for (i = 0; i < count; ++i)
    {
        if (nulls[i])
            continue;

        istore = (IStore *) data[i];
        payload = FIRST_PAIR(istore, IStorePair);
        for (index = 0; index < istore->len; ++index)
        {
            position = is_tree_find(payload[index].key, tree);
            if (position == NULL)
            {
                tree = is_tree_insert(tree, payload[index].key, payload[index].val);
                ++n;
            }
            else{
                position->value += payload[index].val;
            }
        }
    }

    if (n == 0)
        return 0;
    pairs = palloc0(sizeof *pairs);
    bigistore_pairs_init(pairs, n);
    bigistore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_BIGISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}

/*
 * summarize an array of bigistores
 */
Datum
bigistore_array_sum(Datum *data, int count, bool *nulls)
{
    BigIStore       *out;
    BigIStore       *istore;
    AvlNode         *tree;
    BigIStorePair   *payload;
    BigIStorePairs  *pairs;
    AvlNode         *position;
    int              i,
                     n,
                     index;


    tree = NULL;
    n    = 0;

    for (i = 0; i < count; ++i)
    {
        if (nulls[i])
            continue;

        istore = (BigIStore *) data[i];
        payload = FIRST_PAIR(istore, BigIStorePair);
        for (index = 0; index < istore->len; ++index)
        {
            position = is_tree_find(payload[index].key, tree);
            if (position == NULL)
            {
                tree = is_tree_insert(tree, payload[index].key, payload[index].val);
                ++n;
            }
            else{
                position->value = DirectFunctionCall2(int8pl, position->value, payload[index].val);
            }
        }
    }

    if (n == 0)
        return 0;
    pairs = palloc0(sizeof *pairs);
    bigistore_pairs_init(pairs, n);
    bigistore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_BIGISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}