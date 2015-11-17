#include "is_parser.h"
#include <limits.h>

#define WKEY 0
#define WVAL 1
#define WEQ  2
#define WGT  3
#define WDEL 4

#define GET_NUM(_parser, _num)                                               \
    do {                                                                     \
        long _l;                                                             \
        bool neg = false;                                                    \
        if (*(_parser->ptr) == '-')                                          \
            neg = true;                                                      \
        _l   = strtol(_parser->ptr, &_parser->ptr, 10);                      \
        _num = _l;                                                           \
        if ((neg && _num > 0) || (_l == LONG_MIN) )                          \
            ereport(ERROR,                                                   \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                \
                errmsg("istore \"%s\" is out of range", _parser->begin)));   \
        else if ((!neg && _num < 0) || (_l == LONG_MAX ))                    \
            ereport(ERROR,                                                   \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                \
                errmsg("istore \"%s\" is out of range", _parser->begin)));   \
    } while (0)


#define SKIP_SPACES(_ptr)  \
    while (isspace(*_ptr)) \
        _ptr++;

/* TODO really respect quotes and dont just skip them */
#define SKIP_ESCAPED(_ptr) \
    if (*_ptr == '"')      \
            _ptr++;

/*
 * parse cstring into an AVL tree
 */
AvlNode*
is_parse(ISParser *parser)
{
    int32    key;
    int64    val;

    parser->state = WKEY;
    parser->ptr   = parser->begin;
    parser->tree  = NULL;

    while(1)
    {

    	if (parser->state == WKEY)
        {
            SKIP_SPACES(parser->ptr);
            SKIP_ESCAPED(parser->ptr);
            GET_NUM(parser, key);
            parser->state = WEQ;
            SKIP_ESCAPED(parser->ptr);
        }
        else if (parser->state == WEQ)
        {
            SKIP_SPACES(parser->ptr);
            if (*(parser->ptr) == '=')
            {
                parser->state = WGT;
                parser->ptr++;
            }
            else
                ereport(ERROR,
                    (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                     errmsg("invalid input syntax for istore: \"%s\"",
                            parser->begin),
                     errdetail("unexpected sign %c, in istore key", *(parser->ptr))
                     ));
        }
        else if (parser->state == WGT)
        {
            if (*(parser->ptr) == '>')
            {
                parser->state = WVAL;
                parser->ptr++;
            }
            else
                ereport(ERROR,
                    (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                     errmsg("invalid input syntax for istore: \"%s\"",
                            parser->begin),
                     errdetail("unexpected sign %c, expected '>'", *(parser->ptr))
                     ));
        }
        else if (parser->state == WVAL)
        {
            SKIP_SPACES(parser->ptr);
            SKIP_ESCAPED(parser->ptr);
            GET_NUM(parser, val);
            SKIP_ESCAPED(parser->ptr);
            parser->state = WDEL;
            parser->tree = is_tree_insert(parser->tree, key, val);
        }
        else if (parser->state == WDEL)
        {
            SKIP_SPACES(parser->ptr);

            if (*(parser->ptr) == '\0')
                break;
            else if (*(parser->ptr) == ',')
                parser->state = WKEY;
            else
                ereport(ERROR,
                    (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                     errmsg("invalid input syntax for istore: \"%s\"",
                            parser->begin),
                     errdetail("unexpected sign %c, in istore value", *(parser->ptr))
                     ));

            parser->ptr++;
        }
        else
        {
            elog(ERROR, "unknown parser state");
        }
    }

    return parser->tree;
}
