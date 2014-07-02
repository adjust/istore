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
