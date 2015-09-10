#ifndef IS_PARSER_H
#define IS_PARSER_H

#include "avl.h"
#include <limits.h>
#include "intutils.h"


typedef struct ISParser {
    char    *begin;
    char    *ptr;
    int      state;
    AvlNode *tree;
} ISParser;

AvlNode* parse_istore(ISParser *parser);

#define EMPTY_ISTORE(_istore)          \
    do {                               \
        _istore = palloc0(ISHDRSZ);    \
        _istore->buflen = 0;           \
        _istore->len = 0;              \
        SET_VARSIZE(_istore, ISHDRSZ); \
    } while(0)


#endif // IS_PARSER_H