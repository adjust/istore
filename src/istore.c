#include "istore.h"

PG_MODULE_MAGIC;

size_t get_digit_num(long number)
{
    size_t count = 0;
    if( number == 0 || number < 0 )
        ++count;
    while( number != 0 )
    {
        number /= 10;
        ++count;
    }
    return count;
}

ISPair*
find(IStore *is, long key)
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

PG_FUNCTION_INFO_V1(exist);

Datum
exist(PG_FUNCTION_ARGS)
{
    IStore *in;
    int     key;
    bool    found;
    /*TODO: NULL handling*/
    in  = PG_GETARG_IS(0);
    key = PG_GETARG_INT32(1);
    if (find(in, key))
        found = true;
    else
        found = false;
    PG_RETURN_BOOL(found);
}

PG_FUNCTION_INFO_V1(fetchval);

Datum
fetchval(PG_FUNCTION_ARGS)
{
    IStore *in;
    int     key;
    ISPair  *pair;
    /* TODO: NULL handling */
    in  = PG_GETARG_IS(0);
    key = PG_GETARG_INT32(1);
    if ((pair = find(in, key)) == NULL )
        PG_RETURN_NULL();
    else
        PG_RETURN_INT64(pair->val);
}

PG_FUNCTION_INFO_V1(add);

Datum
add(PG_FUNCTION_ARGS)
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
    Pairs_init(creator, 200);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            Pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            Pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
            ++index2;
        }
        else
        {
            Pairs_insert(
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
        Pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
        ++index1;
    }
    while (index2 < is2->len)
    {
        Pairs_insert(creator, pairs2[index2].key, pairs2[index2].val);
        ++index2;
    }
    Pairs_sort(creator);
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(subtract);

Datum
subtract(PG_FUNCTION_ARGS)
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
    Pairs_init(creator, 200);
    while (index1 < is1->len && index2 < is2->len)
    {
        if (pairs1[index1].key < pairs2[index2].key)
        {
            Pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
            ++index1;
        }
        else if (pairs1[index1].key > pairs2[index2].key)
        {
            Pairs_insert(creator, pairs2[index2].key, -pairs2[index2].val);
            ++index2;
        }
        else
        {
            Pairs_insert(
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
        Pairs_insert(creator, pairs1[index1].key, pairs1[index1].val);
        ++index1;
    }
    while (index2 < is2->len)
    {
        Pairs_insert(creator, pairs2[index2].key, -pairs2[index2].val);
        ++index2;
    }
    Pairs_sort(creator);
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}
