#ifndef ISTORE_PARSER_H
#define ISTORE_PARSER_H

#include "postgres.h"
#include "avl.h"

typedef struct ISParser {
    char    *begin;
    char    *ptr;
    char    *ptr2;	/* parsing from arrays */
    int      state;
    AvlNode *tree;
} ISParser;

AvlNode* is_parse(ISParser *parser);
AvlNode* is_parse_arr(ISParser *parser);

#define EMPTY_ISTORE(_istore)          \
    do {                               \
        _istore = palloc0(ISHDRSZ);    \
        _istore->buflen = 0;           \
        _istore->len = 0;              \
        SET_VARSIZE(_istore, ISHDRSZ); \
    } while(0)


#endif // ISTORE_PARSER_H
