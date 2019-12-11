#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"

#include "avl.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "utils/memutils.h"

/*
 * Until version 9.4 postgres didn't have "extern" function declaration in
 * PG_FUNCTION_INFO_V1. This is a quick fix that allows us not to declare every
 * function manually. Copied from the PostgreSQL 12 source code (see fmgr.h)
 */
#if PG_VERSION_NUM < 90400
#undef PG_FUNCTION_INFO_V1
#define PG_FUNCTION_INFO_V1(funcname)                                                                                  \
    extern Datum             funcname(PG_FUNCTION_ARGS);                                                               \
    extern PGDLLEXPORT const Pg_finfo_record *CppConcat(pg_finfo_, funcname)(void);                                    \
    const Pg_finfo_record *                   CppConcat(pg_finfo_, funcname)(void)                                     \
    {                                                                                                                  \
        static const Pg_finfo_record my_finfo = { 1 };                                                                 \
        return &my_finfo;                                                                                              \
    }                                                                                                                  \
    extern int no_such_variable
#endif

/*
 * a single key/value pair
 */
typedef struct
{
    int32 key;
    int32 val;
} IStorePair;

/*
 * collection of pairs
 */
typedef struct
{
    IStorePair *pairs;
    size_t      size;
    int         used;
    int         buflen;
} IStorePairs;

/*
 * the istore
 */
typedef struct
{
    int32 __varlen;
    int32 buflen;
    int32 len;
} IStore;

typedef struct
{
    int32 key;
    int64 val;
} BigIStorePair;

typedef struct
{
    BigIStorePair *pairs;
    size_t         size;
    int            used;
    int            buflen;
} BigIStorePairs;

typedef struct
{
    int32 __varlen;
    int32 buflen;
    int32 len;
} BigIStore;

void istore_copy_and_add_buflen(IStore *istore, BigIStorePair *pairs);
void istore_pairs_init(IStorePairs *pairs, size_t initial_size);
void istore_pairs_insert(IStorePairs *pairs, int32 key, int32 val);
void istore_tree_to_pairs(AvlNode *p, IStorePairs *pairs);
int  is_pair_buf_len(IStorePair *pair);
void bigistore_add_buflen(BigIStore *istore);
void bigistore_pairs_init(BigIStorePairs *pairs, size_t initial_size);
void bigistore_pairs_insert(BigIStorePairs *pairs, int32 key, int64 val);
void bigistore_tree_to_pairs(AvlNode *p, BigIStorePairs *pairs);
int  bigis_pair_buf_len(BigIStorePair *pair);
IStore *istore_pack(IStorePairs *pairs);
IStore *istore_unpack(IStore *orig);

int is_int32_arr_comp(const void *a, const void *b);

#define BUFLEN_OFFSET 8
#define MAX(_a, _b) ((_a > _b) ? _a : _b)
#define MIN(_a, _b) ((_a < _b) ? _a : _b)

#define PAIRS_MAX(_pairtype) (MaxAllocSize / sizeof(_pairtype))
#define PAYLOAD_SIZE(_pairs, _pairtype) (_pairs->used * sizeof(_pairtype))
#define ISHDRSZ VARHDRSZ + sizeof(int32) + sizeof(int32)

#define ISTORE_SIZE(x, _pairtype) (ISHDRSZ + x->len * sizeof(_pairtype))

/*
 * get the first pair of type
 */
#define FIRST_PAIR(x, _pairtype) ((_pairtype *) ((char *) x + ISHDRSZ))
#define LAST_PAIR(x, _pairtype) ((_pairtype *) ((char *) x + ISHDRSZ + (x->len - 1) * sizeof(_pairtype)))

/*
 * get the istore
 */
#define PG_GETARG_IS(x) istore_unpack((IStore *) PG_DETOAST_DATUM(PG_GETARG_DATUM(x)))
#define PG_GETARG_BIGIS(x) (BigIStore *) PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define PG_GETARG_IS_COPY(x) (IStore *) PG_DETOAST_DATUM_COPY(PG_GETARG_DATUM(x))
#define PG_GETARG_BIGIS_COPY(x) (BigIStore *) PG_DETOAST_DATUM_COPY(PG_GETARG_DATUM(x))

/*
 * an empty istore
 */
#define PG_RETURN_EMPTY_ISTORE()                                                                                       \
    do                                                                                                                 \
    {                                                                                                                  \
        IStore *x = (IStore *) palloc0(ISHDRSZ);                                                                       \
        SET_VARSIZE(x, ISHDRSZ);                                                                                       \
        PG_RETURN_POINTER(x);                                                                                          \
    } while (0)

/*
 * creates the internal representation from a pairs collection
 */
#define FINALIZE_ISTORE_BASE(_istore, _pairs, _pairtype)                                                               \
    _istore         = palloc0(ISHDRSZ + PAYLOAD_SIZE(_pairs, _pairtype));                                              \
    _istore->buflen = _pairs->buflen;                                                                                  \
    _istore->len    = _pairs->used;                                                                                    \
    SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs, _pairtype));                                                   \
    memcpy(FIRST_PAIR(_istore, _pairtype), _pairs->pairs, PAYLOAD_SIZE(_pairs, _pairtype));

#define FINALIZE_ISTORE_BASE_V2(_istore, _pairs) \
    do { \
        (_istore) = istore_pack(_pairs); \
    } while (0)

//FINALIZE_ISTORE_BASE(_istore, _pairs, IStorePair);
#define FINALIZE_ISTORE(_istore, _pairs)                                                                               \
    do                                                                                                                 \
    {                                                                                                                  \
        FINALIZE_ISTORE_BASE_V2(_istore, _pairs); \
        pfree(_pairs->pairs);                                                                                          \
    } while (0)

#define FINALIZE_BIGISTORE(_istore, _pairs)                                                                            \
    do                                                                                                                 \
    {                                                                                                                  \
        FINALIZE_ISTORE_BASE(_istore, _pairs, BigIStorePair);                                                          \
        pfree(_pairs->pairs);                                                                                          \
    } while (0)

#define ISTORE_PACKED_FLAG (1 << 31)
#define ISTORE_SET_LENGTH(_istore, _len) \
    do { \
        (_istore)->len = (_len) & ~ISTORE_PACKED_FLAG; \
    } while (0)
#define ISTORE_GET_LENGTH(_istore) \
    (_istore->len & ~ISTORE_PACKED_FLAG)
#define ISTORE_IS_PACKED(_istore) \
    ((_istore)->len & ISTORE_PACKED_FLAG)
#define ISTORE_SET_PACKED(_istore) \
    do { \
        (_istore)->len |= ISTORE_PACKED_FLAG; \
    } while (0)

#define SAMESIGN(a, b) (((a) < 0) == ((b) < 0))
#define INTPL(_a, _b, _r)                                                                                              \
    do                                                                                                                 \
    {                                                                                                                  \
        _r = _a + _b;                                                                                                  \
        if (SAMESIGN(_a, _b) && !SAMESIGN(_r, _a))                                                                     \
            ereport(ERROR, (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE), errmsg("integer out of range")));             \
    } while (0)

#endif // ISTORE_H
