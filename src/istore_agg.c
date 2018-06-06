#include "istore.h"
#include "lib/stringinfo.h"
#include "libpq/pqformat.h"
#include "utils/builtins.h"

#define INITSTATESIZE 30

#define BIG_ISTORE 1
#define ISTORE 0

#define INIT_AGG_STATE(_state)                                                                                         \
    do                                                                                                                 \
    {                                                                                                                  \
        MemoryContext agg_context;                                                                                     \
                                                                                                                       \
        if (!AggCheckCallContext(fcinfo, &agg_context))                                                                \
            elog(ERROR, "aggregate function called in non-aggregate context");                                         \
                                                                                                                       \
        if (PG_ARGISNULL(1) && PG_ARGISNULL(0))                                                                        \
            PG_RETURN_NULL();                                                                                          \
                                                                                                                       \
        _state = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);                      \
                                                                                                                       \
        if (PG_ARGISNULL(1))                                                                                           \
            PG_RETURN_POINTER(_state);                                                                                 \
                                                                                                                       \
    } while (0)

typedef struct
{
    int32         size;
    int32         used;
    BigIStorePair pairs[0];
} ISAggState;

typedef enum
{
    AGG_SUM,
    AGG_MIN,
    AGG_MAX
} ISAggType;

static inline ISAggState *
state_init(MemoryContext agg_context)
{
    ISAggState *state;
    state =
      (ISAggState *) MemoryContextAllocZero(agg_context, sizeof(ISAggState) + INITSTATESIZE * sizeof(BigIStorePair));
    state->size = INITSTATESIZE;
    return state;
}

/*
 * expand state capacity to store at least n new items
 */
static inline ISAggState *
state_extend(ISAggState *state, int n)
{
    if (state->size < state->used + n)
    {
        state->size = state->size * 2 > state->used + n ? state->size * 2 : state->used + n;
        state       = repalloc(state, sizeof(ISAggState) + state->size * sizeof(BigIStorePair));
    }
    return state;
}

// Aggregate internal function for istore.
static inline ISAggState *
istore_agg_internal(ISAggState *state, IStore *istore, ISAggType type)
{
    BigIStorePair *pairs1;
    IStorePair *   pairs2;
    int            index1 = 0, index2 = 0;

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
            while (index2 + i < istore->len && pairs1->key > pairs2[i].key)
            {
                ++i;
            }

            // expand state capacity to store new items
            state  = state_extend(state, i);
            pairs1 = state->pairs + index1;

            // move data i steps forward from index1
            memmove(pairs1 + i, pairs1, (state->used - index1) * sizeof(BigIStorePair));
            // copy data
            state->used += i;
            // we can't use memcpy here as pairs1 and pairs2 differ in type
            for (int j = 0; j < i; j++)
            {
                pairs1->key = pairs2->key;
                pairs1->val = pairs2->val;
                ++pairs1;
                ++pairs2;
            }
            index1 += i;
            index2 += i;
        }
        else
        {
            // identical keys add values
            switch (type)
            {
                case AGG_SUM:
                    /*
                     * Overflow check.  If the inputs are of different signs then their sum
                     * cannot overflow.  If the inputs are of the same sign, their sum had
                     * better be that sign too.
                     */
                    if (SAMESIGN(pairs1->val, pairs2->val))
                    {
                        pairs1->val += pairs2->val;
                        if (!SAMESIGN(pairs1->val, pairs2->val))
                            ereport(ERROR,
                                    (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE), errmsg("bigint out of range")));
                    }
                    else
                    {
                        pairs1->val += pairs2->val;
                    }
                    break;
                case AGG_MIN: pairs1->val = MIN(pairs2->val, pairs1->val); break;
                case AGG_MAX: pairs1->val = MAX(pairs2->val, pairs1->val);
            }

            ++index1;
            ++index2;
            ++pairs1;
            ++pairs2;
        }
    }

    // append any leftovers
    int i = istore->len - index2;
    if (i > 0)
    {
        state = state_extend(state, i);
        state->used += i;
        pairs1 = state->pairs + index1;
        // we can't use memcpy here as pairs1 and pairs2 differ in type
        for (int j = 0; j < i; j++)
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
istore_agg_state_accum(ISAggState *state, int num_paris, BigIStorePair *pairs2, ISAggType type)
{
    BigIStorePair *pairs1;
    int            index1 = 0, index2 = 0;

    pairs1 = state->pairs;
    while (index1 < state->used && index2 < num_paris)
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
            while (index2 + i < num_paris && pairs1->key > pairs2[i].key)
            {
                ++i;
            }

            // expand state capacity to store new items
            state  = state_extend(state, i);
            pairs1 = state->pairs + index1;

            // move data i steps forward from index1
            memmove(pairs1 + i, pairs1, (state->used - index1) * sizeof(BigIStorePair));

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
            switch (type)
            {
                case AGG_SUM:
                    /*
                     * Overflow check.  If the inputs are of different signs then their sum
                     * cannot overflow.  If the inputs are of the same sign, their sum had
                     * better be that sign too.
                     */
                    if (SAMESIGN(pairs1->val, pairs2->val))
                    {
                        pairs1->val += pairs2->val;
                        if (!SAMESIGN(pairs1->val, pairs2->val))
                            ereport(ERROR,
                                    (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE), errmsg("bigint out of range")));
                    }
                    else
                    {
                        pairs1->val += pairs2->val;
                    }
                    break;
                case AGG_MIN: pairs1->val = MIN(pairs2->val, pairs1->val); break;
                case AGG_MAX: pairs1->val = MAX(pairs2->val, pairs1->val);
            }

            ++index1;
            ++index2;
            ++pairs1;
            ++pairs2;
        }
    }

    // append any leftovers
    int i = num_paris - index2;
    if (i > 0)
    {
        state = state_extend(state, i);
        state->used += i;
        pairs1 = state->pairs + index1;
        memcpy(pairs1, pairs2, i * sizeof(BigIStorePair));
    }

    return state;
}

