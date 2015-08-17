#include "istore.h"
#include "funcapi.h"

PG_MODULE_MAGIC;

/*
 * Sum the values of an istore
 */
PG_FUNCTION_INFO_V1(istore_sum_up);
Datum
istore_sum_up(PG_FUNCTION_ARGS)
{
    IStore  *is;
    ISPair  *pairs;
    int64    result = 0;
    int     index = 0;
    is     = PG_GETARG_IS(0);
    pairs = FIRST_PAIR(is);

    while (index < is->len)
        result += pairs[index++].val;
    PG_RETURN_INT64(result);
}

/*
 * Find a key in an istore
 *
 * Binary search the key in the istore.
 */
ISPair*
is_find(IStore *is, int32 key)
{
    ISPair *pairs  = FIRST_PAIR(is);
    ISPair *result = NULL;
    int low = 0;
    int max = is->len;
    int mid = 0;
    while (low < max)
    {
        mid = low + (max - low) / 2;
        if (key < pairs[mid].key)
            max = mid;
        else if (key > pairs[mid].key)
            low = mid + 1;
        else
        {
            result = FIRST_PAIR(is) + mid;
            break;
        }
    }
    return result;
}

/*
 * Implementation of operator ?(istore, int)
 */
PG_FUNCTION_INFO_V1(is_exist);
Datum
is_exist(PG_FUNCTION_ARGS)
{
    bool found;
    IStore *in = PG_GETARG_IS(0);
    int32 key = PG_GETARG_INT32(1);
    if (is_find(in, key))
        found = true;
    else
        found = false;
    PG_RETURN_BOOL(found);
}

/*
 * Implementation of operator ->(istore, int)
 */
PG_FUNCTION_INFO_V1(is_fetchval);
Datum
is_fetchval(PG_FUNCTION_ARGS)
{
    ISPair *pair;
    IStore *in = PG_GETARG_IS(0);
    int32 key = PG_GETARG_INT32(1);
    if ((pair = is_find(in, key)) == NULL )
        PG_RETURN_NULL();
    else
        PG_RETURN_INT64(pair->val);
}

/*
 * Merge two istores
 */
PG_FUNCTION_INFO_V1(is_add);
Datum
is_add(PG_FUNCTION_ARGS)
{
    IStore  *is1,
            *is2,
            *result;
    ISPair  *pairs1,
            *pairs2;
    ISPairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
            ++index2;
        }
        else
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val + pairs2[index2].val);
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Increment values of an istore
 */
