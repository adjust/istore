#include "istore.h"
#include "funcapi.h"
#include "intutils.h"

PG_MODULE_MAGIC;

/*
 * combine two istores by applying PGFunction mergefunc on values where key match
 * if PGFunction miss1func is not NULL values for keys which doesn't exists on
 * first istore is added to the result by applying miss1func to the value
 * while values for keys which doesn't exists on second istore will be added without
 * change.
 * if PGFunction miss1func is NULL only the result will only contain matching keys
 */
IStore*
istore_merge(IStore *arg1, IStore *arg2, PGFunction mergefunc, PGFunction miss1func)
{
    IStore      *result;
    IStorePair  *pairs1,
                *pairs2;
    IStorePairs *creator = NULL;
    int          index1  = 0,
                 index2  = 0;

    pairs1  = FIRST_PAIR(arg1, IStorePair);
    pairs2  = FIRST_PAIR(arg2, IStorePair);
    creator = palloc0(sizeof *creator);

    istore_pairs_init(creator, MIN(arg1->len + arg2->len, 200));

    while (index1 < arg1->len && index2 < arg2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            if (miss1func != NULL)
                istore_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            if (miss1func != NULL)
                istore_pairs_insert(creator, pairs2[index2].key, DirectFunctionCall1(miss1func, pairs2[index2].val));
            ++index2;
        }
        else
        {
            istore_pairs_insert(creator, pairs1[index1].key, DirectFunctionCall2(mergefunc, pairs1[index1].val, pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    if (miss1func != NULL){
        while (index1 < arg1->len)
        {
            istore_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }

        while (index2 < arg2->len)
        {
            istore_pairs_insert(creator, pairs2[index2].key, DirectFunctionCall1(miss1func, pairs2[index2].val));
            ++index2;
        }
    }

    FINALIZE_ISTORE(result, creator);

    return result;
}

/*
 * apply PGFunction applyfunc on each value of arg1 with arg2
 */
IStore*
istore_apply_datum(IStore *arg1, Datum arg2, PGFunction applyfunc)
{
    IStore      *result;
    IStorePair  *pairs;
    IStorePairs *creator = NULL;
    int          index  = 0;


    pairs   = FIRST_PAIR(arg1, IStorePair);
    creator = palloc0(sizeof *creator);

    istore_pairs_init(creator, arg1->len);
    while (index < arg1->len)
    {
        istore_pairs_insert(creator, pairs[index].key, DirectFunctionCall2(applyfunc, pairs[index].val, arg2));
        ++index;
    }
    FINALIZE_ISTORE(result, creator);

    return result;
}

/*
 * special division operations that allows division by zero if nominator is zero
 * as well. Thus 0/0 becomes 0
 */
PG_FUNCTION_INFO_V1(is_int4div);
Datum
is_int4div(PG_FUNCTION_ARGS)
{
    int32 arg1,
          arg2;

    arg1 = PG_GETARG_INT32(0);
    arg2 = PG_GETARG_INT32(1);

    if (arg1 == 0)
        PG_RETURN_INT32(0);

    PG_RETURN_INT32(DirectFunctionCall2(int4div, arg1, arg2));
}


/*
 * Sum the values of an istore
 */
PG_FUNCTION_INFO_V1(istore_sum_up);
Datum
istore_sum_up(PG_FUNCTION_ARGS)
{
    IStore      *is;
    IStorePair  *pairs;
    int64        result;
    int          index;

    is     = PG_GETARG_IS(0);
    pairs  = FIRST_PAIR(is, IStorePair);
    result = 0;
    index  = 0;

    while (index < is->len){
        result = DirectFunctionCall2(int4pl, result, pairs[index++].val);
    }
    PG_RETURN_INT64(result);
}

/*
 * Find a key in an istore
 *
 * Binary search the key in the istore.
 */
IStorePair*
istore_find(IStore *is, int32 key)
{
    IStorePair *pairs  = FIRST_PAIR(is, IStorePair);
    IStorePair *result = NULL;
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
            result = FIRST_PAIR(is, IStorePair) + mid;
            break;
        }
    }
    return result;
}

/*
 * Implementation of operator ?(istore, int)
 */
PG_FUNCTION_INFO_V1(istore_exist);
Datum
istore_exist(PG_FUNCTION_ARGS)
{
    bool found;
    IStore *in = PG_GETARG_IS(0);
    int32 key  = PG_GETARG_INT32(1);
    if (istore_find(in, key))
        found = true;
    else
        found = false;
    PG_RETURN_BOOL(found);
}

/*
 * Implementation of operator ->(istore, int)
 */
PG_FUNCTION_INFO_V1(istore_fetchval);
Datum
istore_fetchval(PG_FUNCTION_ARGS)
{
    IStorePair *pair;
    IStore *in = PG_GETARG_IS(0);
    int32 key  = PG_GETARG_INT32(1);
    if ((pair = istore_find(in, key)) == NULL )
        PG_RETURN_NULL();
    else
        PG_RETURN_INT64(pair->val);
}

/*
 * Merge two istores
 */
PG_FUNCTION_INFO_V1(istore_add);
Datum
istore_add(PG_FUNCTION_ARGS)
{
    IStore      *is1,
                *is2;

    is1     = PG_GETARG_IS(0);
    is2     = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4pl, int4up));
}