static inline ISAggState *
bigistore_agg_internal(ISAggState *state, BigIStore *istore, ISAggType type)
{
    return istore_agg_state_accum(state, istore->len, FIRST_PAIR(istore, BigIStorePair), type);
}

/*
 * MIN(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_min_transfn);
Datum istore_min_transfn(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    INIT_AGG_STATE(state);

    PG_RETURN_POINTER(istore_agg_internal(state, PG_GETARG_IS(1), AGG_MIN));
}

/*
 * MIN(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_min_transfn);
Datum bigistore_min_transfn(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(bigistore_agg_internal(state, PG_GETARG_BIGIS(1), AGG_MIN));
}

/*
 * MAX(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_max_transfn);
Datum istore_max_transfn(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(istore_agg_internal(state, PG_GETARG_IS(1), AGG_MAX));
}

/*
 * MAX(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_max_transfn);
Datum bigistore_max_transfn(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(bigistore_agg_internal(state, PG_GETARG_BIGIS(1), AGG_MAX));
}

/*
 * SUM(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_sum_transfn);
Datum istore_sum_transfn(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(istore_agg_internal(state, PG_GETARG_IS(1), AGG_SUM));
}

/*
 * SUM(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_sum_transfn);
Datum bigistore_sum_transfn(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    INIT_AGG_STATE(state);
    PG_RETURN_POINTER(bigistore_agg_internal(state, PG_GETARG_BIGIS(1), AGG_SUM));
}

/*
 * Final function for SUM(istore/bigistore) and MIN/MAX(bigistore)
 * Both SUM transition functions return the same transition type - the same as
 * MIN/MAX(bigistore).
 */
