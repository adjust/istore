#include "bigistore.h"
#include "funcapi.h"
#include "intutils.h"

/*
 * Sum the values of an bigistore
 */
PG_FUNCTION_INFO_V1(bigistore_sum_up);
Datum
bigistore_sum_up(PG_FUNCTION_ARGS)
{
    BigIStore      *is;
    BigIStorePair  *pairs;
    is              = PG_GETARG_BIGIS(0);
    pairs           = FIRST_PAIR(is, BigIStorePair);
    int64    result = 0;
    int      index  = 0;

    while (index < is->len){
        result = int32add(result, pairs[index++].val);
    }
    PG_RETURN_INT64(result);
}

/*
 * Find a key in an bigistore
 *
 * Binary search the key in the bigistore.
 */
BigIStorePair*
bigistore_find(BigIStore *is, int32 key)
{
    BigIStorePair *pairs  = FIRST_PAIR(is, BigIStorePair);
    BigIStorePair *result = NULL;
    int low        = 0;
    int max        = is->len;
    int mid        = 0;
    while (low < max)
    {
        mid = low + (max - low) / 2;
        if (key < pairs[mid].key)
            max = mid;
        else if (key > pairs[mid].key)
            low = mid + 1;
        else
        {
            result = FIRST_PAIR(is, BigIStorePair) + mid;
            break;
        }
    }
    return result;
}

/*
 * Implementation of operator ?(bigistore, int)
 */
PG_FUNCTION_INFO_V1(bigistore_exist);
Datum
bigistore_exist(PG_FUNCTION_ARGS)
{
    bool found;
    BigIStore *in = PG_GETARG_BIGIS(0);
    int32 key  = PG_GETARG_INT32(1);
    if (bigistore_find(in, key))
        found = true;
    else
        found = false;
    PG_RETURN_BOOL(found);
}

/*
 * Implementation of operator ->(bigistore, int)
 */
PG_FUNCTION_INFO_V1(bigistore_fetchval);
Datum
bigistore_fetchval(PG_FUNCTION_ARGS)
{
    BigIStorePair *pair;
    BigIStore *in = PG_GETARG_BIGIS(0);
    int32 key  = PG_GETARG_INT32(1);
    if ((pair = bigistore_find(in, key)) == NULL )
        PG_RETURN_NULL();
    else
        PG_RETURN_INT64(pair->val);
}

/*
 * Merge two bigistores
 */
PG_FUNCTION_INFO_V1(bigistore_add);
Datum
bigistore_add(PG_FUNCTION_ARGS)
{
    BigIStore      *is1,
                   *is2,
                   *result;
    BigIStorePair  *pairs1,
                   *pairs2;
    BigIStorePairs *creator = NULL;
    int     index1          = 0,
            index2          = 0;

    is1     = PG_GETARG_BIGIS(0);
    is2     = PG_GETARG_BIGIS(1);
    pairs1  = FIRST_PAIR(is1, BigIStorePair);
    pairs2  = FIRST_PAIR(is2, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, MIN(is1->len + is2->len, 200));

    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
            ++index2;
        }
        else
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, int32add(pairs1[index1].val, pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    FILLREMAINING(creator, index1, is1, pairs1, index2, is2, pairs2, BIGISINSERTFUNC)
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Increment values of an bigistore
 */
PG_FUNCTION_INFO_V1(bigistore_add_integer);
Datum
bigistore_add_integer(PG_FUNCTION_ARGS)
{
    BigIStore  *is,
            *result;
    BigIStorePair  *pairs;
    BigIStorePairs *creator = NULL;
    int     index    = 0,
            int_arg;

    is      = PG_GETARG_BIGIS(0);
    int_arg = PG_GETARG_INT32(1);
    pairs   = FIRST_PAIR(is, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, is->len);
    while (index < is->len)
    {
        bigistore_pairs_insert(creator, pairs[index].key, int32add(pairs[index].val, int_arg));
        ++index;
    }
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Merge two bigistores by subtracting
 *
 * XXX Keys which doesn't exists on first bigistore is added to the results
 * without changing the values on the second bigistore.
 */
PG_FUNCTION_INFO_V1(bigistore_subtract);
Datum
bigistore_subtract(PG_FUNCTION_ARGS)
{
    BigIStore      *is1,
                *is2,
                *result;
    BigIStorePair  *pairs1,
                *pairs2;
    BigIStorePairs *creator = NULL;
    int     index1       = 0,
            index2       = 0;

    is1     = PG_GETARG_BIGIS(0);
    is2     = PG_GETARG_BIGIS(1);
    pairs1  = FIRST_PAIR(is1, BigIStorePair);
    pairs2  = FIRST_PAIR(is2, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, MIN(is1->len + is2->len, 200));

    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs2[index2].key, -pairs2[index2].val);
            ++index2;
        }
        else
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, int32sub(pairs1[index1].val, pairs2[index2].val ));
            ++index1;
            ++index2;
        }
    }

    FILLREMAINING(creator, index1, is1, pairs1, index2, is2, pairs2, BIGISINSERTFUNC)
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Decrement values of an bigistore
 */
