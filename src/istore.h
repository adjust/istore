#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"
#include "utils/array.h"
#include "device_type.h"
#include "country.h"
#include "os_name.h"
#include "catalog/pg_type.h"

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

/*
 * macro to create a c string representation of a
 * varlena postgres text. allocates extra memory with palloc.
 * expects the datum to be NULL terminated
 */
#define DATUM_TO_CSTRING(_datum, _str, _len) \
    do {                                     \
    _len = VARSIZE(_datum) - VARHDRSZ;       \
    _str = palloc0(_len + 1);                \
    memcpy(_str, VARDATA(_datum), _len);     \
    } while(0)

extern void get_typlenbyvalalign(Oid eltype, int16 *i_typlen, bool *i_typbyval, char *i_typalign);

struct ISPair {
    int  key;
    long val;
    bool null;
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
extern void is_pairs_insert(ISPairs *pairs, int key, long val, int type);
extern int  is_pairs_cmp(const void *a, const void *b);
extern void is_pairs_sort(ISPairs *pairs);
extern void is_pairs_deinit(ISPairs *pairs);
extern void is_pairs_debug(ISPairs *pairs);

typedef struct AvlNode AvlNode;
typedef struct AvlNode *Position;
typedef struct AvlNode *AvlTree;

struct AvlNode
{
    int      key;
    long     value;
    AvlTree  left;
    AvlTree  right;
    int      height;
};

extern AvlTree is_make_empty(AvlTree t);
extern int is_compare(int key, AvlTree node);
extern Position is_tree_find(int key, AvlTree t);
extern AvlTree is_insert(int key, int value, AvlTree t);
extern int is_tree_length(Position p);
extern int is_tree_to_pairs(Position p, ISPairs *pairs, int n);

#define DIGIT_WIDTH(_digit, _width) \
    do {                            \
        long _local = _digit;       \
        _width = 0;                 \
        if (_local <= 0)            \
            ++_width;               \
        while (_local != 0)         \
        {                           \
            _local /= 10;           \
            ++_width;               \
        }                           \
    } while (0)

#define PAYLOAD(_pairs) _pairs->pairs
#define PAYLOAD_SIZE(_pairs) (_pairs->used * sizeof(ISPair))

#define SKIP_SPACES(_ptr)  \
    while (isspace(*_ptr)) \
        _ptr++;

#define IS_ESCAPED(_ptr, _escaped) \
    do {                           \
        SKIP_SPACES(_ptr);         \
        _escaped = *_ptr == '"';   \
    } while(0)

/* TODO really respect quotes and dont just skip them */
#define SKIP_ESCAPED(_ptr, _escaped) \
    if (*_ptr == '"')                \
            _ptr++;

/* TODO this looks ugly :( */
#define SKIP_COLON_DELIM(_ptr, _moved)       \
    do {                                     \
        if (*_ptr == ':')                    \
            ++_ptr;                          \
        else                                 \
        {                                    \
            _moved = 0;                      \
            break;                           \
        }                                    \
        if (*_ptr == ':')                    \
            ++_ptr;                          \
        else                                 \
            elog(ERROR, "incomplete delim"); \
        _moved = 2;                          \
    } while(0)

/* TODO: alpha + minus correct? */
#define COUNT_ALPHA(_ptr, _count) \
    while (  isalpha(*_ptr)       \
           || *_ptr == '-'        \
          )                       \
    {                             \
        ++_count;                 \
        ++_ptr;                   \
    }

#define EXTRACT_STRING(_str, _buf, _escaped) \
    do {                                     \
        char *_ptr;                          \
        int  _count = 0;                     \
        SKIP_SPACES(_str);                   \
        SKIP_ESCAPED(_str, _escaped);        \
        _ptr = _str;                         \
        COUNT_ALPHA(_ptr, _count);           \
        _buf = pnstrdup(_str, _count);       \
        _str = _ptr;                         \
        SKIP_ESCAPED(_str, _escaped);        \
    } while (0)

#define GET_PLAIN_KEY(_parser, _key, _escaped)          \
    do {                                                \
        SKIP_SPACES(_parser->ptr);                      \
        SKIP_ESCAPED(_parser->ptr, _escaped);           \
        _key = strtol(_parser->ptr, &_parser->ptr, 10); \
        SKIP_ESCAPED(_parser->ptr, _escaped);           \
    } while (0)

#define GET_DEVICE_KEY(_parser, _key, _escaped)       \
    do {                                              \
        char *_buf;                                   \
        EXTRACT_STRING(_parser->ptr, _buf, _escaped); \
        _key = get_device_type_num(_buf);             \
        pfree(_buf);                                  \
    } while (0)

#define GET_COUNTRY_KEY(_parser, _key, _escaped)      \
    do {                                              \
        char *_buf;                                   \
        EXTRACT_STRING(_parser->ptr, _buf, _escaped); \
        if (strlen(_buf) == 2)                        \
            _key = get_country_num(_buf);             \
        else                                          \
            _key = 0;                                 \
        pfree(_buf);                                  \
    } while (0)

#define GET_OS_NAME_KEY(_parser, _key, _escaped)      \
    do {                                              \
        char *_buf;                                   \
        EXTRACT_STRING(_parser->ptr, _buf, _escaped); \
        _key = get_os_name_num(_buf);                 \
        pfree(_buf);                                  \
    } while (0)

#define GET_COHORT_SIZE(_parser, _key) \
    GET_PLAIN_KEY(_parser, _key, false)

#define GET_C_ISTORE(_parser, _key, _escaped)      \
    do {                                                  \
        int _country_key,                                 \
            _device_key,                                  \
            _os_name_key,                                 \
            _cohort_size = 0,                             \
            _delim_found;                                 \
        _key = 0;                                         \
        GET_COUNTRY_KEY(_parser, _country_key, escaped); \
        SKIP_COLON_DELIM(_parser->ptr, _delim_found);     \
        GET_DEVICE_KEY(_parser, _device_key, false);   \
        SKIP_COLON_DELIM(_parser->ptr, _delim_found);     \
        GET_OS_NAME_KEY(_parser, _os_name_key, false); \
        SKIP_COLON_DELIM(_parser->ptr, _delim_found);     \
        if (_delim_found)                                 \
        {                                                 \
            GET_COHORT_SIZE(_parser, _cohort_size);       \
            parser->type = C_ISTORE_COHORT;               \
        }                                                 \
        else\
        {\
            parser->type = C_ISTORE;               \
        }\
        C_ISTORE_CREATE_KEY(\
            _key,\
            _country_key,\
            _device_key,\
            _os_name_key,\
            _cohort_size\
        );\
    } while (0)

#define GET_VAL(_parser, _val, _escaped) \
    GET_PLAIN_KEY(_parser, _val, _escaped)

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
                + 2 + 4;                                                \
    } while (0)

