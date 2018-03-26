#include "istore.h"
#include "utils/builtins.h"

#define INITSTATESIZE 30

#define BIG_ISTORE 1
#define ISTORE 0

#define INIT_AGG_STATE(_state)                                                                 \
    do {                                                                                         \
        MemoryContext  agg_context;                                                              \
                                                                                                 \
        if (!AggCheckCallContext(fcinfo, &agg_context))                                          \
            elog(ERROR, "aggregate function called in non-aggregate context");                   \
                                                                                                 \
        if (PG_ARGISNULL(1) && PG_ARGISNULL(0)) PG_RETURN_NULL();                                \
                                                                                                 \
        _state = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);\
                                                                                                 \
        if (PG_ARGISNULL(1)) PG_RETURN_POINTER(_state);                                          \
                                                                                                 \
    } while(0)

typedef struct {
    size_t size;
    int    used;
    BigIStorePair pairs[0];
} ISAggState;

typedef enum {
    AGG_SUM,
    AGG_MIN,
    AGG_MAX
} ISAggType;

static inline ISAggState *
state_init(MemoryContext agg_context)
{
    ISAggState *state;
    state = (ISAggState *) MemoryContextAllocZero(agg_context, sizeof(ISAggState) + INITSTATESIZE * sizeof(BigIStorePair));
    state->size = INITSTATESIZE ;
    return state;
}

// Aggregate internal function for istore.
static inline ISAggState *
istore_agg_internal(ISAggState *state, IStore *istore, ISAggType type)
{
    BigIStorePair *pairs1;
    IStorePair    *pairs2;
    int            index1 = 0,
                   index2 = 0;

    pairs1 = state->pairs;
    pairs2 = FIRST_PAIR(istore, IStorePair);
    while (index1 < state->used && index2 < istore->len)
    {
        if (pairs1->key < pairs2->key)
        {
            // do nothing keep state
            ++pairs1;
            ++index1;
        }
        else if (pairs1->key > pairs2->key)
        {
            int i = 1;
            while(index2 + i < istore->len && pairs1->key > pairs2[i].key){
                ++i;
            }

            // ensure array is big enough
            if (state->size < state->used + i)
            {
                state->size  = state->size * 2 > state->used + i ? state->size * 2 : state->used + i;
                state        = repalloc(state, sizeof(ISAggState) + state->size * sizeof(BigIStorePair));
                pairs1       = state->pairs+index1;
            }

            // move data i steps forward from index1
            memmove(pairs1+i,pairs1, (state->used - index1) * sizeof(BigIStorePair));
            // copy data
            state->used += i;
            // we can't use memcpy here as pairs1 and pairs2 differ in type
            for (int j=0; j<i; j++)
            {
                pairs1->key = pairs2->key;
                pairs1->val = pairs2->val;
                ++pairs1;
                ++pairs2;
            }
            index1+=i;
            index2+=i;

        }
        else
        {
            // identical keys add values
            if (type == AGG_SUM)
            {
                /*
                * Overflow check.  If the inputs are of different signs then their sum
                * cannot overflow.  If the inputs are of the same sign, their sum had
                * better be that sign too.
                */
                if (SAMESIGN(pairs1->val, pairs2->val))
                {
                    pairs1->val += pairs2->val;
                    if(!SAMESIGN(pairs1->val, pairs2->val))
                        ereport(ERROR,
                                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
                                errmsg("bigint out of range")));
                }
                else
                {
                    pairs1->val += pairs2->val;
                }
            }
            else if (type == AGG_MIN)
            {
                pairs1->val = MIN(pairs2->val, pairs1->val);
            }
            else if (type == AGG_MAX)
            {
                pairs1->val = MAX(pairs2->val, pairs1->val);
            }

            ++index1;
            ++index2;
            ++pairs1;
            ++pairs2;
        }
    }

    // append any leftovers
    int i = istore->len - index2;
    if ( i > 0 )
    {
        if (state->size <= state->used + i)
        {
            state->size = state->size * 2 > state->used + i ? state->size * 2 : state->used + i;
            state       = repalloc(state, sizeof(ISAggState) + state->size * sizeof(BigIStorePair));
            pairs1      = state->pairs+index1;
        }
        state->used += i;
        // we can't use memcpy here as pairs1 and pairs2 differ in type
        for (int j=0; j<i; j++)
        {
            pairs1->key = pairs2->key;
            pairs1->val = pairs2->val;
            ++pairs1;
            ++pairs2;
        }
    }

    return state;
}