/*
 * Increment values of an istore
 */
PG_FUNCTION_INFO_V1(istore_add_integer);
Datum
istore_add_integer(PG_FUNCTION_ARGS)
{
    IStore      *is;
    Datum        int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4pl));
}

/*
 * Merge two istores by subtracting
 *
 * XXX Keys which doesn't exists on first istore is added to the results
 * without changing the values on the second istore.
 */
PG_FUNCTION_INFO_V1(istore_subtract);
Datum
istore_subtract(PG_FUNCTION_ARGS)
{
    IStore      *is1,
                *is2;

    is1     = PG_GETARG_IS(0);
    is2     = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4mi, int4um));
}

/*
 * Decrement values of an istore
 */
PG_FUNCTION_INFO_V1(istore_subtract_integer);
Datum
istore_subtract_integer(PG_FUNCTION_ARGS)
{
    IStore  *is;
    Datum    int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4mi));
}

/*
 * Multiply values of two istores
 *
 * The two istores should have the same keys.  The keys which exist on only
 * one istore are omitted.
 */
PG_FUNCTION_INFO_V1(istore_multiply);
Datum
istore_multiply(PG_FUNCTION_ARGS)
{
    IStore      *is1,
                *is2;

    is1     = PG_GETARG_IS(0);
    is2     = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4mul, NULL));
}

/*
 * Multiply values of an istore
 */
PG_FUNCTION_INFO_V1(istore_multiply_integer);
Datum
istore_multiply_integer(PG_FUNCTION_ARGS)
{
    IStore  *is;
    Datum    int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4mul));
}

/*
 * Divide values of two istores
 *
 * XXX The values of the result are truncated.
 *
 * XXX The two istores should have the same keys.  The keys which exist on only
 * one istore is added to the result with NULL values.
 */
PG_FUNCTION_INFO_V1(istore_divide);
Datum
istore_divide(PG_FUNCTION_ARGS)
{
    IStore      *is1,
                *is2;

    is1     = PG_GETARG_IS(0);
    is2     = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, is_int4div, NULL));
}

/*
 * Divide values of an istore
 *
 * XXX The values of the result are truncated.
 */
PG_FUNCTION_INFO_V1(istore_divide_integer);
Datum
istore_divide_integer(PG_FUNCTION_ARGS)
{
    IStore  *is;
    Datum    int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4div));
}

PG_FUNCTION_INFO_V1(istore_from_intarray);
Datum
istore_from_intarray(PG_FUNCTION_ARGS)
{
    IStore    *result;
    Datum     *i_data;
    bool      *nulls;
    int        n,
               s = 0;
    int16      i_typlen;
    bool       i_typbyval;
    char       i_typalign;
    Oid        i_eltype;
    AvlNode   *tree;
    IStorePairs   *pairs;
    AvlNode   *position;
    int      key,
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
        position = tree_find(key, tree);
        if (position == NULL)
        {
            tree = tree_insert(tree, key, 1);
            ++s;
        }
        else
            // overflow is unlikely as you'd hit the 1GB limit before
            position->value += 1;
    }

    pairs = palloc0(sizeof *pairs);
    istore_pairs_init(pairs, s);
    istore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_ISTORE(result, pairs);
    PG_RETURN_POINTER(result);
}

