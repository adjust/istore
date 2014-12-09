#include "istore.h"
#include "funcapi.h"

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

    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    is1 = PG_GETARG_IS(0);
    is2 = PG_GETARG_IS(1);

    if (is1->type != is2->type)
        elog(ERROR, "is_add istore types differ %d != %d", is1->type, is2->type );

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
                is_pairs_insert(creator, pairs1[index1].key, 0, null_type_for(is1->type));
            else
                is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val + pairs2[index2].val, is1->type);
            ++index1;
            ++index2;
        }
    }

    while (index1 < is1->len)
    {
        if (pairs1[index1].null)
            is_pairs_insert(creator, pairs1[index1].key, 0, null_type_for(is1->type));
        else
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
        ++index1;
    }
    while (index2 < is2->len)
    {
        if (pairs2[index2].null)
            is_pairs_insert(creator, pairs2[index2].key, 0, null_type_for(is2->type));
        else
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
        if (pairs1[index1].null)
            is_pairs_insert(creator, pairs1[index1].key, 0, null_type_for(is1->type));
        else
            is_pairs_insert(creator, pairs1[index1].key, pairs1[index1].val, is1->type);
        ++index1;
    }
    while (index2 < is2->len)
    {
        if (pairs2[index2].null)
            is_pairs_insert(creator, pairs2[index2].key, 0, null_type_for(is2->type));
        else
            is_pairs_insert(creator, pairs2[index2].key, pairs2[index2].val, is2->type);
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
            if (pairs1[index1].null || pairs2[index2].null || pairs2[index2].val == 0)
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
                    pairs1[index1].val / pairs2[index2].val,
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
    /* TODO NULL handling */
    is     = PG_GETARG_IS(0);
    int_arg = PG_GETARG_INT32(1);
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200, is->type);
    while (index < is->len)
    {
        if (pairs[index].null || int_arg == 0)
            is_pairs_insert(creator, pairs[index].key, 0, null_type_for(is->type));
        else
            is_pairs_insert(creator, pairs[index].key, pairs[index].val / int_arg, is->type);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

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
    /* TODO NULL handling */
    is     = PG_GETARG_IS(0);
    int_arg = PG_GETARG_INT64(1);
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);
    is_pairs_init(creator, 200, is->type);
    while (index < is->len)
    {
        if (pairs[index].null || int_arg == 0)
            is_pairs_insert(creator, pairs[index].key, 0, null_type_for(is->type));
        else
            is_pairs_insert(creator, pairs[index].key, pairs[index].val / int_arg, is->type);
        ++index;
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

static Datum
type_istore_from_int_array(ArrayType *input, uint8 type)
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
            // DEVICE_ISTORE
            // COUNTRY_ISTORE
            // OS_NAME_ISTORE
            default:
                key = DatumGetUInt8(i_data[i]);
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
type_istore_from_text_array(ArrayType *input, uint8 type)
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
    int      key = 0,
             i = 0;
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

    for (; i < n; ++i)
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
    Datum result;
    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();
    input = PG_GETARG_ARRAYTYPE_P(0);
    result = type_istore_from_int_array(input, PLAIN_ISTORE);
    if (result == 0)
        PG_RETURN_NULL();
    return result;
}

PG_FUNCTION_INFO_V1(device_istore_from_array);
Datum
device_istore_from_array(PG_FUNCTION_ARGS)
{
    ArrayType *input;
    Oid        i_eltype;
    Datum      result;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    input = PG_GETARG_ARRAYTYPE_P(0);
    i_eltype = ARR_ELEMTYPE(input);
    if (i_eltype == TEXTOID)
        result = type_istore_from_text_array(input, DEVICE_ISTORE);
    else
        result = type_istore_from_int_array(input, DEVICE_ISTORE);
    if (result == 0)
        PG_RETURN_NULL();
    return result;
}

PG_FUNCTION_INFO_V1(country_istore_from_array);
Datum
country_istore_from_array(PG_FUNCTION_ARGS)
{
    ArrayType *input;
    Oid        i_eltype;
    Datum      result;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    input = PG_GETARG_ARRAYTYPE_P(0);
    i_eltype = ARR_ELEMTYPE(input);
    if (i_eltype == TEXTOID)
        result = type_istore_from_text_array(input, COUNTRY_ISTORE);
    else
        result = type_istore_from_int_array(input, COUNTRY_ISTORE);
    if (result == 0)
        PG_RETURN_NULL();
    return result;
}

