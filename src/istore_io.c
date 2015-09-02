#include "istore.h"
#include "is_parser.h"
#include "intutils.h"

#define GET_NUM(_parser, _num)                                                              \
    do {                                                                                    \
        bool neg = false;                                                                   \
        if (*(_parser->ptr) == '-')                                                         \
            neg = true;                                                                     \
        _num = strtol(_parser->ptr, &_parser->ptr, 10);                                     \
        if (neg && _num > 0)                                                                \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("istore \"%s\" is out of range", _parser->begin)));  \
        else if (!neg && _num < 0)                                                          \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("istore \"%s\" is out of range", _parser->begin)));  \
    } while (0)

typedef struct ISParser {
    char    *begin;
    char    *ptr;
    int      state;
    AvlNode *tree;
} ISParser;

static Datum istore_parse_istore(ISParser *parser);

static Datum
istore_parse_istore(ISParser *parser)
{
    IStore  *out;
    IStorePairs *pairs;
    int32    key;
    int32    val;
    int      n;

    parser->state = WKEY;
    parser->ptr   = parser->begin;
    parser->tree  = NULL;
    if (parser->begin[0] == '\0')
    {
        EMPTY_ISTORE(out);
        PG_RETURN_POINTER(out);
    }

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
            parser->tree = tree_insert(parser->tree, key, val);
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

    pairs = palloc0(sizeof(IStorePairs));
    n = tree_length(parser->tree);
    istore_pairs_init(pairs, n);
    istore_tree_to_pairs(parser->tree, pairs, 0);
    istore_make_empty(parser->tree);
    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(istore_out);
Datum
istore_out(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    int     i,
            ptr = 0;
    char   *out;
    IStorePair *pairs;

    if (in->len == 0)
    {
        out = palloc0(1);
        PG_RETURN_CSTRING(out);
    }
    out = palloc0(in->buflen + 1);
    pairs = FIRST_PAIR(in, IStorePair);
    for (i = 0; i<in->len; ++i)
    {
        out[ptr++] = '"';
        ptr += is_ltoa(pairs[i].key, out+ptr);
        memcpy(out+ptr, "\"=>\"", 5);
        ptr += 4;
        ptr += is_ltoa(pairs[i].val, out+ptr);
        memcpy(out+ptr, "\", ", 4);
        ptr += 3;
    }
    // replace trailing , with terminating null
    out[in->buflen - 2] = '\0';
    PG_RETURN_CSTRING(out);
}

PG_FUNCTION_INFO_V1(istore_in);
Datum
istore_in(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    parser.begin = PG_GETARG_CSTRING(0);
    return istore_parse_istore(&parser);
}

PG_FUNCTION_INFO_V1(istore_recv);
Datum
istore_recv(PG_FUNCTION_ARGS)
{
    IStore *result;
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    int i = 0;
    IStorePairs *creator = palloc0(sizeof *creator);
    int32 len = pq_getmsgint(buf, 4);
    istore_pairs_init(creator, len);
    for (; i < len; ++i)
    {
        int32  key  = pq_getmsgint(buf, 4);
        int32  val  = pq_getmsgint(buf, 4);
        istore_pairs_insert(creator, key, val);
    }
    FINALIZE_ISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_send);
Datum
istore_send(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    IStorePair *pairs= FIRST_PAIR(in, IStorePair);
    int i = 0;
    StringInfoData buf;
    pq_begintypsend(&buf);
    pq_sendint(&buf, in->len, 4);
    for (; i < in->len; ++i)
    {
        int32 key = pairs[i].key;
        int32 val = pairs[i].val;
        pq_sendint(&buf, key, 4);
        pq_sendint(&buf, val, 4);
    }
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}