Datum
array_to_istore(Datum *data, int count, bool *nulls)
{
    IStore   *out,
             *istore;
    AvlNode   *tree;
    int       i,
              n = 0,
              index;
    IStorePair   *payload;
    IStorePairs  *pairs;
    AvlNode  *position;

    tree = NULL;

    for (i = 0; i < count; ++i)
    {
        if (nulls[i])
            continue;
        istore = (IStore *) data[i];
        payload = FIRST_PAIR(istore, IStorePair);
        for (index = 0; index < istore->len; ++index)
        {
            position = tree_find(payload[index].key, tree);
            if (position == NULL)
            {
                tree = tree_insert(tree, payload[index].key, payload[index].val);
                ++n;
            }
            else
                position->value = DirectFunctionCall2(int4pl, position->value, payload[index].val);
        }
    }

    if (n == 0)
        return 0;
    pairs = palloc0(sizeof *pairs);
    istore_pairs_init(pairs, n);
    istore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(istore_agg_finalfn);
Datum
istore_agg_finalfn(PG_FUNCTION_ARGS)
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

    result = istore_array_sum(data, count, nulls);

    if (result == 0)
        PG_RETURN_NULL();
    else
        return result;
}

static Datum
istore_add_from_int_arrays(ArrayType *input1, ArrayType *input2)
{
    IStore      *out;
    Datum       *i_data1,
                *i_data2;
    bool        *nulls1,
                *nulls2;
    IStorePairs *pairs;
    int          i,
                 n = 0,
                 n1,
                 n2;
    int16        i_typlen1,
                 i_typlen2;
    bool         i_typbyval1,
                 i_typbyval2;
    char         i_typalign1,
                 i_typalign2;
    Oid          i_eltype1,
                 i_eltype2;
    AvlNode      *tree;
    AvlNode      *position;
    int32        key,
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
        position = tree_find(key, tree);

        if (position == NULL)
        {
            tree = tree_insert(tree, key, value);
            ++n;
        }
        else
            position->value = DirectFunctionCall2(int4pl, position->value, value);
    }

    pairs = palloc0(sizeof *pairs);
    istore_pairs_init(pairs, n);
    istore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);

    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(istore_array_add);
Datum
istore_array_add(PG_FUNCTION_ARGS)
{
    Datum      result;
    ArrayType *input1,
              *input2;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    input1 = PG_GETARG_ARRAYTYPE_P(0);
    input2 = PG_GETARG_ARRAYTYPE_P(1);
    result = istore_add_from_int_arrays(input1, input2);
    if (result == 0)
        PG_RETURN_NULL();

    return result;
}

/*
 * Common initialization function for the various set-returning
 * funcs. fcinfo is only passed if the function is to return a
 * composite; it will be used to look up the return tupledesc.
 * we stash a copy of the istore in the multi-call context in
 * case it was originally toasted.
 */

