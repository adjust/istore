#ifndef IS_PARSER_H
#define IS_PARSER_H

#include "avl.h"

typedef struct ISParser {
    char    *begin;
    char    *ptr;
    int      state;
    AvlNode *tree;
} ISParser;

AvlNode* parse_istore(ISParser *parser);

#define WKEY 0
#define WVAL 1
#define WEQ  2
#define WGT  3
#define WDEL 4

#define GET_NUM(_parser, _num)                                                              \
    do {                                                                                    \
        long _l;                                                                            \
        bool neg = false;                                                                   \
        if (*(_parser->ptr) == '-')                                                         \
            neg = true;                                                                     \
        _l   = strtol(_parser->ptr, &_parser->ptr, 10);                                     \
        _num = _l;\
        if ((neg && _num > 0) || (_l == LONG_MIN) )                          \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("istore \"%s\" is out of range", _parser->begin)));               \
        else if ((!neg && _num < 0) || (_l == LONG_MAX ))                                                          \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("istore \"%s\" is out of range", _parser->begin)));               \
    } while (0)



#define SKIP_SPACES(_ptr)  \
    while (isspace(*_ptr)) \
        _ptr++;

/* TODO really respect quotes and dont just skip them */
#define SKIP_ESCAPED(_ptr) \
    if (*_ptr == '"')      \
            _ptr++;

#define EMPTY_ISTORE(_istore)          \
    do {                               \
        _istore = palloc0(ISHDRSZ);    \
        _istore->buflen = 0;           \
        _istore->len = 0;              \
        SET_VARSIZE(_istore, ISHDRSZ); \
    } while(0)


#endif // IS_PARSER_H