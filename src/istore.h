#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"
#include "utils/array.h"
#include "device_type.h"
#include "country.h"
#include "os_name.h"
#include "catalog/pg_type.h"
#include "access/htup_details.h"

Datum array_to_istore(Datum *data, int count, bool *nulls);
Datum type_istore_to_istore(PG_FUNCTION_ARGS);
Datum istore_to_device_istore(PG_FUNCTION_ARGS);
Datum istore_to_country_istore(PG_FUNCTION_ARGS);
Datum istore_to_os_name_istore(PG_FUNCTION_ARGS);
Datum istore_out(PG_FUNCTION_ARGS);
Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_recv(PG_FUNCTION_ARGS);
Datum istore_send(PG_FUNCTION_ARGS);
Datum cistore_out(PG_FUNCTION_ARGS);
Datum cistore_in(PG_FUNCTION_ARGS);
Datum device_istore_in(PG_FUNCTION_ARGS);
Datum country_istore_in(PG_FUNCTION_ARGS);
Datum os_name_istore_in(PG_FUNCTION_ARGS);
Datum cistore_from_types(PG_FUNCTION_ARGS);
Datum cistore_cohort_from_types(PG_FUNCTION_ARGS);
Datum istore_array_add(PG_FUNCTION_ARGS);
Datum country_istore_array_add(PG_FUNCTION_ARGS);
Datum device_type_istore_array_add(PG_FUNCTION_ARGS);
Datum os_name_istore_array_add(PG_FUNCTION_ARGS);
Datum istore_agg_finalfn(PG_FUNCTION_ARGS);
Datum os_name_istore_from_array(PG_FUNCTION_ARGS);
Datum country_istore_from_array(PG_FUNCTION_ARGS);
Datum device_istore_from_array(PG_FUNCTION_ARGS);
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

#define PLAIN_ISTORE         1
#define NULL_VAL_ISTORE      2
#define DEVICE_ISTORE        3
#define NULL_DEVICE_ISTORE   4
#define COUNTRY_ISTORE       5
#define NULL_COUNTRY_ISTORE  6
#define OS_NAME_ISTORE       7
#define NULL_OS_NAME_ISTORE  8
#define C_ISTORE             9
#define NULL_C_ISTORE       10
#define C_ISTORE_COHORT     11

#define BUFLEN_OFFSET        8
#define NULL_BUFLEN_OFFSET   10

/*
 * macro to create a c string representation of a
 * varlena postgres text. allocates extra memory with palloc.
 * expects the datum to be NULL terminated
 */
#define DATUM_TO_CSTRING(_datum, _str, _len) \
    do {                                     \
        _len = VARSIZE(_datum) - VARHDRSZ;   \
        _str = palloc0(_len + 1);            \
        memcpy(_str, VARDATA(_datum), _len); \
    } while(0)

extern void get_typlenbyvalalign(Oid eltype, int16 *i_typlen, bool *i_typbyval, char *i_typalign);

struct ISPair {
    int32  key;
    long   val;
    bool   null;
};

typedef struct ISPair ISPair;

struct ISPairs {
    ISPair *pairs;
    size_t  size;
    int     used;
    int     buflen;
    uint8   type;
};

typedef struct ISPairs ISPairs;

extern void is_pairs_init(ISPairs *pairs, size_t initial_size, int type);
extern void is_pairs_insert(ISPairs *pairs, int32 key, long val, int type);
extern int  is_pairs_cmp(const void *a, const void *b);
extern void is_pairs_sort(ISPairs *pairs);
extern void is_pairs_deinit(ISPairs *pairs);
extern void is_pairs_debug(ISPairs *pairs);

typedef struct AvlNode AvlNode;
typedef struct AvlNode *Position;
typedef struct AvlNode *AvlTree;

struct AvlNode
{
    int32    key;
    long     value;
    bool     null;
    AvlTree  left;
    AvlTree  right;
    int      height;
};

