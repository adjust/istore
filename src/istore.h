#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"

struct ISPair {
    long key;
    long val;
    int  keylen;
    int  vallen;
};

typedef struct ISPair ISPair;

struct ISPairs {
    ISPair *pairs;
    size_t  size;
    int     used;
    int     buflen;
};

typedef struct ISPairs ISPairs;

void Pairs_init(ISPairs *pairs, size_t initial_size);
void Pairs_insert(ISPairs *pairs, long key, long val);
int  Pairs_cmp(const void *a, const void *b);
void Pairs_sort(ISPairs *pairs);
void Pairs_debug(ISPairs *pairs);

/* TODO remove either that or the following macro */
size_t get_digit_num(long number);

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

#define WKEY 0
#define WVAL 1
#define WEQ  2
#define WGT  3
#define WDEL 4

struct ISParser {
    char    *begin;
    char    *ptr;
    int      state;
    ISPairs *pairs;
};

typedef struct ISParser ISParser;

#define PAYLOAD(_parser) parser.pairs->pairs
#define PAYLOAD_SIZE(_parser) (parser.pairs->used * sizeof(ISPair))

#define SKIP_SPACES(_ptr)  \
    while (isspace(*_ptr)) \
        _ptr++;

#define IS_ESCAPED(_ptr, _escaped) \
    do {                           \
        SKIP_SPACES(_ptr)          \
        _escaped = *_ptr == '"';   \
    } while(0)

#define SKIP_ESCAPED(_ptr, _escaped)                     \
    do {                                                 \
        if (_escaped && *_ptr == '"')                    \
            _ptr++;                                      \
        else if (_escaped && *_ptr != '"')               \
            elog(ERROR, "expected '\"', got %c", *_ptr); \
    } while(0)

#define GET_KEY(_parser, _key, _escaped)            \
    SKIP_SPACES(_parser->ptr)                       \
    SKIP_ESCAPED(_parser->ptr, _escaped);           \
    _key = strtol(_parser->ptr, &_parser->ptr, 10); \
    SKIP_ESCAPED(_parser->ptr, _escaped);

#define GET_VAL(_parser, _val, _escaped) \
    GET_KEY(_parser, _val, _escaped)

typedef struct
{
    int32   __varlen;
    int     buflen;
    int     len;
} IStore;

#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))
#define ISHDRSZ VARHDRSZ + sizeof(int) + sizeof(int)
#define FIRST_PAIR(x) ((ISPair*)((char *) x + ISHDRSZ))

#define FINALIZE_ISTORE(_istore, _parser)                                     \
    do {                                                                      \
        _istore = palloc(ISHDRSZ + PAYLOAD_SIZE(_parser));                    \
        _istore->buflen = _parser.pairs->buflen;                                     \
        _istore->len    = _parser.pairs->used;                                \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_parser));                \
        memcpy(FIRST_PAIR(_istore), PAYLOAD(_parser), PAYLOAD_SIZE(_parser)); \
    } while(0)

void parse_istore(ISParser *parser);

Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_out(PG_FUNCTION_ARGS);

ISPair* find(IStore *is, long key);

Datum exist(PG_FUNCTION_ARGS);
Datum fetchval(PG_FUNCTION_ARGS);

#endif // ISTORE_H
