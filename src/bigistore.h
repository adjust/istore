#ifndef BIGISTORE_H
#define BIGISTORE_H

#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "utils/int8.h"
#include "utils/array.h"
#include "catalog/pg_type.h"
#include "libpq/pqformat.h"
#include "access/htup_details.h"
#include "utils/lsyscache.h"
#include "istore_common.h"
#include "avl.h"

Datum array_to_bigistore(Datum *data, int count, bool *nulls);
Datum bigistore_out(PG_FUNCTION_ARGS);
Datum bigistore_in(PG_FUNCTION_ARGS);
Datum bigistore_recv(PG_FUNCTION_ARGS);
Datum bigistore_send(PG_FUNCTION_ARGS);
Datum bigistore_array_add(PG_FUNCTION_ARGS);
Datum bigistore_agg_finalfn(PG_FUNCTION_ARGS);
Datum bigistore_from_array(PG_FUNCTION_ARGS);
Datum bigistore_multiply_integer(PG_FUNCTION_ARGS);
Datum bigistore_multiply(PG_FUNCTION_ARGS);
Datum bigistore_divide_integer(PG_FUNCTION_ARGS);
Datum bigistore_divide_int8(PG_FUNCTION_ARGS);
Datum bigistore_divide(PG_FUNCTION_ARGS);
Datum bigistore_subtract_integer(PG_FUNCTION_ARGS);
Datum bigistore_subtract(PG_FUNCTION_ARGS);
Datum bigistore_agg(PG_FUNCTION_ARGS);
Datum bigistore_add_integer(PG_FUNCTION_ARGS);
Datum bigistore_add(PG_FUNCTION_ARGS);
Datum bigistore_fetchval(PG_FUNCTION_ARGS);
Datum bigistore_exist(PG_FUNCTION_ARGS);
Datum bigistore_sum_up(PG_FUNCTION_ARGS);
Datum bigistore_each(PG_FUNCTION_ARGS);
Datum bigistore_fill_gaps(PG_FUNCTION_ARGS);
Datum bigistore_accumulate(PG_FUNCTION_ARGS);
Datum bigistore_seed(PG_FUNCTION_ARGS);
Datum bigistore_val_larger(PG_FUNCTION_ARGS);
Datum bigistore_val_smaller(PG_FUNCTION_ARGS);

typedef struct {
    int32  key;
    int64  val;
} BigIStorePair;

typedef struct {
    BigIStorePair *pairs;
    size_t  size;
    int     used;
    int     buflen;
} BigIStorePairs;

typedef struct
{
    int32 __varlen;
    int32   buflen;
    int32   len;
} BigIStore;

void bigistore_pairs_init(BigIStorePairs *pairs, size_t initial_size);
void bigistore_pairs_insert(BigIStorePairs *pairs, int32 key, int64 val);
int  bigistore_pairs_cmp(const void *a, const void *b);

void bigistore_tree_to_pairs(AvlNode *p, BigIStorePairs *pairs);
BigIStorePair* bigistore_find(BigIStore *is, int32 key);

#define PG_GETARG_BIGIS(x) (BigIStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define BIGPAIRSORTFUNC bigistore_pairs_cmp
#define BIGISINSERTFUNC bigistore_pairs_insert

#define FINALIZE_BIGISTORE(_istore, _pairs)                                    \
    do {                                                                          \
        qsort(_pairs->pairs, _pairs->used, sizeof(BigIStorePair), bigistore_pairs_cmp); \
        FINALIZE_BIGISTORE_NOSORT(_istore, _pairs);                       \
    } while(0)

#define FINALIZE_BIGISTORE_NOSORT(_istore, _pairs)                             \
    do {                                                                    \
        _istore = palloc0(ISHDRSZ + PAYLOAD_SIZE(_pairs, BigIStorePair));                  \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs, BigIStorePair));               \
        memcpy(FIRST_PAIR(_istore, BigIStorePair), _pairs->pairs, PAYLOAD_SIZE(_pairs, BigIStorePair)); \
        pfree(_pairs->pairs);                                        \
    } while(0)


#endif // BIGISTORE_H
