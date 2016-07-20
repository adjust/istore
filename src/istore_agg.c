#include "istore.h"

#define SAMESIGN(a,b)   (((a) < 0) == ((b) < 0))
#define INITSTATESIZE 30

typedef struct{
    size_t  size;
    int     used;
    BigIStorePair pairs[0];
} ISAggState;

static inline ISAggState *
state_init(MemoryContext agg_context)
{
    ISAggState    *state;
    state =  (ISAggState *) MemoryContextAllocZero(agg_context, sizeof(ISAggState) + INITSTATESIZE * sizeof(BigIStorePair));
    state->size = INITSTATESIZE ;
    return state;
}

/*
 * MIN(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_min_transfn);
Datum
istore_min_transfn(PG_FUNCTION_ARGS)
{

    MemoryContext  agg_context;
    ISAggState    *state;
    IStore        *istore;
    IStorePair    *pairs2;
    BigIStorePair *pairs1;
    int            index1 = 0,
                   index2 = 0;


    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(1) && PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);

    if (PG_ARGISNULL(1))
        PG_RETURN_POINTER(state);

    istore = PG_GETARG_IS(1);
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
            pairs1->val = MIN(pairs2->val, pairs1->val);

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

    PG_RETURN_POINTER(state);
}

/*
 * MIN(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_min_transfn);
Datum
bigistore_min_transfn(PG_FUNCTION_ARGS)
{

    MemoryContext  agg_context;
    ISAggState    *state;
    BigIStore     *istore;
    BigIStorePair *pairs1,
                  *pairs2;
    int            index1 = 0,
                   index2 = 0;


    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(1) && PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state       = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);

    if PG_ARGISNULL(1)
        PG_RETURN_POINTER(state);

    istore  = PG_GETARG_BIGIS(1);
    pairs1  = state->pairs;
    pairs2  = FIRST_PAIR(istore, BigIStorePair);
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
            memcpy(pairs1,pairs2, i * sizeof(BigIStorePair) );
            pairs1 += i;
            pairs2 += i;
            index1+=i;
            index2+=i;

        }
        else
        {
            // identical keys add values
            pairs1->val = MIN(pairs1->val, pairs2->val);

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
        memcpy(pairs1,pairs2, i * sizeof(BigIStorePair) );
    }

    PG_RETURN_POINTER(state);
}

/*
 * MAX(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_max_transfn);
Datum
istore_max_transfn(PG_FUNCTION_ARGS)
{

    MemoryContext  agg_context;
    ISAggState    *state;
    IStore        *istore;
    IStorePair    *pairs2;
    BigIStorePair *pairs1;
    int            index1 = 0,
                   index2 = 0;


    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(1) && PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);

    if (PG_ARGISNULL(1))
        PG_RETURN_POINTER(state);

    istore = PG_GETARG_IS(1);
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
            pairs1->val = MAX(pairs2->val, pairs1->val);

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

    PG_RETURN_POINTER(state);
}

/*
 * MAX(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_max_transfn);
Datum
bigistore_max_transfn(PG_FUNCTION_ARGS)
{

    MemoryContext  agg_context;
    ISAggState    *state;
    BigIStore     *istore;
    BigIStorePair *pairs1,
                  *pairs2;
    int            index1 = 0,
                   index2 = 0;


    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(1) && PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state       = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);

    if PG_ARGISNULL(1)
        PG_RETURN_POINTER(state);

    istore  = PG_GETARG_BIGIS(1);
    pairs1  = state->pairs;
    pairs2  = FIRST_PAIR(istore, BigIStorePair);
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
            memcpy(pairs1,pairs2, i * sizeof(BigIStorePair) );
            pairs1 += i;
            pairs2 += i;
            index1+=i;
            index2+=i;

        }
        else
        {
            // identical keys add values
            pairs1->val = MAX(pairs1->val, pairs2->val);

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
        memcpy(pairs1,pairs2, i * sizeof(BigIStorePair) );
    }

    PG_RETURN_POINTER(state);
}

/*
 * SUM(istore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(istore_sum_transfn);
Datum
istore_sum_transfn(PG_FUNCTION_ARGS)
{

    MemoryContext  agg_context;
    ISAggState    *state;
    IStore        *istore;
    IStorePair    *pairs2;
    BigIStorePair *pairs1;
    int            index1 = 0,
                   index2 = 0;


    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(1) && PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state       = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);

    if PG_ARGISNULL(1)
        PG_RETURN_POINTER(state);

    istore  = PG_GETARG_IS(1);
    pairs1  = state->pairs;
    pairs2  = FIRST_PAIR(istore, IStorePair);
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
            /*
             * Overflow check.  If the inputs are of different signs then their sum
             * cannot overflow.  If the inputs are of the same sign, their sum had
             * better be that sign too.
             */
            if (SAMESIGN(pairs1->val, pairs2->val)){
                pairs1->val += pairs2->val;
                if(!SAMESIGN(pairs1->val, pairs2->val))
                    ereport(ERROR,
                            (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
                            errmsg("bigint out of range")));
            }
            else
                pairs1->val += pairs2->val;


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

    PG_RETURN_POINTER(state);
}

