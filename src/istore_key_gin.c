/*
 * Gin support routines for istore keys
 *
 * This module provides very basic Gin index support for istore.  It indexes
 * only the keys of the istore, and supports only the strategy to check the
 * key is exist or not, namely the operator "?".
 *
 * The storage type of the index is 4 byte integer as the underlying type of
 * istore.  We wouldn't be able to use it, if we would index values of istore
 * too.  It seems a better approch to support other strategies with another
 * opclass to take the most advantage of the fixed length underlying type of
 * istore by making index as small of possible.
 *
 * Copyright (c) 2015, Emre Hasegeli
 */

#include "postgres.h"

#include "access/gin.h"
#include "access/skey.h"

#include "istore.h"
#include "bigistore.h"


/*
 * The Gin key extractor
 */
PG_FUNCTION_INFO_V1(gin_extract_istore_key);
Datum
gin_extract_istore_key(PG_FUNCTION_ARGS)
{
    IStore *is = PG_GETARG_IS(0);
    int32  *nentries = (int32 *) PG_GETARG_POINTER(1);
    Datum  *entries = NULL;
    IStorePair *pairs = FIRST_PAIR(is,IStorePair);
    int     count = is->len;
    int     i;

    *nentries = count;

    if (count > 0)
        entries = (Datum *) palloc(sizeof(Datum) * count);

    for (i = 0; i < count; ++i)
        entries[i] = Int32GetDatum(pairs[i].key);

    PG_RETURN_POINTER(entries);
}

/*
 * The Gin key extractor
 */
PG_FUNCTION_INFO_V1(gin_extract_bigistore_key);
Datum
gin_extract_bigistore_key(PG_FUNCTION_ARGS)
{
    BigIStore *is = PG_GETARG_BIGIS(0);
    int32  *nentries = (int32 *) PG_GETARG_POINTER(1);
    Datum  *entries = NULL;
    BigIStorePair *pairs = FIRST_PAIR(is,BigIStorePair);
    int     count = is->len;
    int     i;

    *nentries = count;

    if (count > 0)
        entries = (Datum *) palloc(sizeof(Datum) * count);

    for (i = 0; i < count; ++i)
        entries[i] = Int32GetDatum(pairs[i].key);

    PG_RETURN_POINTER(entries);
}

/*
 * The Gin query extractor
 */
PG_FUNCTION_INFO_V1(gin_extract_istore_key_query);
Datum
gin_extract_istore_key_query(PG_FUNCTION_ARGS)
{
    Datum   query = PG_GETARG_DATUM(0);
    int32  *nentries = (int32 *) PG_GETARG_POINTER(1);
    /* StrategyNumber strategy = PG_GETARG_UINT16(2); */
    /* int32  *searchMode = (int32 *) PG_GETARG_POINTER(6); */
    Datum  *entries;

    *nentries = 1;
    entries = (Datum *) palloc(sizeof(Datum));
    entries[0] = query;

    PG_RETURN_POINTER(entries);
}

/*
 * The Gin consistency check
 */
PG_FUNCTION_INFO_V1(gin_consistent_istore_key);
Datum
gin_consistent_istore_key(PG_FUNCTION_ARGS)
{
    /* bool   *check = (bool *) PG_GETARG_POINTER(0); */
    /* StrategyNumber strategy = PG_GETARG_UINT16(1); */
    /* IStore *query = PG_GETARG_IS(2); */
    /* int32   nkeys = PG_GETARG_INT32(3); */
    /* Pointer *extra_data = (Pointer *) PG_GETARG_POINTER(4); */
    bool   *recheck = (bool *) PG_GETARG_POINTER(5);
    bool    res = true;

    *recheck = false;

    PG_RETURN_BOOL(res);
}