PG_FUNCTION_INFO_V1(bigistore_subtract_integer);
Datum
bigistore_subtract_integer(PG_FUNCTION_ARGS)
{
    BigIStore  *is,
            *result;
    BigIStorePair  *pairs;
    BigIStorePairs *creator = NULL;

    int     index = 0,
            int_arg;

    is      = PG_GETARG_BIGIS(0);
    int_arg = PG_GETARG_INT32(1);
    pairs   = FIRST_PAIR(is, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, is->len);

    while (index < is->len)
    {
        bigistore_pairs_insert(creator, pairs[index].key, int32sub(pairs[index].val, int_arg));
        ++index;
    }
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Multiply values of two bigistores
 *
 * The two bigistores should have the same keys.  The keys which exist on only
 * one bigistore are omitted.
 */
PG_FUNCTION_INFO_V1(bigistore_multiply);
Datum
bigistore_multiply(PG_FUNCTION_ARGS)
{
    BigIStore  *is1,
            *is2,
            *result;
    BigIStorePair  *pairs1,
            *pairs2;
    BigIStorePairs *creator = NULL;
    int     index1   = 0,
            index2   = 0;

    is1     = PG_GETARG_BIGIS(0);
    is2     = PG_GETARG_BIGIS(1);
    pairs1  = FIRST_PAIR(is1, BigIStorePair);
    pairs2  = FIRST_PAIR(is2, BigIStorePair);
    creator = palloc0(sizeof *creator);
    bigistore_pairs_init(creator, MIN(is1->len, is2->len));

    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
            ++index1;
        else if (pairs1[index1].key > pairs2[index2].key)
            ++index2;
        else
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, int32mul(pairs1[index1].val, pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Multiply values of an bigistore
 */
PG_FUNCTION_INFO_V1(bigistore_multiply_integer);
Datum
bigistore_multiply_integer(PG_FUNCTION_ARGS)
{
    BigIStore  *is,
            *result;
    BigIStorePair  *pairs;
    BigIStorePairs *creator = NULL;
    int     index    = 0,
            int_arg;

    is      = PG_GETARG_BIGIS(0);
    int_arg = PG_GETARG_INT32(1);
    pairs   = FIRST_PAIR(is, BigIStorePair);
    creator = palloc0(sizeof *creator);
    bigistore_pairs_init(creator, is->len);

    while (index < is->len)
    {
        bigistore_pairs_insert(creator, pairs[index].key, int32mul(pairs[index].val, int_arg));
        ++index;
    }
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Divide values of two bigistores
 *
 * XXX The values of the result are truncated.
 *
 * XXX The two bigistores should have the same keys.  The keys which exist on only
 * one bigistore is added to the result with NULL values.
 */
PG_FUNCTION_INFO_V1(bigistore_divide);
Datum
bigistore_divide(PG_FUNCTION_ARGS)
{
    BigIStore  *is1,
            *is2,
            *result;
    BigIStorePair  *pairs1,
            *pairs2;
    BigIStorePairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;

    is1     = PG_GETARG_BIGIS(0);
    is2     = PG_GETARG_BIGIS(1);
    pairs1  = FIRST_PAIR(is1, BigIStorePair);
    pairs2  = FIRST_PAIR(is2, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, MIN(is1->len, is2->len));

    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
            ++index1;
        else if (pairs1[index1].key > pairs2[index2].key)
            ++index2;
        else
        {
            if (pairs1[index1].val != 0 && pairs2[index2].val == 0)
                ereport(ERROR, (
                    errcode(ERRCODE_DIVISION_BY_ZERO),
                    errmsg("division by zero"),
                    errdetail("Key \"%d\" of right argument has value 0", pairs2[index2].key)
                ));
            bigistore_pairs_insert(creator, pairs1[index1].key, int32div(pairs1[index1].val, pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Divide values of an bigistore
 *
 * XXX The values of the result are truncated.
 */
PG_FUNCTION_INFO_V1(bigistore_divide_integer);
Datum
bigistore_divide_integer(PG_FUNCTION_ARGS)
{
    BigIStore  *is,
            *result;
    BigIStorePair  *pairs;
    BigIStorePairs *creator = NULL;
    int     int_arg,
            index    = 0;

    is      = PG_GETARG_BIGIS(0);
    int_arg = PG_GETARG_INT32(1);

    if (int_arg == 0)
        ereport(ERROR, (
            errcode(ERRCODE_DIVISION_BY_ZERO),
            errmsg("division by zero")
        ));

    pairs   = FIRST_PAIR(is, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, is->len);
    while (index < is->len)
    {
        bigistore_pairs_insert(creator, pairs[index].key, int32div(pairs[index].val, int_arg));
        ++index;
    }
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(bigistore_from_array);
Datum
bigistore_from_array(PG_FUNCTION_ARGS)
{
    BigIStore      *result;
    Datum          *i_data;
    bool           *nulls;
    int             n,
                    s = 0;
    int16           i_typlen;
    bool            i_typbyval;
    char            i_typalign;
    Oid             i_eltype;
    AvlNode      *tree;
    BigIStorePairs *pairs;
    AvlNode     *position;
    int             key,
                    i;

    ArrayType *input = PG_GETARG_ARRAYTYPE_P(0);
    if (input == NULL)
        PG_RETURN_NULL();

    i_eltype = ARR_ELEMTYPE(input);

    get_typlenbyvalalign(
            i_eltype,
            &i_typlen,
            &i_typbyval,
            &i_typalign
            );

    deconstruct_array(
            input,
            i_eltype,
            i_typlen,
            i_typbyval,
            i_typalign,
            &i_data,
            &nulls,
            &n
            );

    tree = NULL;

    for (i = 0; i < n; ++i)
    {
        if (nulls[i])
            continue;
        key = DatumGetInt32(i_data[i]);
        position = istore_tree_find(key, tree);
        if (position == NULL)
        {
            tree = istore_insert(tree, key, 1);
            ++s;
        }
        else
            // overflow is unlikely as you'd hit the 1GB limit before
            position->value += 1;
    }

    pairs = palloc0(sizeof *pairs);
    bigistore_pairs_init(pairs, s);
    bigistore_tree_to_pairs(tree, pairs, 0);
    istore_make_empty(tree);

    FINALIZE_BIGISTORE_NOSORT(result, pairs);
    PG_RETURN_POINTER(result);
}

Datum
array_to_bigistore(Datum *data, int count, bool *nulls)
{
    BigIStore   *out,
             *bigistore;
    AvlNode   *tree;
    int       i,
              n = 0 ,
              index;
    BigIStorePair   *payload;
    BigIStorePairs  *pairs;
    AvlNode     *position;

    tree = NULL;

    for (i = 0; i < count; ++i)
    {
        if (nulls[i])
            continue;
        bigistore = (BigIStore *) data[i];
        payload = FIRST_PAIR(bigistore, BigIStorePair);
        for (index = 0; index < bigistore->len; ++index)
        {
            position = istore_tree_find(payload[index].key, tree);
            if (position == NULL)
            {
                tree = istore_insert(tree, payload[index].key, payload[index].val);
                ++n;
            }
            else
                position->value = int32add(position->value, payload[index].val);
        }
    }
    if (n == 0)
        return 0;
    pairs = palloc0(sizeof *pairs);
    bigistore_pairs_init(pairs, n);
    bigistore_tree_to_pairs(tree, pairs, 0);
    istore_make_empty(tree);

    FINALIZE_BIGISTORE_NOSORT(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(bigistore_agg);
Datum
bigistore_agg(PG_FUNCTION_ARGS)
{
    Datum      result;
    ArrayType *input;
    Datum     *i_data;
    bool      *nulls;
    int        n;
    int16      i_typlen;
    bool       i_typbyval;
    char       i_typalign;
    Oid        i_eltype;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    input = PG_GETARG_ARRAYTYPE_P(0);

    i_eltype = ARR_ELEMTYPE(input);

    get_typlenbyvalalign(
            i_eltype,
            &i_typlen,
            &i_typbyval,
            &i_typalign
            );

    deconstruct_array(
            input,
            i_eltype,
            i_typlen,
            i_typbyval,
            i_typalign,
            &i_data,
            &nulls,
            &n
            );

    if (n == 0 || (n == 1 && nulls[0]))
        PG_RETURN_NULL();

    result = array_to_bigistore(i_data, n, nulls);
    if (result == 0)
        PG_RETURN_NULL();
    else
        return result;
}

PG_FUNCTION_INFO_V1(bigistore_agg_finalfn);
Datum
bigistore_agg_finalfn(PG_FUNCTION_ARGS)
{
    Datum            result;
    ArrayBuildState *input;
    Datum           *data;
    bool            *nulls;
    int              count;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();
    Assert(AggCheckCallContext(fcinfo, NULL));

    input = (ArrayBuildState *) PG_GETARG_POINTER(0);
    count = input->nelems;
    nulls = input->dnulls;
    data  = input->dvalues;

    if (count == 0)
        PG_RETURN_NULL();

    result = array_to_bigistore(data, count, nulls);

    if (result == 0)
        PG_RETURN_NULL();
    else
        return result;
}

static Datum
bigistore_add_from_int_arrays(ArrayType *input1, ArrayType *input2)
{
    BigIStore      *out;
    Datum          *i_data1,
                   *i_data2;
    bool           *nulls1,
                   *nulls2;
    BigIStorePairs *pairs;
    int             i,
                    n = 0,
                    n1,
                    n2;
    int16           i_typlen1,
                    i_typlen2;
    bool            i_typbyval1,
                    i_typbyval2;
    char            i_typalign1,
                    i_typalign2;
    Oid             i_eltype1,
                    i_eltype2;
    AvlNode      *tree;
    AvlNode     *position;
    int32           key,
                    value;

    i_eltype1 = ARR_ELEMTYPE(input1);
    i_eltype2 = ARR_ELEMTYPE(input2);

    get_typlenbyvalalign(
            i_eltype1,
            &i_typlen1,
            &i_typbyval1,
            &i_typalign1
            );

    get_typlenbyvalalign(
            i_eltype2,
            &i_typlen2,
            &i_typbyval2,
            &i_typalign2
            );

    deconstruct_array(
            input1,
            i_eltype1,
            i_typlen1,
            i_typbyval1,
            i_typalign1,
            &i_data1,
            &nulls1,
            &n1
            );

    deconstruct_array(
            input2,
            i_eltype2,
            i_typlen2,
            i_typbyval2,
            i_typalign2,
            &i_data2,
            &nulls2,
            &n2
            );

    if (n1 != n2)
        elog(ERROR, "array dont have the same length");

    tree = NULL;

    for (i = 0; i < n1; ++i)
    {
        if (nulls1[i] || nulls2[i])
            continue;
        key      = DatumGetInt32(i_data1[i]);
        value    = DatumGetInt32(i_data2[i]);
        position = istore_tree_find(key, tree);

        if (position == NULL)
        {
            tree = istore_insert(tree, key, value);
            ++n;
        }
        else
            position->value = int32add(position->value, value);
    }

    pairs = palloc0(sizeof *pairs);
    bigistore_pairs_init(pairs, n);
    bigistore_tree_to_pairs(tree, pairs, 0);
    istore_make_empty(tree);

    FINALIZE_BIGISTORE_NOSORT(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(bigistore_array_add);
Datum
bigistore_array_add(PG_FUNCTION_ARGS)
{
    Datum      result;
    ArrayType *input1,
              *input2;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    input1 = PG_GETARG_ARRAYTYPE_P(0);
    input2 = PG_GETARG_ARRAYTYPE_P(1);
    result = bigistore_add_from_int_arrays(input1, input2);
    if (result == 0)
        PG_RETURN_NULL();

    return result;
}

/*
 * Common initialization function for the various set-returning
 * funcs. fcinfo is only passed if the function is to return a
 * composite; it will be used to look up the return tupledesc.
 * we stash a copy of the bigistore in the multi-call context in
 * case it was originally toasted.
 */

static void
setup_firstcall(FuncCallContext *funcctx, BigIStore *is,
                FunctionCallInfoData *fcinfo)
{
    MemoryContext oldcontext;
    BigIStore     *st;

    oldcontext = MemoryContextSwitchTo(funcctx->multi_call_memory_ctx);

    st = palloc0(ISTORE_SIZE(is, BigIStorePair));
    memcpy(st, is, ISTORE_SIZE(is, BigIStorePair));

    funcctx->user_fctx = (void *) st;

    if (fcinfo)
    {
        TupleDesc   tupdesc;

        /* Build a tuple descriptor for our result type */
        if (get_call_result_type(fcinfo, NULL, &tupdesc) != TYPEFUNC_COMPOSITE)
            elog(ERROR, "return type must be a row type");

        funcctx->tuple_desc = BlessTupleDesc(tupdesc);
    }

    MemoryContextSwitchTo(oldcontext);
}



PG_FUNCTION_INFO_V1(bigistore_each);
Datum
bigistore_each(PG_FUNCTION_ARGS)
{
    FuncCallContext *funcctx;
    BigIStore       *is;
    int              i;
    BigIStorePair   *pairs;

    if (SRF_IS_FIRSTCALL())
    {
        is      = PG_GETARG_BIGIS(0);
        funcctx = SRF_FIRSTCALL_INIT();
        setup_firstcall(funcctx, is, fcinfo);
    }

    funcctx = SRF_PERCALL_SETUP();
    is      = (BigIStore *) funcctx->user_fctx;
    i       = funcctx->call_cntr;
    pairs   = FIRST_PAIR(is, BigIStorePair);

    if (i < is->len)
    {
        Datum       res,
                    dvalues[2];
        bool        nulls[2] = {false, false};
        HeapTuple   tuple;

        dvalues[0] = Int32GetDatum(pairs[i].key);
        dvalues[1] = Int64GetDatum(pairs[i].val);
        tuple      = heap_form_tuple(funcctx->tuple_desc, dvalues, nulls);
        res        = HeapTupleGetDatum(tuple);

        SRF_RETURN_NEXT(funcctx, PointerGetDatum(res));
    }

    SRF_RETURN_DONE(funcctx);
}

PG_FUNCTION_INFO_V1(bigistore_fill_gaps);
Datum
bigistore_fill_gaps(PG_FUNCTION_ARGS)
{

    BigIStore  *is,
            *result;
    BigIStorePair  *pairs;

    BigIStorePairs *creator = NULL;

    int up_to,
        fill_with,
        index1 = 0,
        index2 = 0;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    is    = PG_GETARG_BIGIS(0);
    up_to = PG_GETARG_INT32(1);

    fill_with = PG_GETARG_INT64(2);
    pairs     = FIRST_PAIR(is, BigIStorePair);
    creator   = palloc0(sizeof *creator);

    if (up_to < 0)
        elog(ERROR, "parameter upto must be >= 0");

    bigistore_pairs_init(creator, up_to + 1);

    for(index1=0; index1 <= up_to; ++index1)
    {
        if (index2 < is->len && index1 == pairs[index2].key)
        {
            bigistore_pairs_insert(creator, pairs[index2].key, pairs[index2].val);
            ++index2;
        }
        else
        {
            bigistore_pairs_insert(creator, index1, fill_with);
        }
    }

    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(bigistore_accumulate);
Datum
bigistore_accumulate(PG_FUNCTION_ARGS)
{

    BigIStore  *is,
            *result;
    BigIStorePair  *pairs;

    BigIStorePairs *creator = NULL;

    int     index1    = 0,
            index2    = 0;
    size_t  size      = 0;
    int32   start_key = 0,
            sum       = 0,
            end_key   = -1;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    is = PG_GETARG_BIGIS(0);

    pairs   = FIRST_PAIR(is, BigIStorePair);
    creator = palloc0(sizeof *creator);

    if (is->len > 0)
    {
        start_key = pairs[0].key;
        end_key = PG_NARGS() == 1 ? pairs[is->len -1].key : PG_GETARG_INT32(1);
        size = start_key > end_key ? 0 : (end_key - start_key + 1);
    }

    bigistore_pairs_init(creator, size);

    for(index1=start_key; index1 <= end_key; ++index1)
    {
        if (index2 < is->len && index1 == pairs[index2].key)
        {

            sum = int32add(sum, pairs[index2].val);
            ++index2;
        }
        bigistore_pairs_insert(creator, index1, sum);
    }

    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(bigistore_seed);
Datum
bigistore_seed(PG_FUNCTION_ARGS)
{

    BigIStore  *result;

    BigIStorePairs *creator = NULL;

    int     from,
            up_to,
            fill_with,
            index1 = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    from      = PG_GETARG_INT32(0);
    up_to     = PG_GETARG_INT32(1);
    fill_with = PG_GETARG_INT64(2);
    creator   = palloc0(sizeof *creator);

    if (up_to < from)
        elog(ERROR, "parameter upto must be >= from");

    if (from < 0 )
        elog(ERROR, "parameter from must be >= 0");

    bigistore_pairs_init(creator, up_to - from + 1);

    for(index1=from; index1 <= up_to; ++index1)
    {
        bigistore_pairs_insert(creator, index1, fill_with);
    }

    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Merge two bigistores by extraccting the bigger values
 */
PG_FUNCTION_INFO_V1(bigistore_val_larger);
Datum
bigistore_val_larger(PG_FUNCTION_ARGS)
{
    BigIStore      *is1,
                *is2,
                *result;
    BigIStorePair  *pairs1,
                *pairs2;
    BigIStorePairs *creator = NULL;
    int          index1  = 0,
                 index2  = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    is1     = PG_GETARG_BIGIS(0);
    is2     = PG_GETARG_BIGIS(1);

    pairs1  = FIRST_PAIR(is1, BigIStorePair);
    pairs2  = FIRST_PAIR(is2, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, MIN(is1->len + is2->len, 200));
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
            ++index2;
        }
        else
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, MAX(pairs1[index1].val,pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    FILLREMAINING(creator, index1, is1, pairs1, index2, is2, pairs2, BIGISINSERTFUNC)
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Merge two bigistores by extraccting the smaller values
 */
PG_FUNCTION_INFO_V1(bigistore_val_smaller);
Datum
bigistore_val_smaller(PG_FUNCTION_ARGS)
{
    BigIStore  *is1,
            *is2,
            *result;
    BigIStorePair  *pairs1,
            *pairs2;
    BigIStorePairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    is1     = PG_GETARG_BIGIS(0);
    is2     = PG_GETARG_BIGIS(1);

    pairs1  = FIRST_PAIR(is1, BigIStorePair);
    pairs2  = FIRST_PAIR(is2, BigIStorePair);
    creator = palloc0(sizeof *creator);

    bigistore_pairs_init(creator, MIN(is1->len + is2->len, 200));
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            bigistore_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
            ++index2;
        }
        else
        {
            bigistore_pairs_insert(creator, pairs1[index1].key, MIN(pairs1[index1].val, pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    FILLREMAINING(creator, index1, is1, pairs1, index2, is2, pairs2, BIGISINSERTFUNC)
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}
