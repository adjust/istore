#include "istore.h"

#if PG_VERSION_NUM < 90300
#include "access/htup.h"
#else
#include "access/htup_details.h"
#endif
#include "catalog/pg_type.h"
#include "funcapi.h"
#include "utils/array.h"
#include "utils/builtins.h"
#include "utils/lsyscache.h"
#include "utils/typcache.h"

PG_MODULE_MAGIC;

static inline Datum *istore_key_val_datums(IStore *is);

/*
 * combine two istores by applying PGFunction mergefunc on values where key match
 * if PGFunction miss1func is not NULL values for keys which doesn't exists on
 * first istore is added to the result by applying miss1func to the value
 * while values for keys which doesn't exists on second istore will be added without
 * change.
 * if PGFunction miss1func is NULL only the result will only contain matching keys
 */
static IStore *
istore_merge(IStore *arg1, IStore *arg2, PGFunction mergefunc, PGFunction miss1func)
{
    IStore *     result;
    IStorePair * pairs1, *pairs2;
    IStorePairs *creator = NULL;
    int          index1 = 0, index2 = 0;

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
            if (mergefunc != NULL)
                istore_pairs_insert(
                  creator, pairs1[index1].key, DirectFunctionCall2(mergefunc, pairs1[index1].val, pairs2[index2].val));
            else
                istore_pairs_insert(creator, pairs1[index1].key, pairs2[index2].val);
            ++index1;
            ++index2;
        }
    }

    if (miss1func != NULL)
    {
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
static IStore *
istore_apply_datum(IStore *arg1, Datum arg2, PGFunction applyfunc)
{
    IStore *     result;
    IStorePair * pairs;
    IStorePairs *creator = NULL;
    int          index   = 0;

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
 * get the smallest key from an istore
 */
PG_FUNCTION_INFO_V1(istore_min_key);
Datum istore_min_key(PG_FUNCTION_ARGS)
{
    IStore *istore;
    int32   key;

    istore = PG_GETARG_IS(0);
    if (istore->len == 0)
    {
        PG_RETURN_NULL();
    }
    else
    {
        key = FIRST_PAIR(istore, IStorePair)[0].key;
        PG_RETURN_INT32(key);
    }
}

/*
 * get the biggest key from an istore
 */
PG_FUNCTION_INFO_V1(istore_max_key);
Datum istore_max_key(PG_FUNCTION_ARGS)
{
    IStore *istore;
    int32   key;

    istore = PG_GETARG_IS(0);
    if (istore->len == 0)
    {
        PG_RETURN_NULL();
    }
    else
    {
        key = LAST_PAIR(istore, IStorePair)->key;
        PG_RETURN_INT32(key);
    }
}

/*
 * remove zero values from istore
 */
PG_FUNCTION_INFO_V1(istore_compact);
Datum istore_compact(PG_FUNCTION_ARGS)
{
    IStore *     is, *result;
    IStorePair * pairs;
    int          index;
    IStorePairs *creator;

    is      = PG_GETARG_IS(0);
    pairs   = FIRST_PAIR(is, IStorePair);
    index   = 0;
    creator = NULL;
    creator = palloc0(sizeof *creator);
    istore_pairs_init(creator, is->len);
    while (index < is->len)
    {
        if (pairs[index].val != 0)
            istore_pairs_insert(creator, pairs[index].key, pairs[index].val);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

/*
 * Sum the values of an istore
 */
PG_FUNCTION_INFO_V1(istore_sum_up);
Datum istore_sum_up(PG_FUNCTION_ARGS)
{
    IStore *    is;
    IStorePair *pairs;
    int64       result;
    int         index;
    int32       end_key;

    is     = PG_GETARG_IS(0);
    pairs  = FIRST_PAIR(is, IStorePair);
    result = 0;
    index  = 0;

    if (is->len == 0)
        PG_RETURN_INT64(0);

    if (PG_NARGS() == 1)
    {
        while (index < is->len)
            result = DirectFunctionCall2(int84pl, result, pairs[index++].val);
    }
    else
    {
        end_key = PG_GETARG_INT32(1) > pairs[is->len - 1].key ? pairs[is->len - 1].key : PG_GETARG_INT32(1);
        while (index < is->len && pairs[index].key <= end_key)
            result = DirectFunctionCall2(int84pl, result, pairs[index++].val);
    }

    PG_RETURN_INT64(result);
}

/*
 * Binary search the key in the istore.
 */
static IStorePair *
istore_find(IStore *is, int32 key, int *off_out)
{
    IStorePair *pairs  = FIRST_PAIR(is, IStorePair);
    IStorePair *result = NULL;
    int         low    = 0;
    int         max    = is->len;
    int         mid    = 0;
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
            if (off_out)
                *off_out = mid;
            break;
        }
    }
    return result;
}

/*
 * Implementation of operator ?(istore, int)
 */
PG_FUNCTION_INFO_V1(istore_exist);
Datum istore_exist(PG_FUNCTION_ARGS)
{
    bool    found;
    IStore *in  = PG_GETARG_IS(0);
    int32   key = PG_GETARG_INT32(1);
    if (istore_find(in, key, NULL))
        found = true;
    else
        found = false;
    PG_RETURN_BOOL(found);
}

/*
 * Implementation of operator ->(istore, int)
 */
PG_FUNCTION_INFO_V1(istore_fetchval);
Datum istore_fetchval(PG_FUNCTION_ARGS)
{
    IStorePair *pair;
    IStore *    in  = PG_GETARG_IS(0);
    int32       key = PG_GETARG_INT32(1);
    if ((pair = istore_find(in, key, NULL)) == NULL)
        PG_RETURN_NULL();
    else
        PG_RETURN_INT64(pair->val);
}

/*
 * Merge two istores by addition of values
 */
PG_FUNCTION_INFO_V1(istore_add);
Datum istore_add(PG_FUNCTION_ARGS)
{
    IStore *is1, *is2;

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4pl, int4up));
}

