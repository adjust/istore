#include "bigistore.h"
#include "is_parser.h"
#include <limits.h>
#include "intutils.h"
#define GET_NUM(_parser, _num)                                                              \
    do {                                                                                    \
        long _l;                                                                            \
        bool neg = false;                                                                   \
        if (*(_parser->ptr) == '-')                                                         \
            neg = true;                                                                     \
        _l   = strtol(_parser->ptr, &_parser->ptr, 10);                                     \
        _num = _l;\
        if (neg && _num > 0 || _l == LONG_MIN )                          \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("bigistore \"%s\" is out of range", _parser->begin)));               \
        else if (!neg && _num < 0 || _l == LONG_MAX )                                                          \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("bigistore \"%s\" is out of range", _parser->begin)));               \
    } while (0)


typedef struct BigISParser {
    char       *begin;
    char       *ptr;
    int         state;
    AvlNode *tree;
} BigISParser;

static Datum bigistore_parse_bigistore(BigISParser *parser);

static Datum
bigistore_parse_bigistore(BigISParser *parser)
{
    BigIStore      *out;
    BigIStorePairs *pairs;
    int32           key;
    int64           val;
    int             n;

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
                     errmsg("invalid input syntax for bigistore: \"%s\"",
                            parser->begin),
                     errdetail("unexpected sign %c, in bigistore key", *(parser->ptr))
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
                     errmsg("invalid input syntax for bigistore: \"%s\"",
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
            parser->tree = istore_insert(parser->tree, key, val);
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
                     errmsg("invalid input syntax for bigistore: \"%s\"",
                            parser->begin),
                     errdetail("unexpected sign %c, in bigistore value", *(parser->ptr))
                     ));

            parser->ptr++;
        }
        else
        {
            elog(ERROR, "unknown parser state");
        }
    }

    pairs = palloc0(sizeof(BigIStorePairs));
    n = tree_length(parser->tree);
    bigistore_pairs_init(pairs, n);
    bigistore_tree_to_pairs(parser->tree, pairs, 0);
    istore_make_empty(parser->tree);
    FINALIZE_BIGISTORE_NOSORT(out, pairs);
    PG_RETURN_POINTER(out);
}

PG_FUNCTION_INFO_V1(bigistore_out);
Datum
bigistore_out(PG_FUNCTION_ARGS)
{
    BigIStore *in = PG_GETARG_BIGIS(0);
    int     i,
            ptr = 0;
    char   *out;
    BigIStorePair *pairs;

    if (in->len == 0)
    {
        out = palloc0(1);
        PG_RETURN_CSTRING(out);
    }
    out = palloc0(in->buflen + 1);
    pairs = FIRST_PAIR(in, BigIStorePair);
    for (i = 0; i<in->len; ++i)
    {
        out[ptr++] = '"';
        ptr += is_ltoa(pairs[i].key, out+ptr);
        memcpy(out+ptr, "\"=>\"", 5);
        ptr += 4;
        ptr += is_lltoa(pairs[i].val, out+ptr);
        memcpy(out+ptr, "\", ", 4);
        ptr += 3;
    }
    // replace trailing , with terminating null
    out[in->buflen - 2] = '\0';
    PG_RETURN_CSTRING(out);
}

PG_FUNCTION_INFO_V1(bigistore_in);
Datum
bigistore_in(PG_FUNCTION_ARGS)
{
    BigISParser  parser;
    parser.begin = PG_GETARG_CSTRING(0);
    return bigistore_parse_bigistore(&parser);
}

PG_FUNCTION_INFO_V1(bigistore_recv);
Datum
bigistore_recv(PG_FUNCTION_ARGS)
{
    BigIStore *result;
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    int i = 0;
    BigIStorePairs *creator = palloc0(sizeof *creator);
    int32 len = pq_getmsgint(buf, 4);
    bigistore_pairs_init(creator, len);
    for (; i < len; ++i)
    {
        int32  key  = pq_getmsgint(buf, 4);
        int64  val  = pq_getmsgint64(buf);
        bigistore_pairs_insert(creator, key, val);
    }
    FINALIZE_BIGISTORE_NOSORT(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(bigistore_send);
Datum
bigistore_send(PG_FUNCTION_ARGS)
{
    BigIStore *in = PG_GETARG_BIGIS(0);
    BigIStorePair *pairs= FIRST_PAIR(in, BigIStorePair);
    int i = 0;
    StringInfoData buf;
    pq_begintypsend(&buf);
    pq_sendint(&buf, in->len, 4);
    for (; i < in->len; ++i)
    {
        int32 key = pairs[i].key;
        int64 val = pairs[i].val;
        pq_sendint(&buf, key, 4);
        pq_sendint64(&buf, val);
    }
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}