PG_FUNCTION_INFO_V1(os_name_istore_from_array);
Datum
os_name_istore_from_array(PG_FUNCTION_ARGS)
{
    ArrayType *input;
    Oid        i_eltype;
    Datum      result;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    input = PG_GETARG_ARRAYTYPE_P(0);
    i_eltype = ARR_ELEMTYPE(input);
    if (i_eltype == TEXTOID)
        result = type_istore_from_text_array(input, OS_NAME_ISTORE);
    else
        result = type_istore_from_int_array(input, OS_NAME_ISTORE);
    if (result == 0)
        PG_RETURN_NULL();
    return result;
}

Datum
array_to_istore(Datum *data, int count, bool *nulls)
{
    IStore *out,
           *istore;
    AvlTree  tree;
    int i,
        index;
    uint8 type = 0;
    ISPair *payload;
    ISPairs   *pairs;
    Position position;

    tree = is_make_empty(NULL);

    for (i = 0; i < count; ++i)
    {
        if (nulls[i])
            continue;
        istore = (IStore *) data[i];
        if (type == 0)
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
    i = is_tree_length(tree);

    pairs = palloc0(sizeof *pairs);
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
istore_add_from_int_arrays(ArrayType *input1, ArrayType *input2, uint8 type)
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
    long       key,
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
        //TODO switch over i_eltype2 and GetInt64
        value = DatumGetInt32(i_data2[i]);
        position = is_tree_find(key, tree);
        if (position == NULL)
            tree = is_insert(key, value, false, tree);
        else
            position->value += value;
    }

    pairs = palloc0(sizeof *pairs);

    is_pairs_init(pairs, 200, type);
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
    result = istore_add_from_int_arrays(input1, input2, PLAIN_ISTORE);
    if (result == 0)
        PG_RETURN_NULL();
    return result;
}

PG_FUNCTION_INFO_V1(country_istore_array_add);
Datum
country_istore_array_add(PG_FUNCTION_ARGS)
{
    Datum    result;
    ArrayType *input1,
              *input2;
    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    input1 = PG_GETARG_ARRAYTYPE_P(0);
    input2 = PG_GETARG_ARRAYTYPE_P(1);
    result = istore_add_from_int_arrays(input1, input2, COUNTRY_ISTORE);
    if (result == 0)
        PG_RETURN_NULL();
    return result;
}

PG_FUNCTION_INFO_V1(device_type_istore_array_add);
Datum
device_type_istore_array_add(PG_FUNCTION_ARGS)
{
    Datum    result;
    ArrayType *input1,
              *input2;
    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    input1 = PG_GETARG_ARRAYTYPE_P(0);
    input2 = PG_GETARG_ARRAYTYPE_P(1);
    result = istore_add_from_int_arrays(input1, input2, DEVICE_ISTORE);
    if (result == 0)
        PG_RETURN_NULL();
    return result;
}


PG_FUNCTION_INFO_V1(os_name_istore_array_add);
Datum
os_name_istore_array_add(PG_FUNCTION_ARGS)
{
    Datum    result;
    ArrayType *input1,
              *input2;
    if (PG_ARGISNULL(0) || PG_ARGISNULL(1))
        PG_RETURN_NULL();

    input1 = PG_GETARG_ARRAYTYPE_P(0);
    input2 = PG_GETARG_ARRAYTYPE_P(1);
    result = istore_add_from_int_arrays(input1, input2, OS_NAME_ISTORE);
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

        if (pairs[i].null)
        {
            dvalues[1] = Int64GetDatum(0);
            nulls[1] = true;
        }
        else
        {
            dvalues[1] = Int64GetDatum(pairs[i].val);
        }

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

    int     up_to,
            fill_with;
    int     index1 = 0,
            index2 = 0;

    if (PG_ARGISNULL(0))
        PG_RETURN_NULL();

    bool    fill_with_null = PG_ARGISNULL(2);

    is = PG_GETARG_IS(0);
    up_to = PG_GETARG_INT32(1);

    fill_with = PG_GETARG_INT64(2);
    pairs = FIRST_PAIR(is);
    creator = palloc0(sizeof *creator);

    if (up_to < 0)
        elog(ERROR, "parameter upto must be >= 0");

    if (is->type != PLAIN_ISTORE)
        elog(ERROR, "only supports plain istore ");

    is_pairs_init(creator, up_to + 1 , is->type);

    for(index1=0; index1 <= up_to; ++index1)
    {
        if (index2 < is->len && index1 == pairs[index2].key)
        {
            if (pairs[index2].null)
                is_pairs_insert(creator, pairs[index2].key, pairs[index2].val, null_type_for(is->type));
            else
                is_pairs_insert(creator, pairs[index2].key, pairs[index2].val, is->type);

            ++index2;
        }
        else
        {
            if (fill_with_null)
                is_pairs_insert(creator, index1, fill_with, null_type_for(is->type));
            else
                is_pairs_insert(creator, index1, fill_with, is->type);
        }
    }

    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}