#define C_ISTORE_COHORT_KEY_LEN(_key, _keylen)                                 \
    do {                                                                \
        int _cohort_width = 0; \
        DIGIT_WIDTH(C_ISTORE_GET_COHORT_SIZE(_key),_cohort_width);      \
        _keylen = get_os_name_length(C_ISTORE_GET_OS_NAME_KEY(_key))    \
                + get_device_type_length(C_ISTORE_GET_DEVICE_KEY(_key)) \
                + _cohort_width + 2 + 6;                                                \
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
    int32   __varlen;
    int     buflen;
    int     len;
    uint8   type;
} IStore;

#define NULL_TYPE_FOR(_type, _nulltype)             \
    do {                                            \
        switch (_type)                              \
        {                                           \
            case PLAIN_ISTORE:                      \
                _nulltype = NULL_VAL_ISTORE;        \
                break;                              \
            case DEVICE_ISTORE:                     \
                _nulltype = NULL_DEVICE_ISTORE;     \
                break;                              \
            case COUNTRY_ISTORE:                    \
                _nulltype = NULL_COUNTRY_ISTORE;    \
                break;                              \
            case OS_NAME_ISTORE:                    \
                _nulltype = NULL_OS_NAME_ISTORE;    \
                break;                              \
            case C_ISTORE:                          \
                _nulltype = NULL_C_ISTORE;          \
                break;                              \
            case C_ISTORE_COHORT:                   \
                _nulltype = NULL_C_ISTORE;          \
                break;                              \
            default:                                \
                elog(ERROR, "unknown istore type"); \
        }                                           \
    } while (0)

#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define ISHDRSZ VARHDRSZ + sizeof(int) + sizeof(int) + sizeof(uint8)
#define ISTORE_SIZE(x) (ISHDRSZ + x->len * sizeof(ISPair))
#define FIRST_PAIR(x) ((ISPair*)((char *) x + ISHDRSZ))

#define COPY_ISTORE(_dst, _src)               \
    do {                                      \
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


ISPair* is_find(IStore *is, int key);
Datum array_to_istore(Datum *data, int count, bool *nulls);

#endif // ISTORE_H