static inline ISAggState *
bigistore_agg_internal(ISAggState *state, BigIStore *istore, ISAggType type)
{
    BigIStorePair *pairs2;
    BigIStorePair *pairs1;
    int            index1 = 0,
                   index2 = 0;

    pairs1 = state->pairs;
    pairs2 = FIRST_PAIR(istore, BigIStorePair);
    while (index1 < state->used && index2 < istore->len)
    {
        if (pairs1->key < pairs2->key)
        {
            // do nothing keep state
            ++pairs1;
            ++index1;
        }
        else if (pairs1->key > pairs2->key)
        {
            int i = 1;
            while(index2 + i < istore->len && pairs1->key > pairs2[i].key){
                ++i;
            }

            // ensure array is big enough
            if (state->size < state->used + i)
            {
                state->size  = state->size * 2 > state->used + i ? state->size * 2 : state->used + i;
                state        = repalloc(state, sizeof(ISAggState) + state->size * sizeof(BigIStorePair));
                pairs1       = state->pairs+index1;
            }

            // move data i steps forward from index1
            memmove(pairs1+i,pairs1, (state->used - index1) * sizeof(BigIStorePair));

            // copy data
            state->used += i;
            memcpy(pairs1, pairs2, i * sizeof(BigIStorePair));
            pairs1 += i;
            pairs2 += i;
            index1 += i;
            index2 += i;

        }
        else
        {
            // identical keys - apply logic according to aggregation type
            if (type == AGG_SUM)
            {
                    /*
                    * Overflow check.  If the inputs are of different signs then their sum
                    * cannot overflow.  If the inputs are of the same sign, their sum had
                    * better be that sign too.
                    */
                    if (SAMESIGN(pairs1->val, pairs2->val))
                    {
                        pairs1->val += pairs2->val;
                        if(!SAMESIGN(pairs1->val, pairs2->val))
                            ereport(ERROR,
                                    (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
                                    errmsg("bigint out of range")));
                    }
                    else
                    {
                        pairs1->val += pairs2->val;
                    }
            }
            else if (type == AGG_MIN)
            {
                pairs1->val = MIN(pairs2->val, pairs1->val);
            }
            else if (type == AGG_MAX)
            {
                pairs1->val = MAX(pairs2->val, pairs1->val);
            }

            ++index1;
            ++index2;
            ++pairs1;
            ++pairs2;
        }
    }

    // append any leftovers
    int i = istore->len - index2;
    if ( i > 0 )
    {
        if (state->size <= state->used + i)
        {
            state->size = state->size * 2 > state->used + i ? state->size * 2 : state->used + i;
            state       = repalloc(state, sizeof(ISAggState) + state->size * sizeof(BigIStorePair));
            pairs1      = state->pairs+index1;
        }
        state->used += i;
        memcpy(pairs1,pairs2, i * sizeof(BigIStorePair));
    }

    return state;
}

/*
 * MIN(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_min_transfn);
Datum
istore_min_transfn(PG_FUNCTION_ARGS)
{
    ISAggState    *state;
    INIT_AGG_STATE(state);

    PG_RETURN_POINTER(istore_agg_internal(state, PG_GETARG_IS(1), AGG_MIN));
}

/*
 * MIN(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_min_transfn);
Datum
bigistore_min_transfn(PG_FUNCTION_ARGS)
{
    ISAggState    *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(bigistore_agg_internal(state, PG_GETARG_BIGIS(1), AGG_MIN));
}

/*
 * MAX(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_max_transfn);
Datum
istore_max_transfn(PG_FUNCTION_ARGS)
{
    ISAggState    *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(istore_agg_internal(state, PG_GETARG_IS(1), AGG_MAX));

}

/*
 * MAX(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_max_transfn);
Datum
bigistore_max_transfn(PG_FUNCTION_ARGS)
{
    ISAggState    *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(bigistore_agg_internal(state, PG_GETARG_BIGIS(1), AGG_MAX));

}

/*
 * SUM(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_sum_transfn);
Datum
istore_sum_transfn(PG_FUNCTION_ARGS)
{
    ISAggState    *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(istore_agg_internal(state, PG_GETARG_IS(1), AGG_SUM));

}

/*
 * SUM(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_sum_transfn);
Datum
bigistore_sum_transfn(PG_FUNCTION_ARGS)
{
    ISAggState    *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(bigistore_agg_internal(state, PG_GETARG_BIGIS(1), AGG_SUM));

}

/*
 * Final function for SUM(istore/bigistore) and MIN/MAX(bigistore)
 * Both SUM transition functions return the same transition type - the same as
 * MIN/MAX(bigistore).
 */
