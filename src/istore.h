#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"
#include "utils/array.h"
#include "device_type.h"
#include "country.h"
#include "os_name.h"

#define NULL_VAL_ISTORE 0
#define PLAIN_ISTORE    1
#define DEVICE_ISTORE   2
#define COUNTRY_ISTORE  3
#define OS_NAME_ISTORE  4

extern void get_typlenbyvalalign(Oid eltype, int16 *i_typlen, bool *i_typbyval, char *i_typalign);

struct ISPair {
    long key;
    long val;
    bool null;
};

typedef struct ISPair ISPair;

struct ISPairs {
    ISPair *pairs;
    size_t  size;
    int     used;
    int     buflen;
    int     type;
};

typedef struct ISPairs ISPairs;

extern void is_pairs_init(ISPairs *pairs, size_t initial_size);
extern void is_pairs_insert(ISPairs *pairs, long key, long val, int type);
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

#define SKIP_ESCAPED(_ptr, _escaped)                     \
    do {                                                 \
        if (_escaped && *_ptr == '"')                    \
            _ptr++;                                      \
        else if (_escaped && *_ptr != '"')               \
            elog(ERROR, "expected '\"', got %c", *_ptr); \
    } while(0)

#define COUNT_ALPHA(_ptr, _count) \
    while (isalpha(*_ptr))        \
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

#define GET_PLAIN_KEY(_parser, _key, _escaped)      \
    SKIP_SPACES(_parser->ptr);                      \
    SKIP_ESCAPED(_parser->ptr, _escaped);           \
    _key = strtol(_parser->ptr, &_parser->ptr, 10); \
    SKIP_ESCAPED(_parser->ptr, _escaped);

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
        _key = get_country_num(_buf);                 \
        pfree(_buf);                                  \
    } while (0)

#define GET_OS_NAME_KEY(_parser, _key, _escaped)      \
    do {                                              \
        char *_buf;                                   \
        EXTRACT_STRING(_parser->ptr, _buf, _escaped); \
        _key = get_os_name_num(_buf);                 \
        pfree(_buf);                                  \
    } while (0)

#define GET_VAL(_parser, _val, _escaped) \
    GET_PLAIN_KEY(_parser, _val, _escaped)

typedef struct
{
    int32   __varlen;
    int     buflen;
    int     len;
} IStore;

#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define ISHDRSZ VARHDRSZ + sizeof(int) + sizeof(int)
#define FIRST_PAIR(x) ((ISPair*)((char *) x + ISHDRSZ))

#define FINALIZE_ISTORE(_istore, _pairs)                                    \
    do {                                                                    \
        is_pairs_sort(_pairs);                                              \
        _istore = palloc(ISHDRSZ + PAYLOAD_SIZE(_pairs));                   \
        _istore->buflen = _pairs->buflen;                                   \
        _istore->len    = _pairs->used;                                     \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_pairs));               \
        memcpy(FIRST_PAIR(_istore), PAYLOAD(_pairs), PAYLOAD_SIZE(_pairs)); \
        is_pairs_deinit(_pairs);                                            \
    } while(0)


ISPair* is_find(IStore *is, long key);
Datum array_to_istore(Datum *data, int count, bool *nulls);

#endif // ISTORE_H
