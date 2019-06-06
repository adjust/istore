#include "is_parser.h"
#include <limits.h>
#include <strings.h>

#define WKEY 0
#define WVAL 1
#define WEQ  2
#define WGT  3
#define WDEL 4
#define WDELVAL 5

#define GET_NUM(ptr, _num, whole)                                            \
    do {                                                                     \
        long _l;                                                             \
        bool neg = false;                                                    \
        if (*(ptr) == '-')                                                   \
            neg = true;                                                      \
        _l   = strtol(ptr, &ptr, 10);                                        \
        _num = _l;                                                           \
        if ((neg && _num > 0) || (_l == LONG_MIN) )                          \
            ereport(ERROR,                                                   \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                \
                errmsg("istore \"%s\" is out of range", whole)));            \
        else if ((!neg && _num < 0) || (_l == LONG_MAX ))                    \
            ereport(ERROR,                                                   \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                \
                errmsg("istore \"%s\" is out of range", whole)));            \
    } while (0)


#define SKIP_SPACES(_ptr)  \
    while (isspace(*_ptr)) \
        _ptr++;

/* TODO really respect quotes and dont just skip them */
#define SKIP_ESCAPED(_ptr) \
    if (*_ptr == '"')      \
            _ptr++;

static inline void
raise_unexpected_sign(char sign, char *str)
{
    ereport(ERROR,
        (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
         errmsg("invalid input syntax for istore: \"%s\"", str),
         errdetail(sign ? "unexpected sign %c, in istore key" : "unexpected end %c", sign)));
}

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
            GET_NUM(parser->ptr, key, parser->begin);
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
                raise_unexpected_sign(*(parser->ptr), parser->begin);
        }
        else if (parser->state == WGT)
        {
            if (*(parser->ptr) == '>')
            {
                parser->state = WVAL;
                parser->ptr++;
            }
            else
                raise_unexpected_sign(*(parser->ptr), parser->begin);
        }
        else if (parser->state == WVAL)
        {
            SKIP_SPACES(parser->ptr);
            SKIP_ESCAPED(parser->ptr);
            GET_NUM(parser->ptr, val, parser->begin);
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
                raise_unexpected_sign(*(parser->ptr), parser->begin);

            parser->ptr++;
        }
        else
        {
            elog(ERROR, "unknown parser state");
        }
    }

    return parser->tree;
}

/*
 * parse arrays tuple cstring into an AVL tree
 */
AvlNode*
is_parse_arr(ISParser *parser)
{
    int32    key;
    int64    val;
    size_t   len = strlen(parser->begin);

    parser->state = WKEY;
    parser->ptr   = index(parser->begin, '[');
    parser->ptr2  = rindex(parser->begin, '[');

    if (parser->ptr == NULL || parser->ptr == parser->ptr2)
        ereport(ERROR,
            (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
             errmsg("invalid input syntax for istore: \"%s\"",
                    parser->begin)));

    parser->tree  = NULL;
    parser->ptr++;
    parser->ptr2++;

    while (parser->ptr < parser->ptr2 && parser->ptr2 < parser->begin + len)
    {
        if (parser->state == WKEY)
        {
            SKIP_SPACES(parser->ptr);
            SKIP_ESCAPED(parser->ptr);
            GET_NUM(parser->ptr, key, parser->begin);
            parser->state = WVAL;
            SKIP_ESCAPED(parser->ptr);
        }
        else if (parser->state == WDEL)
        {
            SKIP_SPACES(parser->ptr);

            if (*(parser->ptr) == ']')
                break;
            else if (*(parser->ptr) == ',')
                parser->state = WDELVAL;
            else
                raise_unexpected_sign(*(parser->ptr), parser->begin);

            parser->ptr++;
        }
        else if (parser->state == WDELVAL)
        {
            SKIP_SPACES(parser->ptr2);

            if (*(parser->ptr2) == ']')
                break;
            else if (*(parser->ptr2) == ',')
                parser->state = WKEY;
            else
                raise_unexpected_sign(*(parser->ptr2), parser->begin);

            parser->ptr2++;
        }
        else if (parser->state == WVAL)
        {
            SKIP_SPACES(parser->ptr2);
            SKIP_ESCAPED(parser->ptr2);
            GET_NUM(parser->ptr2, val, parser->begin);
            SKIP_ESCAPED(parser->ptr2);

            parser->state = WDEL;
            parser->tree = is_tree_insert(parser->tree, key, val);
        }
        else
        {
            elog(ERROR, "unknown parser state");
        }
    }

    return parser->tree;
}
