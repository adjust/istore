#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "utils/array.h"
#include "catalog/pg_type.h"
#include "libpq/pqformat.h"
#include "access/htup_details.h"
#include "utils/lsyscache.h"
#include "istore_common.h"
#include "avl.h"

Datum array_to_istore(Datum *data, int count, bool *nulls);
Datum istore_out(PG_FUNCTION_ARGS);
Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_recv(PG_FUNCTION_ARGS);
Datum istore_send(PG_FUNCTION_ARGS);
Datum istore_array_add(PG_FUNCTION_ARGS);
Datum istore_agg_finalfn(PG_FUNCTION_ARGS);
Datum istore_from_intarray(PG_FUNCTION_ARGS);
Datum istore_multiply_integer(PG_FUNCTION_ARGS);
Datum istore_multiply(PG_FUNCTION_ARGS);
Datum istore_divide_integer(PG_FUNCTION_ARGS);
Datum istore_divide_int8(PG_FUNCTION_ARGS);
Datum istore_divide(PG_FUNCTION_ARGS);
Datum istore_subtract_integer(PG_FUNCTION_ARGS);
Datum istore_subtract(PG_FUNCTION_ARGS);
Datum istore_add_integer(PG_FUNCTION_ARGS);
Datum istore_add(PG_FUNCTION_ARGS);
Datum istore_fetchval(PG_FUNCTION_ARGS);
Datum istore_exist(PG_FUNCTION_ARGS);
Datum istore_sum_up(PG_FUNCTION_ARGS);
Datum istore_each(PG_FUNCTION_ARGS);
Datum istore_fill_gaps(PG_FUNCTION_ARGS);
Datum istore_accumulate(PG_FUNCTION_ARGS);
Datum istore_seed(PG_FUNCTION_ARGS);
Datum istore_val_larger(PG_FUNCTION_ARGS);
Datum istore_val_smaller(PG_FUNCTION_ARGS);
Datum  istore_array_sum(Datum *data, int count, bool *nulls);

typedef struct {
    int32  key;
    int32  val;
} IStorePair;

typedef struct {
    IStorePair *pairs;
    size_t  size;
    int     used;
    int     buflen;
} IStorePairs;


typedef struct
{
    int32 __varlen;
    int32   buflen;
    int32   len;
} IStore;

IStore* istore_merge(IStore *arg1, IStore *arg2, PGFunction mergefunc, PGFunction miss1func);
IStore* istore_apply_datum(IStore *arg1, Datum arg2, PGFunction applyfunc);
void istore_pairs_init(IStorePairs *pairs, size_t initial_size);
void istore_pairs_insert(IStorePairs *pairs, int32 key, int32 val);
int  istore_pairs_cmp(const void *a, const void *b);

void istore_tree_to_pairs(AvlNode *p, IStorePairs *pairs);
IStorePair* istore_find(IStore *is, int32 key);

#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))

#define FINALIZE_ISTORE(_istore, _pairs)                             \
    do {                                                                    \
        _istore = palloc0(ISHDRSZ + PAYLOAD_SIZE(_pairs, IStorePair));                  \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs, IStorePair));               \
        memcpy(FIRST_PAIR(_istore, IStorePair), _pairs->pairs, PAYLOAD_SIZE(_pairs, IStorePair)); \
        pfree(_pairs->pairs);                                               \
    } while(0)



#endif // ISTORE_H
