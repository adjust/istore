#include "istore.h"

PG_MODULE_MAGIC;

uint8
null_type_for(uint8 type)
{
    switch (type)
    {
        case PLAIN_ISTORE:    return NULL_VAL_ISTORE;
        case DEVICE_ISTORE:   return NULL_DEVICE_ISTORE;
        case COUNTRY_ISTORE:  return NULL_COUNTRY_ISTORE;
        case OS_NAME_ISTORE:  return NULL_OS_NAME_ISTORE;
        case C_ISTORE:        return NULL_C_ISTORE;
        case C_ISTORE_COHORT: return NULL_C_ISTORE;
        default:
            elog(ERROR, "unknown istore type");
    }
}

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

PG_FUNCTION_INFO_V1(is_exist);
Datum
is_exist(PG_FUNCTION_ARGS)
{
    IStore *in;
    int     key;
    bool    found;
    /*TODO: NULL handling*/
    in  = PG_GETARG_IS(0);
    GET_KEYARG_BY_TYPE(in, key);
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
    GET_KEYARG_BY_TYPE(in, key);
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
    /* throw error if istore types differ? */
    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);
    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200, is1->type);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val, is1->type);
            ++index2;
        }
        else
        {
            if (pairs1[index1].null || pairs2[index2].null)
                is_pairs_insert(
                    creator,
                    pairs1[index1].key,
                    0,
                    null_type_for(is1->type)
                );
            else
                is_pairs_insert(
                    creator,
                    pairs1[index1].key,
                    pairs1[index1].val + pairs2[index2].val,
                    is1->type
                );
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val, is2->type);
        ++index2;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(is_sum);
Datum
is_sum(PG_FUNCTION_ARGS)
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
    /* throw error if istore types differ? */
    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);
    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200, is1->type);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val, is1->type);
            ++index2;
        }
        else
        {
            is_pairs_insert(
                creator,
                pairs1[index1].key,
                pairs1[index1].val + pairs2[index2].val,
                is1->type
            );
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val, is2->type);
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
    is_pairs_init(creator, 200, is->type);
    while (index < is->len)
    {
        if (pairs[index].null)
            is_pairs_insert(creator, pairs[index].key, 0, null_type_for(is->type));
        else
            is_pairs_insert(creator, pairs[index].key, pairs[index].val + int_arg, is->type);
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
    is_pairs_init(creator, 200, is1->type);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, -pairs2[index2].val, is1->type);
            ++index2;
        }
        else
        {
            if (pairs1[index1].null || pairs2[index2].null)
                is_pairs_insert(
                    creator,
                    pairs1[index1].key,
                    0,
                    null_type_for(is1->type)
                );
            else
                is_pairs_insert(
                    creator,
                    pairs1[index1].key,
                    pairs1[index1].val - pairs2[index2].val,
                    is1->type
                );
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, -pairs2[index2].val, is2->type);
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
    is_pairs_init(creator, 200, is->type);
    while (index < is->len)
    {
        if (pairs[index].null)
            is_pairs_insert(creator, pairs[index].key, 0, null_type_for(is->type));
        else
            is_pairs_insert(creator, pairs[index].key, pairs[index].val - int_arg, is->type);
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
    uint8   nulltype;
    /* TODO NULL handling */
    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);
    pairs1 = FIRST_PAIR(is1);
    pairs2 = FIRST_PAIR(is2);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200, is1->type);
    nulltype = null_type_for(is1->type);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs1[index1].key, 0, nulltype);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            is_pairs_insert(creator, pairs2[index2].key, 0, nulltype);
            ++index2;
        }
        else
        {
            if (pairs1[index1].null || pairs2[index2].null)
                is_pairs_insert(
                    creator,
                    pairs1[index1].key,
                    0,
                    null_type_for(is1->type)
                );
            else
                is_pairs_insert(
                    creator,
                    pairs1[index1].key,
                    pairs1[index1].val * pairs2[index2].val,
                    is1->type
                );
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        is_pairs_insert(creator, pairs1[index1].key, 0, nulltype);
        ++index1;
    }
    while (index2 < is2->len)
    {
        is_pairs_insert(creator, pairs2[index2].key, 0, nulltype);
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
    is_pairs_init(creator, 200, is->type);
    while (index < is->len)
    {
        if (pairs[index].null)
            is_pairs_insert(creator, pairs[index].key, 0, null_type_for(is->type));
        else
            is_pairs_insert(creator, pairs[index].key, pairs[index].val * int_arg, is->type);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

static Datum
type_istore_from_int_array(ArrayType *input, int type)
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
        switch (type)
        {
            case PLAIN_ISTORE:
                key = DatumGetInt32(i_data[i]);
                break;
            case DEVICE_ISTORE:
            case COUNTRY_ISTORE:
            case OS_NAME_ISTORE:
                key = DatumGetUInt8(i_data[i]);
                break;
        }
        if (key < 0)
            elog(ERROR, "cannot count array that has negative integers");
        position = is_tree_find(key, tree);
        if (position == NULL)
            tree = is_insert(key, 1, false, tree);
        else
            position->value += 1;
    }

    n = is_tree_length(tree);
    pairs = palloc0(sizeof *pairs);
    is_pairs_init(pairs, 200, type);
    is_tree_to_pairs(tree, pairs, 0);
    is_make_empty(tree);
    FINALIZE_ISTORE(result, pairs);
    PG_RETURN_POINTER(result);
}