/*
 * SUM(bigistore) aggregate funtion
 */
PG_FUNCTION_INFO_V1(bigistore_sum_transfn);
Datum
bigistore_sum_transfn(PG_FUNCTION_ARGS)
{

    MemoryContext  agg_context;
    ISAggState    *state;
    BigIStore     *istore;
    BigIStorePair *pairs1,
                  *pairs2;
    int            index1 = 0,
                   index2 = 0;


    if (!AggCheckCallContext(fcinfo, &agg_context))
        elog(ERROR, "aggregate function called in non-aggregate context");

    if (PG_ARGISNULL(1) && PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state       = PG_ARGISNULL(0) ? state_init(agg_context) : (ISAggState *) PG_GETARG_POINTER(0);

    if PG_ARGISNULL(1)
        PG_RETURN_POINTER(state);

    istore  = PG_GETARG_BIGIS(1);
    pairs1  = state->pairs;
    pairs2  = FIRST_PAIR(istore, BigIStorePair);
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
            memcpy(pairs1,pairs2, i * sizeof(BigIStorePair) );
            pairs1 += i;
            pairs2 += i;
            index1+=i;
            index2+=i;

        }
        else
        {
            // identical keys add values
            /*
             * Overflow check.  If the inputs are of different signs then their sum
             * cannot overflow.  If the inputs are of the same sign, their sum had
             * better be that sign too.
             */
            if (SAMESIGN(pairs1->val, pairs2->val)){
                pairs1->val += pairs2->val;
                if(!SAMESIGN(pairs1->val, pairs2->val))
                    ereport(ERROR,
                            (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
                            errmsg("bigint out of range")));
            }
            else
                pairs1->val += pairs2->val;

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
        memcpy(pairs1,pairs2, i * sizeof(BigIStorePair) );
    }

    PG_RETURN_POINTER(state);
}


/*
 * Final function for SUM(istore/bigistore)
 * Both transition function return the same transition type
 * and both Aggregates return bigistore so only one finalfunction
 * is needed here.
 */
PG_FUNCTION_INFO_V1(istore_agg_finalfn_pairs);
Datum
istore_agg_finalfn_pairs(PG_FUNCTION_ARGS)
{
    ISAggState  *state;
    BigIStore   *istore;

    if( PG_ARGISNULL(0))
        PG_RETURN_NULL();

    state       = (ISAggState *) PG_GETARG_POINTER(0);
    istore      = (BigIStore *)(palloc0(ISHDRSZ + state->used * sizeof(BigIStorePair)));
    istore->len = state->used;

    memcpy(FIRST_PAIR(istore, BigIStorePair), state->pairs, state->used * sizeof(BigIStorePair));
    bigistore_add_buflen(istore);

    SET_VARSIZE(istore, ISHDRSZ + state->used * sizeof(BigIStorePair));

    PG_RETURN_POINTER(istore);
}