PG_FUNCTION_INFO_V1(is_add_integer);
Datum
is_add_integer(PG_FUNCTION_ARGS)
{
    IStore  *is,
            *result;
    ISPair  *pairs;
    ISPairs *creator = NULL;

    int     index = 0,
            int_arg;
    is     = PG_GETARG_IS(0);
    int_arg = PG_GETARG_INT32(1);
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index < is->len)
    {
        is_pairs_insert(creator, pairs[index].key, pairs[index].val + int_arg);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Merge two istores by subtracting
 *
 * XXX Keys which doesn't exists on first istore is added to the results
 * without changing the values on the second istore.
 */
PG_FUNCTION_INFO_V1(is_subtract);
Datum
is_subtract(PG_FUNCTION_ARGS)
{
    IStore  *is1,
            *is2,
            *result;
    ISPair  *pairs1,
            *pairs2;
    ISPairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;
    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);
    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, -pairs2[index2].val);
            ++index2;
        }
        else
        {
            is_pairs_insert(
                creator,
                pairs1[index1].key,
                pairs1[index1].val - pairs2[index2].val
            );
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Decrement values of an istore
 */
PG_FUNCTION_INFO_V1(is_subtract_integer);
Datum
is_subtract_integer(PG_FUNCTION_ARGS)
{
    IStore  *is,
            *result;
    ISPair  *pairs;
    ISPairs *creator = NULL;

    int     index = 0,
            int_arg;
    is     = PG_GETARG_IS(0);
    int_arg = PG_GETARG_INT32(1);
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index < is->len)
    {
        is_pairs_insert(creator, pairs[index].key, pairs[index].val - int_arg);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Multiply values of two istores
 *
 * XXX The two istores should have the same keys.  The keys which exist on only
 * one istore is added to the result with NULL values.
 */
PG_FUNCTION_INFO_V1(is_multiply);
Datum
is_multiply(PG_FUNCTION_ARGS)
{
    IStore  *is1,
            *is2,
            *result;
    ISPair  *pairs1,
            *pairs2;
    ISPairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;
    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);
    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);

    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
            ++index1;
        else if (pairs1[index1].key > pairs2[index2].key)
            ++index2;
        else
        {
            is_pairs_insert(
                creator,
                pairs1[index1].key,
                pairs1[index1].val * pairs2[index2].val
            );
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        ++index1;
    }
    while (index2 < is2->len)
    {
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Multiply values of an istore
 */
PG_FUNCTION_INFO_V1(is_multiply_integer);
Datum
is_multiply_integer(PG_FUNCTION_ARGS)
{
    IStore  *is,
            *result;
    ISPair  *pairs;
    ISPairs *creator = NULL;

    int     index = 0,
            int_arg;
    is     = PG_GETARG_IS(0);
    int_arg = PG_GETARG_INT32(1);
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index < is->len)
    {
        is_pairs_insert(creator, pairs[index].key, pairs[index].val * int_arg);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Divide values of two istores
 *
 * XXX The values of the result are truncated.
 *
 * XXX The two istores should have the same keys.  The keys which exist on only
 * one istore is added to the result with NULL values.
 */
PG_FUNCTION_INFO_V1(is_divide);
Datum
is_divide(PG_FUNCTION_ARGS)
{
    IStore  *is1,
            *is2,
            *result;
    ISPair  *pairs1,
            *pairs2;
    ISPairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;
    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);
    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs2[index2].val == 0)
            ereport(ERROR, (
                errcode(ERRCODE_DIVISION_BY_ZERO),
                errmsg("division by zero"),
                errdetail("Key \"%d\" of right argument has value 0", pairs2[index2].key)
            ));

        if (pairs1[index1].key < pairs2[index2].key)
            ++index1;
        else if (pairs1[index1].key > pairs2[index2].key)
            ++index2;
        else
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val / pairs2[index2].val);
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
        ++index1;
    }
    while (index2 < is2->len)
    {
        if (pairs2[index2].val == 0)
            ereport(ERROR, (
                errcode(ERRCODE_DIVISION_BY_ZERO),
                errmsg("division by zero"),
                errdetail("Key \"%d\" of right argument has value 0", pairs2[index2].key)
            ));

        is_pairs_insert(creator, pairs2[index2].key, 1 / pairs2[index2].val);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Divide values of an istore
 *
 * XXX The values of the result are truncated.
 */
PG_FUNCTION_INFO_V1(is_divide_integer);
Datum
is_divide_integer(PG_FUNCTION_ARGS)
{
    IStore  *is,
            *result;
    ISPair  *pairs;
    ISPairs *creator = NULL;

    int     index = 0,
            int_arg;
    is     = PG_GETARG_IS(0);
    int_arg = PG_GETARG_INT32(1);

    if (int_arg == 0)
        ereport(ERROR, (
            errcode(ERRCODE_DIVISION_BY_ZERO),
            errmsg("division by zero")
        ));

    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index < is->len)
    {
        is_pairs_insert(creator, pairs[index].key, pairs[index].val / int_arg);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Divide values of an istore
 *
 * XXX The values of the result are truncated.
 */
PG_FUNCTION_INFO_V1(is_divide_int8);
Datum
is_divide_int8(PG_FUNCTION_ARGS)
{
    IStore  *is,
            *result;
    ISPair  *pairs;
    ISPairs *creator = NULL;

    int     index = 0;
    int64   int_arg;
    is     = PG_GETARG_IS(0);
    int_arg = PG_GETARG_INT64(1);
    if (int_arg == 0)
        ereport(ERROR, (
            errcode(ERRCODE_DIVISION_BY_ZERO),
            errmsg("division by zero")
        ));
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index < is->len)
    {
        is_pairs_insert(creator, pairs[index].key, pairs[index].val / int_arg);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_from_array);
Datum
istore_from_array(PG_FUNCTION_ARGS)
{
    IStore    *result;
    Datum     *i_data;
    bool      *nulls;
    int        n;
    int16      i_typlen;
    bool       i_typbyval;
    char       i_typalign;
    Oid        i_eltype;
    AvlTree  tree;
    ISPairs   *pairs;
    Position position;
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

    tree = is_make_empty(NULL);

    for (i = 0; i < n; ++i)
    {
        if (nulls[i])
            continue;
        key = DatumGetInt32(i_data[i]);
        if (key < 0)
            elog(ERROR, "cannot count array that has negative integers");
        position = is_tree_find(key, tree);
        if (position == NULL)
            tree = is_insert(key, 1, tree);
        else
            position->value += 1;
    }

    n = is_tree_length(tree);
    pairs = palloc0(sizeof *pairs);
    is_pairs_init(pairs, 200);
    is_tree_to_pairs(tree, pairs, 0);
    is_make_empty(tree);
    FINALIZE_ISTORE(result, pairs);
    PG_RETURN_POINTER(result);
}

Datum
array_to_istore(Datum *data, int count, bool *nulls)
{
    IStore *out,
           *istore;
    AvlTree  tree;
    int i,
        index;
    ISPair *payload;
    ISPairs   *pairs;
    Position position;

    tree = is_make_empty(NULL);

    for (i = 0; i < count; ++i)
    {
        if (nulls[i])
            continue;
        istore = (IStore *) data[i];
        for (index = 0; index < istore->len; ++index)
        {
            payload = FIRST_PAIR(istore) + index;
            position = is_tree_find(payload->key, tree);
            if (position == NULL)
                tree = is_insert(payload->key, payload->val, tree);
            else
                position->value += payload->val;
        }
    }
    i = is_tree_length(tree);
    if (i == 0)
        return 0;

    pairs = palloc0(sizeof *pairs);
    is_pairs_init(pairs, 200);
    is_tree_to_pairs(tree, pairs, 0);
    is_make_empty(tree);
    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(istore_agg);
Datum
istore_agg(PG_FUNCTION_ARGS)
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

    result = array_to_istore(i_data, n, nulls);
    if (result == 0)
        PG_RETURN_NULL();
    else
        return result;
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

    result = array_to_istore(data, count, nulls);

    if (result == 0)
        PG_RETURN_NULL();
    else
        return result;
}

static Datum
istore_add_from_int_arrays(ArrayType *input1, ArrayType *input2)
{
    IStore    *out;
    Datum     *i_data1,
              *i_data2;
    bool      *nulls1,
              *nulls2;
    int        i,
               n1,
               n2;
    int16      i_typlen1,
               i_typlen2;
    bool       i_typbyval1,
               i_typbyval2;
    char       i_typalign1,
               i_typalign2;
    Oid        i_eltype1,
               i_eltype2;
    AvlTree    tree;
    ISPairs   *pairs;
    Position   position;
    int64       key,
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

    tree = is_make_empty(NULL);

    for (i = 0; i < n1; ++i)
    {
        if (nulls1[i] || nulls2[i])
            continue;
        key   = DatumGetInt32(i_data1[i]);

        switch (i_eltype2)
        {
            case INT4OID:
                value = DatumGetInt32(i_data2[i]);
                break;
            case INT8OID:
                value = DatumGetInt64(i_data2[i]);
                break;
            default:
                elog(ERROR, "istore_add_from_int_arrays unsupported array type %d", i_eltype2);
        }

        position = is_tree_find(key, tree);
        if (position == NULL)
            tree = is_insert(key, value, tree);
        else
            position->value += value;
    }

    pairs = palloc0(sizeof *pairs);

    is_pairs_init(pairs, 200);
    is_tree_to_pairs(tree, pairs, 0);
    is_make_empty(tree);
    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(istore_array_add);
Datum
istore_array_add(PG_FUNCTION_ARGS)
{
    Datum    result;
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

    COPY_ISTORE(st, is);

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
    IStore     *is;
    int         i;
    ISPair          *pairs;

    if (SRF_IS_FIRSTCALL())
    {
        is = PG_GETARG_IS(0);
        funcctx = SRF_FIRSTCALL_INIT();
        setup_firstcall(funcctx, is, fcinfo);
    }

    funcctx = SRF_PERCALL_SETUP();
    is = (IStore *) funcctx->user_fctx;
    i = funcctx->call_cntr;
    pairs = FIRST_PAIR(is);

    if (i < is->len)
    {
        Datum       res,
                    dvalues[2];
        bool        nulls[2] = {false, false};
        HeapTuple   tuple;

        dvalues[0] = UInt32GetDatum(pairs[i].key);
        dvalues[1] = Int64GetDatum(pairs[i].val);
        tuple = heap_form_tuple(funcctx->tuple_desc, dvalues, nulls);
        res = HeapTupleGetDatum(tuple);

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
    ISPair  *pairs;

    ISPairs *creator = NULL;

    int     up_to;
    int64   fill_with;
    int     index1 = 0,
            index2 = 0;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    is = PG_GETARG_IS(0);
    up_to = PG_GETARG_INT32(1);

    fill_with = PG_GETARG_INT64(2);
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);

    if (up_to < 0)
        elog(ERROR, "parameter upto must be >= 0");

    is_pairs_init(creator, up_to + 1);

    for(index1=0; index1 <= up_to; ++index1)
    {
        if (index2 < is->len && index1 == pairs[index2].key)
        {
            is_pairs_insert(creator, pairs[index2].key, pairs[index2].val);
            ++index2;
        }
        else
        {
            is_pairs_insert(creator, index1, fill_with);
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
    ISPair  *pairs;

    ISPairs *creator = NULL;

    int64    sum = 0;
    int     index1 = 0,
            index2 = 0;
    size_t  size = 0 ;
    int32   start_key = 0,
            end_key = -1;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    is = PG_GETARG_IS(0);

    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);

    if (is->len > 0)
    {
        start_key = pairs[0].key;
        end_key = PG_NARGS() == 1 ? pairs[is->len -1].key : PG_GETARG_INT32(1);
        size = start_key > end_key ? 0 : (end_key - start_key + 1);
    }

    is_pairs_init(creator, size);

    for(index1=start_key; index1 <= end_key; ++index1)
    {
        if (index2 < is->len && index1 == pairs[index2].key)
        {

            sum += pairs[index2].val;
            ++index2;
        }
        is_pairs_insert(creator, index1, sum);
    }

    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_seed);
Datum
istore_seed(PG_FUNCTION_ARGS)
{

    IStore  *result;

    ISPairs *creator = NULL;

    int     from,
            up_to;
    int64  fill_with;
    int     index1 = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    from = PG_GETARG_INT32(0);
    up_to = PG_GETARG_INT32(1);
    fill_with = PG_GETARG_INT64(2);
    creator = palloc0(sizeof *creator);

    if (up_to < from)
        elog(ERROR, "parameter upto must be >= from");

    if (from < 0 )
        elog(ERROR, "parameter from must be >= 0");

    is_pairs_init(creator, up_to - from + 1);

    for(index1=from; index1 <= up_to; ++index1)
    {
        is_pairs_insert(creator, index1, fill_with);
    }

    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Merge two istores by extraccting the bigger values
 */
PG_FUNCTION_INFO_V1(is_val_larger);
Datum
is_val_larger(PG_FUNCTION_ARGS)
{
    IStore  *is1,
            *is2,
            *result;
    ISPair  *pairs1,
            *pairs2;
    ISPairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
            ++index2;
        }
        else
        {
            is_pairs_insert(creator, pairs1[index1].key, ((pairs1[index1].val > pairs2[index2].val) ? pairs1[index1].val : pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Merge two istores by extraccting the smaller values
 */
PG_FUNCTION_INFO_V1(is_val_smaller);
Datum
is_val_smaller(PG_FUNCTION_ARGS)
{
    IStore  *is1,
            *is2,
            *result;
    ISPair  *pairs1,
            *pairs2;
    ISPairs *creator = NULL;

    int     index1 = 0,
            index2 = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
            ++index2;
        }
        else
        {
            is_pairs_insert(creator, pairs1[index1].key, ((pairs1[index1].val < pairs2[index2].val) ? pairs1[index1].val : pairs2[index2].val));
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}
