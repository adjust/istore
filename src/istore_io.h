#ifndef ISTORE_IO_H
#define ISTORE_IO_H

#include "istore.h"
#include "pairs.h"

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
    int      buflen;
};

typedef struct ISParser ISParser;

#define PAYLOAD(_parser) parser.pairs->pairs
#define PAYLOAD_SIZE(_parser) (parser.pairs->used * sizeof(ISPair))

#define IS_ESCAPED(_ptr, _escaped) \
    do {                           \
        while (isspace(*_ptr))     \
            _ptr++;                \
        _escaped = *_ptr == '"';   \
    } while(0)

#define SKIP_ESCAPED(_ptr, _escaped)                     \
    do {                                                 \
        if (_escaped && *_ptr == '"')                    \
            _ptr++;                                      \
        else if (_escaped && *_ptr != '"')               \
            elog(ERROR, "expected '\"', got %c", *_ptr); \
    } while(0)

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
        _istore->buflen = _parser.buflen;                                     \
        _istore->len    = _parser.pairs->used;                                \
        SET_VARSIZE(_istore, ISHDRSZ + PAYLOAD_SIZE(_parser));                \
        memcpy(FIRST_PAIR(_istore), PAYLOAD(_parser), PAYLOAD_SIZE(_parser)); \
    } while(0)

void parse_istore(ISParser *parser);

PG_FUNCTION_INFO_V1(istore_in);
PG_FUNCTION_INFO_V1(istore_out);

Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_out(PG_FUNCTION_ARGS);

#endif // ISTORE_IO_H
