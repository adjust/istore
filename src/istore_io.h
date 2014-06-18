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

typedef struct
{
    int32   __varlen;
    int     buflen;
    int     len;
    ISPair *pairs;
} IStore;

#define PG_GETARG_IS(x) (IStore *)PG_DETOAST_DATUM(PG_GETARG_DATUM(x))

void parse_istore(ISParser *parser);

size_t get_digit_num( long number );

PG_FUNCTION_INFO_V1(istore_in);
PG_FUNCTION_INFO_V1(istore_out);

Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_out(PG_FUNCTION_ARGS);

#endif // ISTORE_IO_H