static Datum
type_istore_from_text_array(ArrayType *input, int type)
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
    size_t   len;

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
        char    *str = NULL;
        if (nulls[i])
            continue;
        switch (type)
        {
            case PLAIN_ISTORE:
                elog(ERROR, "text array is not allowed for PLAIN_ISTORE");
                break;
            case DEVICE_ISTORE:
                DATUM_TO_CSTRING(i_data[i], str, len);
                key = get_device_type_num(str);
                break;
            case COUNTRY_ISTORE:
                DATUM_TO_CSTRING(i_data[i], str, len);
                key = get_country_num(str);
                break;
            case OS_NAME_ISTORE:
                DATUM_TO_CSTRING(i_data[i], str, len);
                key = get_os_name_num(str);
                break;
        }
        if (key < 0)
            elog(ERROR, "cannot count array that has negative integers");
        position = is_tree_find(key, tree);
        if (position == NULL)
            tree = is_insert(key, 1, false, tree);
        else
            position->value += 1;
    }

    n = is_tree_length(tree);
    pairs = palloc0(sizeof *pairs);
    is_pairs_init(pairs, 200, type);
    is_tree_to_pairs(tree, pairs, 0);
    is_make_empty(tree);
    FINALIZE_ISTORE(result, pairs);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_from_array);
Datum
istore_from_array(PG_FUNCTION_ARGS)
{
    ArrayType *input;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();
    input = PG_GETARG_ARRAYTYPE_P(0);
    return type_istore_from_int_array(input, PLAIN_ISTORE);
}

PG_FUNCTION_INFO_V1(device_istore_from_array);
Datum
device_istore_from_array(PG_FUNCTION_ARGS)
{
    ArrayType *input;
    Oid        i_eltype;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    input = PG_GETARG_ARRAYTYPE_P(0);
    i_eltype = ARR_ELEMTYPE(input);
    if (i_eltype == TEXTOID)
        return type_istore_from_text_array(input, DEVICE_ISTORE);
    else
        return type_istore_from_int_array(input, DEVICE_ISTORE);
}

PG_FUNCTION_INFO_V1(country_istore_from_array);
Datum
country_istore_from_array(PG_FUNCTION_ARGS)
{
    ArrayType *input;
    Oid        i_eltype;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    input = PG_GETARG_ARRAYTYPE_P(0);
    i_eltype = ARR_ELEMTYPE(input);
    if (i_eltype == TEXTOID)
        return type_istore_from_text_array(input, COUNTRY_ISTORE);
    else
        return type_istore_from_int_array(input, COUNTRY_ISTORE);
}

PG_FUNCTION_INFO_V1(os_name_istore_from_array);
Datum
os_name_istore_from_array(PG_FUNCTION_ARGS)
{
    ArrayType *input;
    Oid        i_eltype;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    input = PG_GETARG_ARRAYTYPE_P(0);
    i_eltype = ARR_ELEMTYPE(input);
    if (i_eltype == TEXTOID)
        return type_istore_from_text_array(input, OS_NAME_ISTORE);
    else
        return type_istore_from_int_array(input, OS_NAME_ISTORE);
}

Datum
array_to_istore(Datum *data, int count, bool *nulls)
{
    IStore *out,
           *istore;
    AvlTree  tree;
    int i,
        type = -1,
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
        if (type == -1)
            type = istore->type;
        else if (type != istore->type)
            elog(ERROR, "inconsistent istore types in array");

        for (index = 0; index < istore->len; ++index)
        {
            payload = FIRST_PAIR(istore) + index;
            position = is_tree_find(payload->key, tree);
            if (position == NULL)
                tree = is_insert(payload->key, payload->val, false, tree);
            else
                position->value += payload->val;
        }
    }
    pairs = palloc(sizeof *pairs);
    is_pairs_init(pairs, 200, type);
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
        key   = DatumGetInt32(i_data1[i]);
        value = DatumGetInt64(i_data2[i]);
        position = is_tree_find(key, tree);
        if (position == NULL)
            tree = is_insert(key, value, false, tree);
        else
            position->value += value;
    }
    pairs = palloc(sizeof *pairs);
    is_pairs_init(pairs, 200, PLAIN_ISTORE);
    is_tree_to_pairs(tree, pairs, 0);
    is_make_empty(tree);
    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}