PG_FUNCTION_INFO_V1(bigistore_agg_finalfn_pairs);
Datum
bigistore_agg_finalfn_pairs(PG_FUNCTION_ARGS)
{
    ISAggState  *state;
    BigIStore   *istore;

    if (PG_ARGISNULL(0)) PG_RETURN_NULL();

    state       = (ISAggState *) PG_GETARG_POINTER(0);
    istore      = (BigIStore *)(palloc0(ISHDRSZ + state->used * sizeof(BigIStorePair)));
    istore->len = state->used;

    memcpy(FIRST_PAIR(istore, BigIStorePair), state->pairs, state->used * sizeof(BigIStorePair));
    bigistore_add_buflen(istore);

    SET_VARSIZE(istore, ISHDRSZ + state->used * sizeof(BigIStorePair));

    PG_RETURN_POINTER(istore);
}

/*
 * Final function for MIN/MAX(istore)
 */
PG_FUNCTION_INFO_V1(istore_agg_finalfn_pairs);
Datum
istore_agg_finalfn_pairs(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    IStore     *istore;

    if (PG_ARGISNULL(0)) PG_RETURN_NULL();

    state       = (ISAggState *) PG_GETARG_POINTER(0);
    istore      = (IStore *)(palloc0(ISHDRSZ + state->used * sizeof(IStorePair)));
    istore->len = state->used;

    istore_copy_and_add_buflen(istore, state->pairs);

    SET_VARSIZE(istore, ISHDRSZ + state->used * sizeof(IStorePair));

    PG_RETURN_POINTER(istore);
}


/*
 * Agg(int, bigint) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_avl_transfn);
Datum
istore_avl_transfn(PG_FUNCTION_ARGS)
{
    AvlNode         *tree;
    AvlNode         *position;
    MemoryContext    agg_context, oldcontext;
    int32            key,value, pl_result;

    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(0) && (PG_ARGISNULL(1) || PG_ARGISNULL(2)))
        PG_RETURN_NULL();

    tree  = PG_ARGISNULL(0) ? NULL : (AvlNode *) PG_GETARG_POINTER(0);

    if (PG_ARGISNULL(1) || PG_ARGISNULL(2))
        PG_RETURN_POINTER(tree);

    key         = PG_GETARG_INT32(1);
    value       = PG_GETARG_INT32(2);
    oldcontext  = MemoryContextSwitchTo(agg_context);
    position    = is_tree_find(key, tree);

    if (position == NULL)
        tree = is_tree_insert(tree, key, value);
    else
    {
        INTPL(position->value, value, pl_result);
        position->value = pl_result;
    }
    MemoryContextSwitchTo(oldcontext);
    PG_RETURN_POINTER(tree);
}

PG_FUNCTION_INFO_V1(istore_avl_finalfn);
Datum
istore_avl_finalfn(PG_FUNCTION_ARGS)
{
    AvlNode      *tree;
    IStore       *istore;
    IStorePairs  *pairs;

    if (PG_ARGISNULL(0)) PG_RETURN_NULL();

    tree  = (AvlNode *) PG_GETARG_POINTER(0);

    pairs = palloc0(sizeof *pairs);
    istore_pairs_init(pairs, 200);
    istore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_ISTORE(istore, pairs);
    PG_RETURN_POINTER(istore);
}



/*
 * Agg(int, bigint) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_avl_transfn);
Datum
bigistore_avl_transfn(PG_FUNCTION_ARGS)
{
    AvlNode         *tree;
    AvlNode         *position;
    MemoryContext    agg_context, oldcontext;
    int32            key;
    int64            value, pl_result;

    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(0) && (PG_ARGISNULL(1) || PG_ARGISNULL(2)))
        PG_RETURN_NULL();

    tree  = PG_ARGISNULL(0) ? NULL : (AvlNode *) PG_GETARG_POINTER(0);

    if (PG_ARGISNULL(1) || PG_ARGISNULL(2))
        PG_RETURN_POINTER(tree);

    key         = PG_GETARG_INT32(1);
    value       = PG_GETARG_INT64(2);
    oldcontext  = MemoryContextSwitchTo(agg_context);
    position    = is_tree_find(key, tree);

    if (position == NULL)
        tree = is_tree_insert(tree, key, value);
    else
    {
        INTPL(position->value, value, pl_result);
        position->value = pl_result;
    }
    MemoryContextSwitchTo(oldcontext);
    PG_RETURN_POINTER(tree);
}

PG_FUNCTION_INFO_V1(bigistore_avl_finalfn);
Datum
bigistore_avl_finalfn(PG_FUNCTION_ARGS)
{
    AvlNode         *tree;
    BigIStore       *istore;
    BigIStorePairs  *pairs;

    if (PG_ARGISNULL(0)) PG_RETURN_NULL();

    tree  = (AvlNode *) PG_GETARG_POINTER(0);

    pairs = palloc0(sizeof *pairs);
    bigistore_pairs_init(pairs, 200);
    bigistore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_BIGISTORE(istore, pairs);
    PG_RETURN_POINTER(istore);
}








