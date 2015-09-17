#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"
#include "avl.h"
#include "utils/memutils.h"

Datum istore_out(PG_FUNCTION_ARGS);
Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_recv(PG_FUNCTION_ARGS);
Datum istore_send(PG_FUNCTION_ARGS);
Datum istore_to_json(PG_FUNCTION_ARGS);
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
Datum istore_array_sum(Datum *data, int count, bool *nulls);
Datum istore_compact(PG_FUNCTION_ARGS);
Datum istore_akeys(PG_FUNCTION_ARGS);
Datum istore_avals(PG_FUNCTION_ARGS);
Datum istore_skeys(PG_FUNCTION_ARGS);
Datum istore_svals(PG_FUNCTION_ARGS);

Datum bigistore_out(PG_FUNCTION_ARGS);
Datum bigistore_in(PG_FUNCTION_ARGS);
Datum bigistore_recv(PG_FUNCTION_ARGS);
Datum bigistore_send(PG_FUNCTION_ARGS);
Datum bigistore_to_json(PG_FUNCTION_ARGS);
Datum bigistore_array_add(PG_FUNCTION_ARGS);
Datum bigistore_agg_finalfn(PG_FUNCTION_ARGS);
Datum bigistore_from_intarray(PG_FUNCTION_ARGS);
Datum bigistore_multiply_integer(PG_FUNCTION_ARGS);
Datum bigistore_multiply(PG_FUNCTION_ARGS);
Datum bigistore_divide_integer(PG_FUNCTION_ARGS);
Datum bigistore_divide_int8(PG_FUNCTION_ARGS);
Datum bigistore_divide(PG_FUNCTION_ARGS);
Datum bigistore_subtract_integer(PG_FUNCTION_ARGS);
Datum bigistore_subtract(PG_FUNCTION_ARGS);
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
Datum bigistore_array_sum(Datum *data, int count, bool *nulls);
Datum bigistore_compact(PG_FUNCTION_ARGS);
Datum bigistore_akeys(PG_FUNCTION_ARGS);
Datum bigistore_avals(PG_FUNCTION_ARGS);
Datum bigistore_skeys(PG_FUNCTION_ARGS);
Datum bigistore_svals(PG_FUNCTION_ARGS);


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


IStore* istore_merge(IStore *arg1, IStore *arg2, PGFunction mergefunc, PGFunction miss1func);
IStore* istore_apply_datum(IStore *arg1, Datum arg2, PGFunction applyfunc);

BigIStore* bigistore_merge(BigIStore *arg1, BigIStore *arg2, PGFunction mergefunc, PGFunction miss1func);
BigIStore* bigistore_apply_datum(BigIStore *arg1, Datum arg2, PGFunction applyfunc);

void istore_pairs_init(IStorePairs *pairs, size_t initial_size);
void istore_pairs_insert(IStorePairs *pairs, int32 key, int32 val);
int  istore_pairs_cmp(const void *a, const void *b);
void istore_tree_to_pairs(AvlNode *p, IStorePairs *pairs);
IStorePair* istore_find(IStore *is, int32 key);

void bigistore_pairs_init(BigIStorePairs *pairs, size_t initial_size);
void bigistore_pairs_insert(BigIStorePairs *pairs, int32 key, int64 val);
int  bigistore_pairs_cmp(const void *a, const void *b);
void bigistore_tree_to_pairs(AvlNode *p, BigIStorePairs *pairs);
BigIStorePair* bigistore_find(BigIStore *is, int32 key);

#define BUFLEN_OFFSET 8
#define MAX(_a, _b) ((_a > _b) ? _a : _b)
#define MIN(_a ,_b) ((_a < _b) ? _a : _b)

#define PAIRS_MAX(_pairtype) (MaxAllocSize / sizeof(_pairtype))
#define PAYLOAD_SIZE(_pairs, _pairtype) (_pairs->used * sizeof(_pairtype))
#define ISHDRSZ VARHDRSZ + sizeof(int32) + sizeof(int32)

#define ISTORE_SIZE(x, _pairtype) (ISHDRSZ + x->len * sizeof(_pairtype))
#define FIRST_PAIR(x, _pairtype) ((_pairtype*)((char*) x + ISHDRSZ))


#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define PG_GETARG_BIGIS(x) (BigIStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))

#define FINALIZE_ISTORE(_istore, _pairs)                                    \
    do {                                                                    \
        _istore = palloc0(ISHDRSZ + PAYLOAD_SIZE(_pairs, IStorePair));      \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs, IStorePair));   \
        memcpy(FIRST_PAIR(_istore, IStorePair), _pairs->pairs,              \
               PAYLOAD_SIZE(_pairs, IStorePair));                           \
        pfree(_pairs->pairs);                                               \
    } while(0)

#define FINALIZE_BIGISTORE(_istore, _pairs)                                 \
    do {                                                                    \
        _istore = palloc0(ISHDRSZ + PAYLOAD_SIZE(_pairs, BigIStorePair));   \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs, BigIStorePair));\
        memcpy(FIRST_PAIR(_istore, BigIStorePair), _pairs->pairs,           \
               PAYLOAD_SIZE(_pairs, BigIStorePair));                        \
        pfree(_pairs->pairs);                                               \
    } while(0)


#endif // ISTORE_H
