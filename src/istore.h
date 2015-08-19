#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"
#include "utils/array.h"
#include "catalog/pg_type.h"
#include "libpq/pqformat.h"
#include "access/htup_details.h"
#include "utils/lsyscache.h"

Datum array_to_istore(Datum *data, int count, bool *nulls);
Datum istore_out(PG_FUNCTION_ARGS);
Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_recv(PG_FUNCTION_ARGS);
Datum istore_send(PG_FUNCTION_ARGS);
Datum istore_array_add(PG_FUNCTION_ARGS);
Datum istore_agg_finalfn(PG_FUNCTION_ARGS);
Datum istore_from_array(PG_FUNCTION_ARGS);
Datum is_multiply_integer(PG_FUNCTION_ARGS);
Datum is_multiply(PG_FUNCTION_ARGS);
Datum is_divide_integer(PG_FUNCTION_ARGS);
Datum is_divide_int8(PG_FUNCTION_ARGS);
Datum is_divide(PG_FUNCTION_ARGS);
Datum is_subtract_integer(PG_FUNCTION_ARGS);
Datum is_subtract(PG_FUNCTION_ARGS);
Datum istore_agg(PG_FUNCTION_ARGS);
Datum is_add_integer(PG_FUNCTION_ARGS);
Datum is_add(PG_FUNCTION_ARGS);
Datum is_fetchval(PG_FUNCTION_ARGS);
Datum is_exist(PG_FUNCTION_ARGS);
Datum istore_sum_up(PG_FUNCTION_ARGS);
Datum istore_each(PG_FUNCTION_ARGS);
Datum istore_fill_gaps(PG_FUNCTION_ARGS);
Datum istore_accumulate(PG_FUNCTION_ARGS);
Datum istore_seed(PG_FUNCTION_ARGS);
Datum is_val_larger(PG_FUNCTION_ARGS);
Datum is_val_smaller(PG_FUNCTION_ARGS);

#define BUFLEN_OFFSET        8

typedef struct {
    int32  key;
    int64   val;
} ISPair;

typedef struct {
    ISPair *pairs;
    size_t  size;
    int     used;
    int     buflen;
} ISPairs;

typedef struct AvlNode AvlNode;
typedef struct AvlNode *Position;
typedef struct AvlNode *AvlTree;

struct AvlNode
{
    int32    key;
    int64    value;
    AvlTree  left;
    AvlTree  right;
    int      height;
};

typedef struct
{
    int32 __varlen;
    int32   buflen;
    int32   len;
} IStore;

void is_pairs_init(ISPairs *pairs, size_t initial_size);
void is_pairs_insert(ISPairs *pairs, int32 key, int64 val);
int  is_pairs_cmp(const void *a, const void *b);
void is_pairs_sort(ISPairs *pairs);
void is_pairs_deinit(ISPairs *pairs);
void is_pairs_debug(ISPairs *pairs);

AvlTree is_make_empty(AvlTree t);
int is_compare(int32 key, AvlTree node);
Position is_tree_find(int32 key, AvlTree t);
AvlTree is_insert(AvlTree t, int32 key, int64 value);
int is_tree_length(Position p);
int is_tree_to_pairs(Position p, ISPairs *pairs, int n);
ISPair* is_find(IStore *is, int32 key);

#define DIGIT_WIDTH(_digit, _width)       \
    do {                                  \
        int64 _local = _digit;             \
        _width = 0;                       \
        if (_local <= 0)                  \
            ++_width;                     \
        for (; _local != 0; _local /= 10) \
            ++_width;                     \
    } while (0)

#define PAYLOAD(_pairs) _pairs->pairs
#define PAYLOAD_SIZE(_pairs) (_pairs->used * sizeof(ISPair))

#define SKIP_SPACES(_ptr)  \
    while (isspace(*_ptr)) \
        _ptr++;

/* TODO really respect quotes and dont just skip them */
#define SKIP_ESCAPED(_ptr) \
    if (*_ptr == '"')      \
            _ptr++;

#define GET_PLAIN_KEY(_parser, _key)                    \
    do {                                                \
        _key = strtol(_parser->ptr, &_parser->ptr, 10); \
    } while (0)

#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define ISHDRSZ VARHDRSZ + sizeof(int32) + sizeof(int32)
#define ISTORE_SIZE(x) (ISHDRSZ + x->len * sizeof(ISPair))
#define FIRST_PAIR(x) ((ISPair*)((char *) x + ISHDRSZ))

#define COPY_ISTORE(_dst, _src)                \
    do {                                       \
        _dst = palloc0(ISTORE_SIZE(_src));      \
        memcpy(_dst, _src, ISTORE_SIZE(_src)); \
    } while(0)

#define FINALIZE_ISTORE(_istore, _pairs)                                    \
    do {                                                                    \
        is_pairs_sort(_pairs);                                              \
        _istore = palloc0(ISHDRSZ + PAYLOAD_SIZE(_pairs));                   \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs));               \
        memcpy(FIRST_PAIR(_istore), PAYLOAD(_pairs), PAYLOAD_SIZE(_pairs)); \
        is_pairs_deinit(_pairs);                                            \
    } while(0)

#define EMPTY_ISTORE(_istore)          \
    do {                               \
        _istore = palloc0(ISHDRSZ);    \
        _istore->buflen = 0;           \
        _istore->len = 0;              \
        SET_VARSIZE(_istore, ISHDRSZ); \
    } while(0)

#define LARGER(_a, _b) (_a > _b) ? _a : _b
#define SMALLER(_a ,_b) (_a < _b) ? _a : _b
#endif // ISTORE_H
