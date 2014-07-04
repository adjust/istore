#include "istore.h"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(istore_sum_up);
Datum
istore_sum_up(PG_FUNCTION_ARGS)
{
    IStore  *is;
    ISPair  *pairs;
    long    result = 0;
    int     index = 0;
    /* TODO NULL handling */
    is     = PG_GETARG_IS(0);
    pairs = FIRST_PAIR(is);
    while (index < is->len)
    {
        result += pairs[index].val;
        ++index;
    }
    PG_RETURN_INT64(result);
}

ISPair*
is_find(IStore *is, long key)
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

PG_FUNCTION_INFO_V1(is_exist);
Datum
is_exist(PG_FUNCTION_ARGS)
{
    IStore *in;
    int     key;
    bool    found;
    /*TODO: NULL handling*/
    in  = PG_GETARG_IS(0);
    key = PG_GETARG_INT32(1);
    if (is_find(in, key))
        found = true;
    else
        found = false;
    PG_RETURN_BOOL(found);
}

PG_FUNCTION_INFO_V1(is_fetchval);
Datum
is_fetchval(PG_FUNCTION_ARGS)
{
    IStore *in;
    int     key;
    ISPair  *pair;
    /* TODO: NULL handling */
    in  = PG_GETARG_IS(0);
    key = PG_GETARG_INT32(1);
    if ((pair = is_find(in, key)) == NULL )
        PG_RETURN_NULL();
    else
        PG_RETURN_INT64(pair->val);
}

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
    /* TODO NULL handling */
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
            is_pairs_insert(
                creator,
                pairs1[index1].key,
                pairs1[index1].val + pairs2[index2].val
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
    /* TODO NULL handling */
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
    /* TODO NULL handling */
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
        is_pairs_insert(creator, pairs2[index2].key, -pairs2[index2].val);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

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
    /* TODO NULL handling */
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
    /* TODO NULL handling */
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
            is_pairs_insert_null(creator, pairs1[index1].key);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert_null(creator, pairs2[index2].key);
            ++index2;
        }
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
        is_pairs_insert_null(creator, pairs1[index1].key);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert_null(creator, pairs2[index2].key);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

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
    /* TODO NULL handling */
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

PG_FUNCTION_INFO_V1(istore_from_array);
Datum
istore_from_array(PG_FUNCTION_ARGS)
{
    IStore    *result;
    ArrayType *input;
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
    is_pairs_init(pairs, 100);
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
    pairs = palloc(sizeof *pairs);
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

    return array_to_istore(i_data, n, nulls);
}

PG_FUNCTION_INFO_V1(istore_agg_finalfn);
Datum
istore_agg_finalfn(PG_FUNCTION_ARGS)
{
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

    return array_to_istore(data, count, nulls);
}

PG_FUNCTION_INFO_V1(istore_array_add);
Datum
istore_array_add(PG_FUNCTION_ARGS)
{
    IStore    *out;
    ArrayType *input1,
              *input2;
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
    long       key,
               value;

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    input1 = PG_GETARG_ARRAYTYPE_P(0);
    input2 = PG_GETARG_ARRAYTYPE_P(1);

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
    else if (n1 == 0 || (n1 == 1 && nulls1[0]))
        PG_RETURN_NULL();
    else if (n2 == 0 || (n2 == 1 && nulls2[0]))
        PG_RETURN_NULL();

    tree = is_make_empty(NULL);

    for (i = 0; i < n1; ++i)
    {
        if (nulls1[i] || nulls2[i])
            continue;
        key   = DatumGetInt64(i_data1[i]);
        value = DatumGetInt64(i_data2[i]);
        position = is_tree_find(key, tree);
        if (position == NULL)
            tree = is_insert(key, value, tree);
        else
            position->value += value;
    }
    pairs = palloc(sizeof *pairs);
    is_pairs_init(pairs, 200);
    is_tree_to_pairs(tree, pairs, 0);
    is_make_empty(tree);
    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}