/*
 * Increment values of an istore
 */
PG_FUNCTION_INFO_V1(istore_add_integer);
Datum istore_add_integer(PG_FUNCTION_ARGS)
{
    IStore *is;
    Datum   int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4pl));
}

/*
 * Merge two istores by subtracting
 *
 * Keys which doesn't exists on first istore is added to the results
 * a treated as if their value is zero
 */
PG_FUNCTION_INFO_V1(istore_subtract);
Datum istore_subtract(PG_FUNCTION_ARGS)
{
    IStore *is1, *is2;

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4mi, int4um));
}
/*
 * Decrement values of an istore
 */
PG_FUNCTION_INFO_V1(istore_subtract_integer);
Datum istore_subtract_integer(PG_FUNCTION_ARGS)
{
    IStore *is;
    Datum   int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4mi));
}

/*
 * Multiply values of two istores
 *
 * The two istores should have the same keys. The keys which exist on only
 * one istore are omitted.
 */
PG_FUNCTION_INFO_V1(istore_multiply);
Datum istore_multiply(PG_FUNCTION_ARGS)
{
    IStore *is1, *is2;

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4mul, NULL));
}

/*
 * Multiply values of an istore
 */
PG_FUNCTION_INFO_V1(istore_multiply_integer);
Datum istore_multiply_integer(PG_FUNCTION_ARGS)
{
    IStore *is;
    Datum   int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4mul));
}

/*
 * Divide values of two istores
 *
 * The two istores should have the same keys.  The keys which exist on only
 * one istore are omitted.
 */
PG_FUNCTION_INFO_V1(istore_divide);
Datum istore_divide(PG_FUNCTION_ARGS)
{
    IStore *is1, *is2;

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4div, NULL));
}

/*
 * Divide values of an istore
 */
PG_FUNCTION_INFO_V1(istore_divide_integer);
Datum istore_divide_integer(PG_FUNCTION_ARGS)
{
    IStore *is;
    Datum   int_arg;

    is      = PG_GETARG_IS(0);
    int_arg = PG_GETARG_DATUM(1);

    PG_RETURN_POINTER(istore_apply_datum(is, int_arg, int4div));
}

/*
 * concat two istores
 *
 * duplicate keys get overwritten
 */
PG_FUNCTION_INFO_V1(istore_concat);
Datum istore_concat(PG_FUNCTION_ARGS)
{
    IStore *is1, *is2;

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, NULL, int4up));
}

/*
 * create an istore from an intarray by counting elements
 */