extern AvlTree is_make_empty(AvlTree t);
extern int is_compare(int32 key, AvlTree node);
extern Position is_tree_find(int32 key, AvlTree t);
extern AvlTree is_insert(int32 key, long value, bool null, AvlTree t);
extern int is_tree_length(Position p);
extern int is_tree_to_pairs(Position p, ISPairs *pairs, int n);

#define DIGIT_WIDTH(_digit, _width)       \
    do {                                  \
        long _local = _digit;             \
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

#define DELIM     ':'
#define DELIM_NUM 2

#define SKIP_COLON_DELIM(_parser, _moved)                    \
    do {                                                     \
        for (_moved = 0; _moved < DELIM_NUM; ++_moved)       \
            if (*(_parser->ptr) != DELIM)                    \
                break;                                       \
            else                                             \
                _parser->ptr++;                              \
        switch (_moved)                                      \
        {                                                    \
            case 0:  _parser->type = C_ISTORE; break;        \
            case 1:  elog(ERROR, "incomplete delimiter");    \
            case 2:  _parser->type = C_ISTORE_COHORT; break; \
            default: elog(ERROR, "too long delimiter");      \
        }                                                    \
    } while(0)

#define COUNT_ALPHA(_ptr, _count)                   \
    for (;isalpha(*_ptr) || *_ptr == '-'; ++_count) \
        ++_ptr;

#define EXTRACT_STRING(_str, _buf)           \
    do {                                     \
        char *_ptr;                          \
        int  _count = 0;                     \
        _ptr = _str;                         \
        COUNT_ALPHA(_ptr, _count);           \
        _buf = pnstrdup(_str, _count);       \
        _str = _ptr;                         \
    } while (0)

#define GET_PLAIN_KEY(_parser, _key)                    \
    do {                                                \
        _key = strtol(_parser->ptr, &_parser->ptr, 10); \
    } while (0)

#define GET_DEVICE_KEY(_parser, _key)       \
    do {                                    \
        char *_buf;                         \
        EXTRACT_STRING(_parser->ptr, _buf); \
        _key = get_device_type_num(_buf);   \
        pfree(_buf);                        \
    } while (0)

#define GET_COUNTRY_KEY(_parser, _key)      \
    do {                                    \
        char *_buf;                         \
        EXTRACT_STRING(_parser->ptr, _buf); \
        _key = get_country_num(_buf);       \
        pfree(_buf);                        \
    } while (0)

#define GET_OS_NAME_KEY(_parser, _key)      \
    do {                                    \
        char *_buf;                         \
        EXTRACT_STRING(_parser->ptr, _buf); \
        _key = get_os_name_num(_buf);       \
        pfree(_buf);                        \
    } while (0)

#define GET_COHORT_SIZE(_parser, _key, _found) \
    do {                                       \
        if (_found)                            \
            GET_PLAIN_KEY(_parser, _key);      \
    } while (0)

#define GET_C_ISTORE(_parser, _key)                                 \
    do {                                                            \
        int _c_key, _d_key,                                         \
            _o_key, _c_size = 0,                                    \
            _found;                                                 \
        _key = 0;                                                   \
        GET_COUNTRY_KEY(_parser, _c_key);                           \
        SKIP_COLON_DELIM(_parser, _found);                          \
        GET_DEVICE_KEY(_parser, _d_key);                            \
        SKIP_COLON_DELIM(_parser, _found);                          \
        GET_OS_NAME_KEY(_parser, _o_key);                           \
        SKIP_COLON_DELIM(_parser, _found);                          \
        GET_COHORT_SIZE(_parser, _c_size, _found);                  \
        C_ISTORE_CREATE_KEY(_key, _c_key, _d_key, _o_key, _c_size); \
    } while (0)

#define VALID_NULL(x)                                                 \
        (  (x[0] == 'N' && x[1] == 'U' && x[2] == 'L' && x[3] == 'L') \
        || (x[0] == 'n' && x[1] == 'u' && x[2] == 'l' && x[3] == 'l') \
        )

#define GET_VAL(_parser, _val, _null) \
    do {\
        _val = -1;\
        GET_PLAIN_KEY(_parser, _val);\
        if (_val == 0 && VALID_NULL(_parser->ptr))\
        {\
            _null = true; \
            _parser->ptr = _parser->ptr + 4;\
        }\
    } while (0)

#define C_ISTORE_CREATE_KEY(_key, _c, _d, _o, _s) \
    _key = _key | _s;                             \
    _key = _key | _o << 8;                        \
    _key = _key | _d << 16;                       \
    _key = _key | _c << 24;                       \


#define C_ISTORE_GET_COHORT_SIZE(_key) ((_key & 0x000000FF))
#define C_ISTORE_GET_OS_NAME_KEY(_key) ((_key & 0x0000FF00) >> 8)
#define C_ISTORE_GET_DEVICE_KEY(_key)  ((_key & 0x00FF0000) >> 16)
#define C_ISTORE_GET_COUNTRY_KEY(_key) ((_key & 0xFF000000) >> 24)

#define C_ISTORE_KEY_LEN(_key, _keylen)                                 \
    do {                                                                \
        _keylen = get_os_name_length(C_ISTORE_GET_OS_NAME_KEY(_key))    \
                + get_device_type_length(C_ISTORE_GET_DEVICE_KEY(_key)) \
                + DELIM_NUM * 2 + 2;                                    \
    } while (0)

#define C_ISTORE_COHORT_KEY_LEN(_key, _keylen)                          \
    do {                                                                \
        int _cohort_width = 0;                                          \
        DIGIT_WIDTH(C_ISTORE_GET_COHORT_SIZE(_key),_cohort_width);      \
        _keylen = get_os_name_length(C_ISTORE_GET_OS_NAME_KEY(_key))    \
                + get_device_type_length(C_ISTORE_GET_DEVICE_KEY(_key)) \
                + _cohort_width + DELIM_NUM * 3 + 2;                    \
    } while (0)


#define GET_KEYARG_BY_TYPE(_istore, _key)                     \
    do {                                                      \
        char *type = NULL;                                    \
        switch (_istore->type)                                \
        {                                                     \
            case PLAIN_ISTORE:                                \
                key = PG_GETARG_INT32(1);                     \
                break;                                        \
            case DEVICE_ISTORE:                               \
                type = PG_GETARG_CSTRING(1);                  \
                key = get_device_type_num(type);              \
                break;                                        \
            case COUNTRY_ISTORE:                              \
                type = PG_GETARG_CSTRING(1);                  \
                key = get_country_num(type);                  \
                break;                                        \
            case OS_NAME_ISTORE:                              \
                type = PG_GETARG_CSTRING(1);                  \
                key = get_os_name_num(type);                  \
                break;                                        \
            default:                                          \
                elog(ERROR, "is_exist: unknown istore type"); \
            }                                                 \
    } while(0)

typedef struct
{
    int32 __varlen;
    int32   buflen;
    int32   len;
    uint8   type;
} IStore;

uint8 null_type_for(uint8 type);

#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define ISHDRSZ VARHDRSZ + sizeof(int32) + sizeof(int32) + sizeof(uint8)
#define ISTORE_SIZE(x) (ISHDRSZ + x->len * sizeof(ISPair))
#define FIRST_PAIR(x) ((ISPair*)((char *) x + ISHDRSZ))

#define COPY_ISTORE(_dst, _src)                \
    do {                                       \
        _dst = palloc(ISTORE_SIZE(_src));      \
        memcpy(_dst, _src, ISTORE_SIZE(_src)); \
    } while(0)

#define FINALIZE_ISTORE(_istore, _pairs)                                    \
    do {                                                                    \
        is_pairs_sort(_pairs);                                              \
        _istore = palloc(ISHDRSZ + PAYLOAD_SIZE(_pairs));                   \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        _istore->type   = _pairs->type;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs));               \
        memcpy(FIRST_PAIR(_istore), PAYLOAD(_pairs), PAYLOAD_SIZE(_pairs)); \
        is_pairs_deinit(_pairs);                                            \
    } while(0)


ISPair* is_find(IStore *is, int32 key);

#endif // ISTORE_H
