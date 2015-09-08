#include "istore.h"
#include "bigistore.h"

PG_FUNCTION_INFO_V1(bigistore_to_istore);
Datum
bigistore_to_istore(PG_FUNCTION_ARGS)
{
    BigIStore      *is;
    BigIStorePair  *pairs;
    IStore         *result;
    IStorePairs    *creator ;
    int             index;

    creator = NULL;
    is      = PG_GETARG_BIGIS(0);
    pairs   = FIRST_PAIR(is, BigIStorePair);
    creator = palloc0(sizeof *creator);
    index   = 0;
    istore_pairs_init(creator, is->len);
    while (index < is->len){
        istore_pairs_insert(creator, pairs[index].key, DirectFunctionCall1(int84, pairs[index].val));
        ++index;
    }
    FINALIZE_ISTORE(result, creator);

    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_to_big_istore);
Datum
istore_to_big_istore(PG_FUNCTION_ARGS)
{
    IStore          *is;
    IStorePair      *pairs;
    BigIStore       *result;
    BigIStorePairs  *creator ;
    int              index;

    creator = NULL;
    is      = PG_GETARG_IS(0);
    pairs   = FIRST_PAIR(is, IStorePair);
    creator = palloc0(sizeof *creator);
    index   = 0;

    bigistore_pairs_init(creator, is->len);
    while (index < is->len){
        bigistore_pairs_insert(creator, pairs[index].key, pairs[index].val);
        ++index;
    }

    FINALIZE_BIGISTORE(result, creator);
    PG_RETURN_POINTER(result);
}