PG_FUNCTION_INFO_V1(bigistore_agg_finalfn_pairs);
Datum bigistore_agg_finalfn_pairs(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    BigIStore * istore;

    state = (ISAggState *) PG_GETARG_POINTER(0);

    istore      = (BigIStore *) (palloc0(ISHDRSZ + state->used * sizeof(BigIStorePair)));
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
Datum istore_agg_finalfn_pairs(PG_FUNCTION_ARGS)
{
    ISAggState *state;
    IStore *    istore;

    state       = (ISAggState *) PG_GETARG_POINTER(0);
    istore      = (IStore *) (palloc0(ISHDRSZ + state->used * sizeof(IStorePair)));
    istore->len = state->used;

    istore_copy_and_add_buflen(istore, state->pairs);

    SET_VARSIZE(istore, ISHDRSZ + state->used * sizeof(IStorePair));

    PG_RETURN_POINTER(istore);
}

/*
 * Agg(int, bigint) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_avl_transfn);
Datum istore_avl_transfn(PG_FUNCTION_ARGS)
{
    AvlNode *     tree;
    AvlNode *     position;
    MemoryContext agg_context, oldcontext;
    int32         key, value, pl_result;

    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(0) && (PG_ARGISNULL(1) || PG_ARGISNULL(2)))
        PG_RETURN_NULL();

    tree = PG_ARGISNULL(0) ? NULL : (AvlNode *) PG_GETARG_POINTER(0);

    if (PG_ARGISNULL(1) || PG_ARGISNULL(2))
        PG_RETURN_POINTER(tree);

    key        = PG_GETARG_INT32(1);
    value      = PG_GETARG_INT32(2);
    oldcontext = MemoryContextSwitchTo(agg_context);
    position   = is_tree_find(key, tree);

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
Datum istore_avl_finalfn(PG_FUNCTION_ARGS)
{
    AvlNode *    tree;
    IStore *     istore;
    IStorePairs *pairs;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    tree = (AvlNode *) PG_GETARG_POINTER(0);

    pairs = palloc0(sizeof *pairs);
    istore_pairs_init(pairs, 200);
    istore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_ISTORE(istore, pairs);
    PG_RETURN_POINTER(istore);
}

/*
 * ISAGG(int, bigint) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_avl_transfn);
Datum bigistore_avl_transfn(PG_FUNCTION_ARGS)
{
    AvlNode *     tree;
    AvlNode *     position;
    MemoryContext agg_context, oldcontext;
    int32         key;
    int64         value, pl_result;

    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(0) && (PG_ARGISNULL(1) || PG_ARGISNULL(2)))
        PG_RETURN_NULL();

    tree = PG_ARGISNULL(0) ? NULL : (AvlNode *) PG_GETARG_POINTER(0);

    if (PG_ARGISNULL(1) || PG_ARGISNULL(2))
        PG_RETURN_POINTER(tree);

    key        = PG_GETARG_INT32(1);
    value      = PG_GETARG_INT64(2);
    oldcontext = MemoryContextSwitchTo(agg_context);
    position   = is_tree_find(key, tree);

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
Datum bigistore_avl_finalfn(PG_FUNCTION_ARGS)
{
    AvlNode *       tree;
    BigIStore *     istore;
    BigIStorePairs *pairs;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    tree = (AvlNode *) PG_GETARG_POINTER(0);

    pairs = palloc0(sizeof *pairs);
    bigistore_pairs_init(pairs, 200);
    bigistore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_BIGISTORE(istore, pairs);
    PG_RETURN_POINTER(istore);
}

/* parallel support functions */

// create a agg state copy in the right memory context
static inline ISAggState *
is_agg_state_copy(ISAggState *state, MemoryContext context)
{
    ISAggState *res;

    res = (ISAggState *) MemoryContextAllocZero(context, sizeof(ISAggState) + state->size * sizeof(BigIStorePair));
    res->size = state->size;
    res->used = state->used;

    memcpy(res->pairs, state->pairs, state->size * sizeof(BigIStorePair));
    return res;
}

static inline ISAggState *
istore_agg_combine(PG_FUNCTION_ARGS, ISAggType type)
{
    ISAggState *  state1, *state2;
    MemoryContext agg_context;

    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    state1 = PG_ARGISNULL(0) ? NULL : (ISAggState *) PG_GETARG_POINTER(0);
    state2 = PG_ARGISNULL(1) ? NULL : (ISAggState *) PG_GETARG_POINTER(1);

    if (state1 == NULL && state2 == NULL)
        return NULL;

    if (state2 == NULL)
        return state1;

    if (state1 == NULL)
    {
        state1 = is_agg_state_copy(state2, agg_context);

        return state1;
    }

    state1 = istore_agg_state_accum(state1, state2->used, state2->pairs, type);
    return state1;
}

PG_FUNCTION_INFO_V1(istore_agg_sum_combine);
Datum istore_agg_sum_combine(PG_FUNCTION_ARGS)
{
    ISAggState *res;

    res = istore_agg_combine(fcinfo, AGG_SUM);

    if (res == NULL)
        PG_RETURN_NULL();

    PG_RETURN_POINTER(res);
}

PG_FUNCTION_INFO_V1(istore_agg_min_combine);
Datum istore_agg_min_combine(PG_FUNCTION_ARGS)
{
    ISAggState *res;

    res = istore_agg_combine(fcinfo, AGG_MIN);

    if (res == NULL)
        PG_RETURN_NULL();

    PG_RETURN_POINTER(res);
}

PG_FUNCTION_INFO_V1(istore_agg_max_combine);
Datum istore_agg_max_combine(PG_FUNCTION_ARGS)
{
    ISAggState *res;

    res = istore_agg_combine(fcinfo, AGG_MAX);

    if (res == NULL)
        PG_RETURN_NULL();

    PG_RETURN_POINTER(res);
}

/*
 * Serialize the internal aggregation state ISAggState into bytea.
 */
PG_FUNCTION_INFO_V1(istore_agg_serial);
Datum istore_agg_serial(PG_FUNCTION_ARGS)
{

    ISAggState *   state;
    StringInfoData buf;

    if (!AggCheckCallContext(fcinfo, NULL))
        elog(ERROR, "aggregate serialization function called in non-aggregate context");

    state = (ISAggState *) PG_GETARG_POINTER(0);

    pq_begintypsend(&buf);
    pq_sendint(&buf, state->used, sizeof(int32));
    pq_sendbytes(&buf, (char *) state->pairs, state->used * sizeof(BigIStorePair));

    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}

/*
 * Deserialize bytea into the internal aggregation state ISAggState.
 */
PG_FUNCTION_INFO_V1(istore_agg_deserial);
Datum istore_agg_deserial(PG_FUNCTION_ARGS)
{
    bytea *        sstate;
    ISAggState *   state;
    int            used;
    StringInfoData buf;

    if (!AggCheckCallContext(fcinfo, NULL))
        elog(ERROR, "aggregate deserialization function called in non-aggregate context");

    sstate = PG_GETARG_BYTEA_PP(0);
    initStringInfo(&buf);
    appendBinaryStringInfo(&buf, VARDATA_ANY(sstate), VARSIZE_ANY_EXHDR(sstate));

    used = pq_getmsgint(&buf, sizeof(int32));

    state       = (ISAggState *) palloc0(sizeof(ISAggState) + used * sizeof(BigIStorePair));
    state->size = used;
    state->used = used;
    pq_copymsgbytes(&buf, (char *) state->pairs, used * sizeof(BigIStorePair));

    PG_RETURN_POINTER(state);
}