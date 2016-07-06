#include "istore.h"

typedef struct{
    size_t  size;
    int     used;
    BigIStorePair pairs[0];
} ISAggState;


PG_FUNCTION_INFO_V1(istore_sum_transfn);
Datum
istore_sum_transfn(PG_FUNCTION_ARGS)
{
    
    MemoryContext  agg_context,
                   old_context;
    ISAggState       *state;
    IStore        *istore;
    IStorePair    *pairs2;
    BigIStorePair *pairs1;
    int            index1 = 0,
                   index2 = 0;
    

    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    
    state       = PG_ARGISNULL(0) ? NULL : (ISAggState *) PG_GETARG_POINTER(0);

    if (PG_ARGISNULL(1) && state == NULL)
        PG_RETURN_NULL();

    if (state == NULL)
        state =  (ISAggState *) MemoryContextAllocZero(agg_context, sizeof(ISAggState) + 10 * sizeof(BigIStorePair));
    
    if PG_ARGISNULL(1)
        PG_RETURN_POINTER(state);
        
    istore  = PG_GETARG_IS(1);
    pairs1  = state->pairs;
    pairs2  = FIRST_PAIR(istore, IStorePair);
    while (index1 < state->used && index2 < istore->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            // do nothing keep state
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            int i = 1;
            while(index2 + i < istore->len && pairs1[index1].key > pairs2[index2 + i].key){
                ++i;
            }

            // ensure array is big enough
            if (state->size < state->used + i)
            {
                state->size  = state->size * 2 > state->used + i ? state->size * 2 : state->used + i;
                state        = repalloc(state, sizeof(ISAggState) + state->size * sizeof(BigIStorePair));
                pairs1       = state->pairs;
            }

            // move data i steps forward from index1 
            memmove(pairs1+index1+i,pairs1+index1, (state->used - index1) * sizeof(BigIStorePair));
            // copy data 
            state->used += i;
            // memcpy(pairs1+index1,pairs2+index2, i * sizeof(IStorePair) );
            for (int j=0; j<i; j++)
            {
                pairs1[index1].key = pairs2[index2].key;
                pairs1[index1].val = pairs2[index2].val;
                index1++;
                index2++;                    
            }

        }
        else
        {
            // identity add
            pairs1[index1].val += pairs2[index2].val;
                    
            ++index1;
            ++index2;
        }
    }

    // append any leftovers
    int left = istore->len - index2;
    if ( left > 0 )
    {
        if (state->size <= state->used + left)
        {
            old_context = MemoryContextSwitchTo(agg_context);
            state->size = state->size * 2 > state->used + left ? state->size * 2 : state->used + left;   
            state       = repalloc(state, sizeof(ISAggState) + state->size * sizeof(IStorePair));
            pairs1      = state->pairs;
            MemoryContextSwitchTo(old_context);
        }
        state->used += left;
        // memcpy(pairs1+index1,pairs2+index2, left * sizeof(IStorePair) );
        for (int j=0; j<left; j++)
        {
            pairs1[index1].key = pairs2[index2].key;
            pairs1[index1].val = pairs2[index2].val;
            index1++;
            index2++;                    
        }
    }


    PG_RETURN_POINTER(state);
}

PG_FUNCTION_INFO_V1(istore_sum_finalfn);
Datum
istore_sum_finalfn(PG_FUNCTION_ARGS)
{
    ISAggState  *state;
    IStore      *istore;

    if( PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state       = (ISAggState *) PG_GETARG_POINTER(0);
    istore      = (IStore *)(palloc0(ISHDRSZ + state->used * sizeof(BigIStorePair)));
    istore->len = state->used;
    
    memcpy(FIRST_PAIR(istore, BigIStorePair), state->pairs, state->used * sizeof(BigIStorePair));
    istore_add_buflen(istore);  
       
    SET_VARSIZE(istore, ISHDRSZ + state->used * sizeof(BigIStorePair));

    PG_RETURN_POINTER(istore);
}
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