static void
setup_firstcall(FuncCallContext *funcctx, IStore *is,
                FunctionCallInfoData *fcinfo)
{
    MemoryContext oldcontext;
    IStore     *st;

    oldcontext = MemoryContextSwitchTo(funcctx->multi_call_memory_ctx);

    st = palloc0(ISTORE_SIZE(is, IStorePair));
    memcpy(st, is, ISTORE_SIZE(is, IStorePair));

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



PG_FUNCTION_INFO_V1(istore_each);
Datum
istore_each(PG_FUNCTION_ARGS)
{
    FuncCallContext *funcctx;
    IStore          *is;
    int              i;
    IStorePair          *pairs;

    if (SRF_IS_FIRSTCALL())
    {
        is      = PG_GETARG_IS(0);
        funcctx = SRF_FIRSTCALL_INIT();
        setup_firstcall(funcctx, is, fcinfo);
    }

    funcctx = SRF_PERCALL_SETUP();
    is      = (IStore *) funcctx->user_fctx;
    i       = funcctx->call_cntr;
    pairs   = FIRST_PAIR(is, IStorePair);

    if (i < is->len)
    {
        Datum       res,
                    dvalues[2];
        bool        nulls[2] = {false, false};
        HeapTuple   tuple;

        dvalues[0] = Int32GetDatum(pairs[i].key);
        dvalues[1] = Int32GetDatum(pairs[i].val);
        tuple      = heap_form_tuple(funcctx->tuple_desc, dvalues, nulls);
        res        = HeapTupleGetDatum(tuple);

        SRF_RETURN_NEXT(funcctx, PointerGetDatum(res));
    }

    SRF_RETURN_DONE(funcctx);
}

PG_FUNCTION_INFO_V1(istore_fill_gaps);
Datum
istore_fill_gaps(PG_FUNCTION_ARGS)
{

    IStore  *is,
            *result;
    IStorePair  *pairs;

    IStorePairs *creator = NULL;

    int up_to,
        fill_with,
        index1 = 0,
        index2 = 0;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    is    = PG_GETARG_IS(0);
    up_to = PG_GETARG_INT32(1);

    fill_with = PG_GETARG_INT64(2);
    pairs     = FIRST_PAIR(is, IStorePair);
    creator   = palloc0(sizeof *creator);

    if (up_to < 0)
        elog(ERROR, "parameter upto must be >= 0");

    istore_pairs_init(creator, up_to + 1);

    for(index1=0; index1 <= up_to; ++index1)
    {
        if (index2 < is->len && index1 == pairs[index2].key)
        {
            istore_pairs_insert(creator, pairs[index2].key, pairs[index2].val);
            ++index2;
        }
        else
        {
            istore_pairs_insert(creator, index1, fill_with);
        }
    }

    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_accumulate);
Datum
istore_accumulate(PG_FUNCTION_ARGS)
{

    IStore  *is,
            *result;
    IStorePair  *pairs;

    IStorePairs *creator = NULL;

    int     index1    = 0,
            index2    = 0;
    size_t  size      = 0;
    int32   start_key = 0,
            sum       = 0,
            end_key   = -1;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    is = PG_GETARG_IS(0);

    pairs   = FIRST_PAIR(is, IStorePair);
    creator = palloc0(sizeof *creator);

    if (is->len > 0)
    {
        start_key = pairs[0].key;
        end_key = PG_NARGS() == 1 ? pairs[is->len -1].key : PG_GETARG_INT32(1);
        size = start_key > end_key ? 0 : (end_key - start_key + 1);
    }

    istore_pairs_init(creator, size);

    for(index1=start_key; index1 <= end_key; ++index1)
    {
        if (index2 < is->len && index1 == pairs[index2].key)
        {

            sum = DirectFunctionCall2(int4pl, sum, pairs[index2].val);
            ++index2;
        }
        istore_pairs_insert(creator, index1, sum);
    }

    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_seed);
Datum
istore_seed(PG_FUNCTION_ARGS)
{

    IStore  *result;

    IStorePairs *creator = NULL;

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

    istore_pairs_init(creator, up_to - from + 1);

    for(index1=from; index1 <= up_to; ++index1)
    {
        istore_pairs_insert(creator, index1, fill_with);
    }

    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Merge two istores by extraccting the bigger values
 */
PG_FUNCTION_INFO_V1(istore_val_larger);
Datum
istore_val_larger(PG_FUNCTION_ARGS)
{
    IStore      *is1,
                *is2;

    is1     = PG_GETARG_IS(0);
    is2     = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4larger, int4up));
}

/*
 * Merge two istores by extraccting the smaller values
 */
PG_FUNCTION_INFO_V1(istore_val_smaller);
Datum
istore_val_smaller(PG_FUNCTION_ARGS)
{
    IStore      *is1,
                *is2;

    is1     = PG_GETARG_IS(0);
    is2     = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4smaller, int4up));
}