PG_FUNCTION_INFO_V1(istore_from_intarray);
Datum istore_from_intarray(PG_FUNCTION_ARGS)
{
    IStore *     result;
    Datum *      i_data;
    bool *       nulls;
    int          n, s = 0;
    int16        i_typlen;
    bool         i_typbyval;
    char         i_typalign;
    Oid          i_eltype;
    AvlNode *    tree;
    IStorePairs *pairs;
    AvlNode *    position;
    int          key, i;

    ArrayType *input = PG_GETARG_ARRAYTYPE_P(0);
    if (input == NULL)
        PG_RETURN_NULL();

    i_eltype = ARR_ELEMTYPE(input);

    get_typlenbyvalalign(i_eltype, &i_typlen, &i_typbyval, &i_typalign);

    deconstruct_array(input, i_eltype, i_typlen, i_typbyval, i_typalign, &i_data, &nulls, &n);

    tree = NULL;

    for (i = 0; i < n; ++i)
    {
        if (nulls[i])
            continue;
        switch (i_eltype)
        {
            case INT2OID: key = DatumGetInt16(i_data[i]); break;
            case INT4OID: key = DatumGetInt32(i_data[i]); break;
            default: elog(ERROR, "unsupported array type");
        }

        position = is_tree_find(key, tree);
        if (position == NULL)
        {
            tree = is_tree_insert(tree, key, 1);
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

/*
 * istore from key and value intarrays
 * bot arrays must have the same length, NULLs are omitted
 * duplicate keys result in added values
 */
static Datum
istore_add_from_int_arrays(ArrayType *input1, ArrayType *input2)
{
    IStore *     out;
    Datum *      i_data1, *i_data2;
    bool *       nulls1, *nulls2;
    IStorePairs *pairs;
    int          i, n = 0, n1, n2;
    int16        i_typlen1, i_typlen2;
    bool         i_typbyval1, i_typbyval2;
    char         i_typalign1, i_typalign2;
    Oid          i_eltype1, i_eltype2;
    AvlNode *    tree;
    AvlNode *    position;
    int32        key, value;

    i_eltype1 = ARR_ELEMTYPE(input1);
    i_eltype2 = ARR_ELEMTYPE(input2);

    get_typlenbyvalalign(i_eltype1, &i_typlen1, &i_typbyval1, &i_typalign1);

    get_typlenbyvalalign(i_eltype2, &i_typlen2, &i_typbyval2, &i_typalign2);

    deconstruct_array(input1, i_eltype1, i_typlen1, i_typbyval1, i_typalign1, &i_data1, &nulls1, &n1);

    deconstruct_array(input2, i_eltype2, i_typlen2, i_typbyval2, i_typalign2, &i_data2, &nulls2, &n2);

    if (n1 != n2)
        elog(ERROR, "array dont have the same length");

    tree = NULL;

    for (i = 0; i < n1; ++i)
    {
        if (nulls1[i] || nulls2[i])
            continue;
        switch (i_eltype1)
        {
            case INT2OID: key = DatumGetInt16(i_data1[i]); break;
            case INT4OID: key = DatumGetInt32(i_data1[i]); break;
            case INT8OID:
			{
				key = DatumGetInt32(DirectFunctionCall1(int84, i_data1[i]));
				break;
			}
            default: elog(ERROR, "unsupported array type");
        }
        switch (i_eltype2)
        {
            case INT2OID: value = DatumGetInt16(i_data2[i]); break;
            case INT4OID: value = DatumGetInt32(i_data2[i]); break;
            default: elog(ERROR, "unsupported array type");
        }

        position = is_tree_find(key, tree);

        if (position == NULL)
        {
            tree = is_tree_insert(tree, key, value);
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

/*
 * bigistore from key and value intarrays
 */
PG_FUNCTION_INFO_V1(istore_array_add);
Datum istore_array_add(PG_FUNCTION_ARGS)
{
    Datum      result;
    ArrayType *input1, *input2;

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
 * istore from row(array, array)
 */
PG_FUNCTION_INFO_V1(row_to_istore);
Datum row_to_istore(PG_FUNCTION_ARGS)
{
    HeapTupleHeader     td;
    Oid                 tupType;
    int32               tupTypmod;
    TupleDesc           tupdesc;
    HeapTupleData       tmptup,
                       *tuple;
    int                 i;

    Datum               composite = PG_GETARG_DATUM(0),
                        result;
    ArrayType          *input[2];

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    td = DatumGetHeapTupleHeader(composite);

    /* Extract rowtype info and find a tupdesc */
    tupType = HeapTupleHeaderGetTypeId(td);
    tupTypmod = HeapTupleHeaderGetTypMod(td);
    tupdesc = lookup_rowtype_tupdesc(tupType, tupTypmod);

    if (tupdesc->natts != 2)
        elog(ERROR, "expected two arrays in wholerow");

    /* Build a temporary HeapTuple control structure */
    tmptup.t_len = HeapTupleHeaderGetDatumLength(td);
    tmptup.t_data = td;
    tuple = &tmptup;

    for (i = 0; i < tupdesc->natts; i++)
    {
        Datum       val;
        bool        isnull;
        Form_pg_attribute att = TupleDescAttr(tupdesc, i);
        Oid         basetype;

        if (att->attisdropped)
            goto fail;

        basetype = get_base_element_type(att->atttypid);
        if (basetype == InvalidOid)
            elog(ERROR, "expected only arrays in wholerow");

        val = heap_getattr(tuple, i + 1, tupdesc, &isnull);

        if (isnull)
            goto fail;
        else
            input[i] = DatumGetArrayTypeP(val);
    }

    result = istore_add_from_int_arrays(input[0], input[1]);
    if (result == 0)
        goto fail;

    ReleaseTupleDesc(tupdesc);
    return result;

fail:
    ReleaseTupleDesc(tupdesc);
    PG_RETURN_NULL();
}

/*
 * Common initialization function for the various set-returning
 * funcs. fcinfo is only passed if the function is to return a
 * composite; it will be used to look up the return tupledesc.
 * we stash a copy of the istore in the multi-call context in
 * case it was originally toasted.
 */

static void
setup_firstcall(FuncCallContext *funcctx, IStore *is, FunctionCallInfo fcinfo)
{
    MemoryContext oldcontext;
    IStore *      st;

    oldcontext = MemoryContextSwitchTo(funcctx->multi_call_memory_ctx);

    st = palloc0(ISTORE_SIZE(is, IStorePair));
    memcpy(st, is, ISTORE_SIZE(is, IStorePair));

    funcctx->user_fctx = (void *) st;

    if (fcinfo)
    {
        TupleDesc tupdesc;

        /* Build a tuple descriptor for our result type */
        if (get_call_result_type(fcinfo, NULL, &tupdesc) != TYPEFUNC_COMPOSITE)
            elog(ERROR, "return type must be a row type");

        funcctx->tuple_desc = BlessTupleDesc(tupdesc);
    }

    MemoryContextSwitchTo(oldcontext);
}

/*
 * return keys and values as a set
 */
PG_FUNCTION_INFO_V1(istore_each);
Datum istore_each(PG_FUNCTION_ARGS)
{
    FuncCallContext *funcctx;
    IStore *         is;
    int              i;
    IStorePair *     pairs;

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
        Datum     res, dvalues[2];
        bool      nulls[2] = { false, false };
        HeapTuple tuple;

        dvalues[0] = Int32GetDatum(pairs[i].key);
        dvalues[1] = Int32GetDatum(pairs[i].val);
        tuple      = heap_form_tuple(funcctx->tuple_desc, dvalues, nulls);
        res        = HeapTupleGetDatum(tuple);

        SRF_RETURN_NEXT(funcctx, PointerGetDatum(res));
    }

    SRF_RETURN_DONE(funcctx);
}

/*
 * fill missing keys in a range
 */
PG_FUNCTION_INFO_V1(istore_fill_gaps);
Datum istore_fill_gaps(PG_FUNCTION_ARGS)
{

    IStore *    is, *result;
    IStorePair *pairs;

    IStorePairs *creator = NULL;

    int up_to, fill_with, index1 = 0, index2 = 0;

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

    for (index1 = 0; index1 <= up_to; ++index1)
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

/*
 * rolling sum over keys
 */
PG_FUNCTION_INFO_V1(istore_accumulate);
Datum istore_accumulate(PG_FUNCTION_ARGS)
{

    IStore *    is, *result;
    IStorePair *pairs;

    IStorePairs *creator = NULL;

    int    index1 = 0, index2 = 0;
    size_t size      = 0;
    int32  start_key = 0, sum = 0, end_key = -1;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    is = PG_GETARG_IS(0);

    pairs   = FIRST_PAIR(is, IStorePair);
    creator = palloc0(sizeof *creator);

    if (is->len > 0)
    {
        start_key = pairs[0].key;
        end_key   = PG_NARGS() == 1 ? pairs[is->len - 1].key : PG_GETARG_INT32(1);
        size      = start_key > end_key ? 0 : (end_key - start_key + 1);
    }

    istore_pairs_init(creator, size);

    for (index1 = start_key; index1 <= end_key; ++index1)
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

/*
 * construct a bigistore with a key range and a fixed value
 */
PG_FUNCTION_INFO_V1(istore_seed);
Datum istore_seed(PG_FUNCTION_ARGS)
{

    IStore *result;

    IStorePairs *creator = NULL;

    int from, up_to, fill_with, index1 = 0;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    from      = PG_GETARG_INT32(0);
    up_to     = PG_GETARG_INT32(1);
    fill_with = PG_GETARG_INT64(2);
    creator   = palloc0(sizeof *creator);

    if (up_to < from)
        elog(ERROR, "parameter upto must be >= from");

    if (from < 0)
        elog(ERROR, "parameter from must be >= 0");

    istore_pairs_init(creator, up_to - from + 1);

    for (index1 = from; index1 <= up_to; ++index1)
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
Datum istore_val_larger(PG_FUNCTION_ARGS)
{
    IStore *is1, *is2;

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4larger, int4up));
}

/*
 * Merge two istores by extraccting the smaller values
 */
PG_FUNCTION_INFO_V1(istore_val_smaller);
Datum istore_val_smaller(PG_FUNCTION_ARGS)
{
    IStore *is1, *is2;

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    PG_RETURN_POINTER(istore_merge(is1, is2, int4smaller, int4up));
}

/*
 * return array of keys
 */
PG_FUNCTION_INFO_V1(istore_akeys);
Datum istore_akeys(PG_FUNCTION_ARGS)
{
    IStore *    is;
    IStorePair *pairs;
    Datum *     d;
    int         index;
    ArrayType * a;

    is    = PG_GETARG_IS(0);
    index = 0;

    if (is->len == 0)
    {
        a = construct_empty_array(INT4OID);
        PG_RETURN_POINTER(a);
    }

    pairs = FIRST_PAIR(is, IStorePair);
    d     = (Datum *) palloc(sizeof(Datum) * is->len);

    while (index < is->len)
    {
        d[index] = pairs[index].key;
        ++index;
    }

    a = construct_array(d, is->len, INT4OID, sizeof(int32), true, 'i');
    PG_RETURN_POINTER(a);
}

/*
 * return array of values
 */
PG_FUNCTION_INFO_V1(istore_avals);
Datum istore_avals(PG_FUNCTION_ARGS)
{
    IStore *    is;
    IStorePair *pairs;
    Datum *     d;
    int         index;
    ArrayType * a;

    is    = PG_GETARG_IS(0);
    index = 0;

    if (is->len == 0)
    {
        a = construct_empty_array(INT4OID);
        PG_RETURN_POINTER(a);
    }

    pairs = FIRST_PAIR(is, IStorePair);
    d     = (Datum *) palloc(sizeof(Datum) * is->len);

    while (index < is->len)
    {
        d[index] = pairs[index].val;
        ++index;
    }

    a = construct_array(d, is->len, INT4OID, sizeof(int32), true, 'i');
    PG_RETURN_POINTER(a);
}

/*
 * return set of keys
 */
PG_FUNCTION_INFO_V1(istore_skeys);
Datum istore_skeys(PG_FUNCTION_ARGS)
{
    IStore *         is;
    FuncCallContext *funcctx;
    IStorePair *     pairs;
    int              i;

    if (SRF_IS_FIRSTCALL())
    {
        is      = PG_GETARG_IS(0);
        funcctx = SRF_FIRSTCALL_INIT();
        setup_firstcall(funcctx, is, NULL);
    }

    funcctx = SRF_PERCALL_SETUP();
    is      = (IStore *) funcctx->user_fctx;
    i       = funcctx->call_cntr;
    pairs   = FIRST_PAIR(is, IStorePair);

    if (i < is->len)
        SRF_RETURN_NEXT(funcctx, Int32GetDatum(pairs[i].key));

    SRF_RETURN_DONE(funcctx);
}

/*
 * return set of values
 */
PG_FUNCTION_INFO_V1(istore_svals);
Datum istore_svals(PG_FUNCTION_ARGS)
{
    IStore *         is;
    FuncCallContext *funcctx;
    IStorePair *     pairs;
    int              i;

    if (SRF_IS_FIRSTCALL())
    {
        is      = PG_GETARG_IS(0);
        funcctx = SRF_FIRSTCALL_INIT();
        setup_firstcall(funcctx, is, NULL);
    }

    funcctx = SRF_PERCALL_SETUP();
    is      = (IStore *) funcctx->user_fctx;
    i       = funcctx->call_cntr;
    pairs   = FIRST_PAIR(is, IStorePair);

    if (i < is->len)
        SRF_RETURN_NEXT(funcctx, Int32GetDatum(pairs[i].val));

    SRF_RETURN_DONE(funcctx);
}

PG_FUNCTION_INFO_V1(istore_length);
Datum istore_length(PG_FUNCTION_ARGS)
{
    const IStore *is = PG_GETARG_IS(0);
    PG_RETURN_INT32(is->len);
}

/*
 * return palloced array of alternating key values
 * returns NULL if istore is empty
 */
static inline Datum *
istore_key_val_datums(IStore *is)
{
    Datum *     d;
    IStorePair *pairs;
    int         index = 0;

    if (is->len == 0)
        return NULL;

    pairs = FIRST_PAIR(is, IStorePair);
    d     = (Datum *) palloc(sizeof(Datum) * is->len * 2);

    while (index < is->len)
    {
        d[index * 2]     = pairs[index].key;
        d[index * 2 + 1] = pairs[index].val;
        ++index;
    }
    return d;
}

PG_FUNCTION_INFO_V1(istore_to_array);
Datum istore_to_array(PG_FUNCTION_ARGS)
{
    IStore *   is;
    Datum *    d;
    ArrayType *a;

    is = PG_GETARG_IS(0);

    if (is->len == 0)
    {
        a = construct_empty_array(INT4OID);
        PG_RETURN_POINTER(a);
    }
    d = istore_key_val_datums(is);
    a = construct_array(d, is->len * 2, INT4OID, sizeof(int32), true, 'i');
    PG_RETURN_POINTER(a);
}

PG_FUNCTION_INFO_V1(istore_to_matrix);
Datum istore_to_matrix(PG_FUNCTION_ARGS)
{
    IStore *   is;
    Datum *    d;
    int        out_size[2] = { 0, 2 };
    int        lb[2]       = { 1, 1 };
    ArrayType *a;

    is = PG_GETARG_IS(0);

    if (is->len == 0)
    {
        a = construct_empty_array(INT4OID);
        PG_RETURN_POINTER(a);
    }

    out_size[0] = is->len;
    d           = istore_key_val_datums(is);
    a           = construct_md_array(d, NULL, 2, out_size, lb, INT4OID, sizeof(int32), true, 'i');
    PG_RETURN_POINTER(a);
}

PG_FUNCTION_INFO_V1(istore_slice);
Datum istore_slice(PG_FUNCTION_ARGS)
{
    IStorePair * pairs;
    IStore *     result;
    IStore *     is      = PG_GETARG_IS(0);
    IStorePairs *creator = NULL;
    ArrayType *  a       = PG_GETARG_ARRAYTYPE_P_COPY(1);
    int32 *      ar      = (int32 *) ARR_DATA_PTR(a);
    int          alen    = ArrayGetNItems(ARR_NDIM(a), ARR_DIMS(a));
    int          index1 = 0, index2 = 0;
    bool         found = false;

    if (ARR_HASNULL(a) && array_contains_nulls(a))
        ereport(ERROR, (errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED), errmsg("array must not contain nulls")));

    pairs   = FIRST_PAIR(is, IStorePair);
    creator = palloc0(sizeof *creator);

    istore_pairs_init(creator, MIN(is->len, alen));

    if (alen > 1)
        qsort((void *) ar, alen, sizeof(int32), is_int32_arr_comp);

    while (index1 < is->len && index2 < alen)
    {
        if (pairs[index1].key < ar[index2])
        {
            ++index1;
        }
        else if (pairs[index1].key > ar[index2])
        {
            ++index2;
        }
        else
        {
            istore_pairs_insert(creator, pairs[index1].key, pairs[index1].val);
            ++index1;
            ++index2;
            found = true;
        }
    }
    if (found)
    {
        FINALIZE_ISTORE(result, creator);
        PG_RETURN_POINTER(result);
    }
    else
        PG_RETURN_EMPTY_ISTORE();
}

PG_FUNCTION_INFO_V1(istore_slice_min_max);
Datum istore_slice_min_max(PG_FUNCTION_ARGS)
{
    int32   min = PG_GETARG_INT32(1);
    int32   max = PG_GETARG_INT32(2);
    IStore *is  = PG_GETARG_IS_COPY(0);

    int min_idx = 0;
    int i       = 0;
    int len     = is->len;

    IStorePair *pairs;
    pairs = FIRST_PAIR(is, IStorePair);

    if (min > max)
        ereport(ERROR, (errcode(ERRCODE_SYNTAX_ERROR), errmsg("min must be less or equal max")));

    if (is->len <= 0 || pairs[is->len - 1].key < min || pairs[0].key > max)
        PG_RETURN_EMPTY_ISTORE();

    if (pairs[0].key >= min && pairs[is->len - 1].key <= max)
        PG_RETURN_POINTER(is);

    is->buflen = 0;
    is->len    = 0;

    // skip pairs lower than min
    while (pairs[i].key < min && ++i)
        ;
    min_idx = i;

    for (; pairs[i].key <= max && i < len; i++)
    {
        ++is->len;
        is->buflen += is_pair_buf_len(pairs + i);
    }

    Assert(is->len > 0);

    if (is->len == 0)
        PG_RETURN_EMPTY_ISTORE();

    if (min_idx > 0)
        memmove(pairs, pairs + min_idx, (is->len * sizeof(IStorePair)));

    SET_VARSIZE(is, ISHDRSZ + (is->len * sizeof(IStorePair)));
    PG_RETURN_POINTER(is);
}

PG_FUNCTION_INFO_V1(istore_slice_to_array);
Datum istore_slice_to_array(PG_FUNCTION_ARGS)
{
    IStorePair *pair;
    IStore *    is   = PG_GETARG_IS(0);
    ArrayType * a    = PG_GETARG_ARRAYTYPE_P(1);
    int32 *     ar   = (int32 *) ARR_DATA_PTR(a);
    int         alen = ArrayGetNItems(ARR_NDIM(a), ARR_DIMS(a));
    int         lbs[1];
    int         dims[1];
    int         i;
    Datum *     out_datums;
    bool *      out_nulls;
    ArrayType * aout;

    if (ARR_HASNULL(a) && array_contains_nulls(a))
        ereport(ERROR, (errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED), errmsg("array must not contain nulls")));

    out_datums = palloc(sizeof(Datum) * alen);
    out_nulls  = palloc(sizeof(bool) * alen);
    dims[0]    = alen;
    lbs[0]     = 1;

    for (i = 0; i < alen; ++i)
    {
        if ((pair = istore_find(is, ar[i], NULL)) == NULL)
        {
            out_datums[i] = (Datum) 0;
            out_nulls[i]  = true;
        }
        else
        {
            out_datums[i] = pair->val;
            out_nulls[i]  = false;
        }
    }

    aout = construct_md_array(out_datums, out_nulls, 1, dims, lbs, INT4OID, sizeof(int32), true, 'i');

    PG_RETURN_POINTER(aout);
}

static IStore *
istore_clamp_pass(IStore *is, int32 clamp_key, int delta_dir)
{
    IStore *    result_is;
    IStorePair *pairs;
    IStorePairs creator;
    int32       clamp_sum = 0;
    int         index = 0, count = 0, delta_buflen = 0;

    /* short circuit out of the funciton if there is nothing to clamp */
    if (delta_dir > 0 && FIRST_PAIR(is, IStorePair)->key >= clamp_key)
        return is;
    if (delta_dir < 0 && LAST_PAIR(is, IStorePair)->key <= clamp_key)
        return is;

    pairs = FIRST_PAIR(is, IStorePair);
    index = delta_dir > 0 ? 0 : is->len - 1;
    while (((delta_dir > 0) && (index < is->len && pairs[index].key <= clamp_key)) ||
           ((delta_dir < 0) && (index >= 0 && pairs[index].key >= clamp_key)))
    {
        INTPL(pairs[index].val, clamp_sum, clamp_sum);
        delta_buflen += is_pair_buf_len(pairs + index);
        index += delta_dir, count++;
    }

    /* back to the last element that is to be clamped */
    index -= delta_dir, count--;

    /* copy survivors into a new spot */
    if (delta_dir > 0)
        pairs = pairs + index;

    creator = (IStorePairs){ .pairs = pairs, .buflen = is->buflen - delta_buflen, .used = is->len - count };
    FINALIZE_ISTORE_BASE(result_is, (&creator), IStorePair);

    /* put the clamp_sum in the clamp-key place */
    pairs      = delta_dir > 0 ? FIRST_PAIR(result_is, IStorePair) : LAST_PAIR(result_is, IStorePair);
    pairs->key = clamp_key;
    pairs->val = clamp_sum;
    result_is->buflen += is_pair_buf_len(pairs);

    return result_is;
}

PG_FUNCTION_INFO_V1(istore_clamp_below);
Datum istore_clamp_below(PG_FUNCTION_ARGS)
{
    PG_RETURN_POINTER(istore_clamp_pass(PG_GETARG_IS(0), PG_GETARG_INT32(1), 1));
}

PG_FUNCTION_INFO_V1(istore_clamp_above);
Datum istore_clamp_above(PG_FUNCTION_ARGS)
{
    PG_RETURN_POINTER(istore_clamp_pass(PG_GETARG_IS(0), PG_GETARG_INT32(1), -1));
}

PG_FUNCTION_INFO_V1(istore_delete);
Datum istore_delete(PG_FUNCTION_ARGS)
{
    IStorePair *pair;
    IStore *    is  = PG_GETARG_IS_COPY(0);
    int32       key = PG_GETARG_INT32(1);
    int         del_off;

    if ((pair = istore_find(is, key, &del_off)))
    {
        --is->len;
        is->buflen -= is_pair_buf_len(pair);
        if (is->len > del_off)
            memmove(pair, pair + 1, (is->len - del_off) * sizeof(IStorePair));
    }
    SET_VARSIZE(is, ISHDRSZ + (is->len * sizeof(IStorePair)));
    PG_RETURN_POINTER(is);
}

PG_FUNCTION_INFO_V1(istore_delete_array);
Datum istore_delete_array(PG_FUNCTION_ARGS)
{
    IStorePair *pairs;
    IStore *    is       = PG_GETARG_IS_COPY(0);
    ArrayType * a        = PG_GETARG_ARRAYTYPE_P_COPY(1);
    int32 *     ar       = (int32 *) ARR_DATA_PTR(a);
    int         alen     = ArrayGetNItems(ARR_NDIM(a), ARR_DIMS(a));
    int         is_index = 0, ar_index = 0;

    if (ARR_HASNULL(a) && array_contains_nulls(a))
        ereport(ERROR, (errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED), errmsg("array must not contain nulls")));

    pairs = FIRST_PAIR(is, IStorePair);

    if (alen > 1)
        qsort((void *) ar, alen, sizeof(int32), is_int32_arr_comp);

    while (is_index < is->len && ar_index < alen)
    {
        if (pairs[is_index].key < ar[ar_index])
        {
            ++is_index;
        }
        else if (pairs[is_index].key > ar[ar_index])
        {
            ++ar_index;
        }
        else
        {
            --is->len;
            is->buflen -= is_pair_buf_len(pairs + is_index);
            if (is->len > is_index)
                memmove(pairs + is_index, pairs + is_index + 1, (is->len - is_index) * sizeof(IStorePair));

            ++ar_index;
        }
    }

    SET_VARSIZE(is, ISHDRSZ + (is->len * sizeof(IStorePair)));
    PG_RETURN_POINTER(is);
}

PG_FUNCTION_INFO_V1(istore_delete_istore);
Datum istore_delete_istore(PG_FUNCTION_ARGS)
{
    IStorePair *pairs, *delpairs;
    IStore *    is    = PG_GETARG_IS_COPY(0);
    IStore *    isdel = PG_GETARG_IS(1);

    int index1 = 0, index2 = 0;

    pairs    = FIRST_PAIR(is, IStorePair);
    delpairs = FIRST_PAIR(isdel, IStorePair);

    while (index1 < is->len && index2 < isdel->len)
    {
        if (pairs[index1].key < delpairs[index2].key)
        {
            ++index1;
        }
        else if (pairs[index1].key > delpairs[index2].key)
        {
            ++index2;
        }
        else
        {
            if (pairs[index1].val == delpairs[index2].val)
            {
                --is->len;
                is->buflen -= is_pair_buf_len(pairs + index1);
                if (is->len > index1)
                    memmove(pairs + index1, pairs + index1 + 1, (is->len - index1) * sizeof(IStorePair));
                ++index2;
            }
            else
            {
                ++index2;
                ++index1;
            }
        }
    }

    SET_VARSIZE(is, ISHDRSZ + (is->len * sizeof(IStorePair)));
    PG_RETURN_POINTER(is);
}

PG_FUNCTION_INFO_V1(istore_exists_any);
Datum istore_exists_any(PG_FUNCTION_ARGS)
{
    IStore *   is   = PG_GETARG_IS(0);
    ArrayType *a    = PG_GETARG_ARRAYTYPE_P(1);
    int32 *    ar   = (int32 *) ARR_DATA_PTR(a);
    int        alen = ArrayGetNItems(ARR_NDIM(a), ARR_DIMS(a));
    int        i    = 0;

    if (ARR_HASNULL(a) && array_contains_nulls(a))
        ereport(ERROR, (errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED), errmsg("array must not contain nulls")));

    for (i = 0; i < alen; i++)
    {
        if (istore_find(is, ar[i], NULL) != NULL)
            PG_RETURN_BOOL(true);
    }

    PG_RETURN_BOOL(false);
}

PG_FUNCTION_INFO_V1(istore_exists_all);
Datum istore_exists_all(PG_FUNCTION_ARGS)
{
    IStore *   is   = PG_GETARG_IS(0);
    ArrayType *a    = PG_GETARG_ARRAYTYPE_P(1);
    int32 *    ar   = (int32 *) ARR_DATA_PTR(a);
    int        alen = ArrayGetNItems(ARR_NDIM(a), ARR_DIMS(a));
    int        i;

    if (ARR_HASNULL(a) && array_contains_nulls(a))
        ereport(ERROR, (errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED), errmsg("array must not contain nulls")));

    for (i = 0; i < alen; i++)
    {
        if (istore_find(is, ar[i], NULL) == NULL)
            PG_RETURN_BOOL(false);
    }

    PG_RETURN_BOOL(true);
}

int
is_int32_arr_comp(const void *a, const void *b)
{
    if (*(const int32 *) a == *(const int32 *) b)
        return 0;
    return (*(const int32 *) a > *(const int32 *) b) ? 1 : -1;
}

static bool
is_istore_in_range(IStore *is, int32 *lower, int32 *upper, bool inclusive)
{
    IStorePair *pairs;
    int32       val;

    if (lower != NULL && upper != NULL && *lower > *upper)
        return false;

    if (is->len == 0)
        return true;

    pairs = FIRST_PAIR(is, IStorePair);
    Assert(pairs != NULL);

    for (int i = 0; i < is->len; i++)
    {
        val = pairs[i].val;
        if (lower != NULL && (val < *lower || (!inclusive && val == *lower)))
            return false;

        if (upper != NULL && (val > *upper || (!inclusive && val == *upper)))
            return false;
    }

    return true;
}

static IStore *
istore_limit(IStore *is, int32 *min, int32 *max)
{
    IStore *     result;
    IStorePair * pairs;
    IStorePairs *new_pairs;
    int32        val;

    new_pairs = palloc(sizeof(IStorePairs));
    istore_pairs_init(new_pairs, is->len);

    if ((min != NULL && max != NULL && *min > *max) || is->len == 0)
    {
        FINALIZE_ISTORE(result, new_pairs);
        return result;
    }

    pairs = FIRST_PAIR(is, IStorePair);
    Assert(pairs != NULL);

    for (int i = 0; i < is->len; i++)
    {
        val = pairs[i].val;
        if (min != NULL && val < *min)
            val = *min;
        else if (max != NULL && val > *max)
            val = *max;
        istore_pairs_insert(new_pairs, pairs[i].key, val);
    }
    FINALIZE_ISTORE(result, new_pairs);
    return result;
}

PG_FUNCTION_INFO_V1(istore_in_range);
Datum istore_in_range(PG_FUNCTION_ARGS)
{
    IStore *is    = PG_GETARG_IS(0);
    int32   lower = PG_GETARG_INT32(1);
    int32   upper = PG_GETARG_INT32(2);
    bool    result;

    result = is_istore_in_range(is, &lower, &upper, true);
    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(istore_less_than);
Datum istore_less_than(PG_FUNCTION_ARGS)
{
    IStore *is    = PG_GETARG_IS(0);
    int32   upper = PG_GETARG_INT32(1);
    bool    result;

    result = is_istore_in_range(is, NULL, &upper, false);
    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(istore_less_than_or_equal);
Datum istore_less_than_or_equal(PG_FUNCTION_ARGS)
{
    IStore *is    = PG_GETARG_IS(0);
    int32   upper = PG_GETARG_INT32(1);
    bool    result;

    result = is_istore_in_range(is, NULL, &upper, true);
    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(istore_greater_than);
Datum istore_greater_than(PG_FUNCTION_ARGS)
{
    IStore *is    = PG_GETARG_IS(0);
    int32   lower = PG_GETARG_INT32(1);
    bool    result;

    result = is_istore_in_range(is, &lower, NULL, false);
    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(istore_greater_than_or_equal);
Datum istore_greater_than_or_equal(PG_FUNCTION_ARGS)
{
    IStore *is    = PG_GETARG_IS(0);
    int32   lower = PG_GETARG_INT32(1);
    bool    result;

    result = is_istore_in_range(is, &lower, NULL, true);
    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(istore_floor);
Datum istore_floor(PG_FUNCTION_ARGS)
{
    IStore *result;
    IStore *is  = PG_GETARG_IS(0);
    int32   min = PG_GETARG_INT32(1);

    result = istore_limit(is, &min, NULL);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_ceiling);
Datum istore_ceiling(PG_FUNCTION_ARGS)
{
    IStore *result;
    IStore *is  = PG_GETARG_IS(0);
    int32   max = PG_GETARG_INT32(1);

    result = istore_limit(is, NULL, &max);
    PG_RETURN_POINTER(result);
}
