#include "istore.h"

#define WKEY 0
#define WVAL 1
#define WEQ  2
#define WGT  3
#define WDEL 4

#define SKIP_SPACES(_ptr)  \
    while (isspace(*_ptr)) \
        _ptr++;

/* TODO really respect quotes and dont just skip them */
#define SKIP_ESCAPED(_ptr) \
    if (*_ptr == '"')      \
            _ptr++;

#define GET_NUM(_parser, _key)                                                              \
    do {                                                                                    \
        bool neg = false;                                                                   \
        if (*(_parser->ptr) == '-')                                                         \
            neg = true;                                                                     \
        _key = strtol(_parser->ptr, &_parser->ptr, 10);                                     \
        if (neg && _key > 0)                                                                \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("istore \"%s\" is out of range for type integer", _parser->begin)));  \
        else if (!neg && _key < 0)                                                          \
            ereport(ERROR,                                                                  \
                (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),                               \
                errmsg("istore \"%s\" is out of range for type integer", _parser->begin)));  \
    } while (0)

#define EMPTY_ISTORE(_istore)          \
    do {                               \
        _istore = palloc0(ISHDRSZ);    \
        _istore->buflen = 0;           \
        _istore->len = 0;              \
        SET_VARSIZE(_istore, ISHDRSZ); \
    } while(0)

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
    istore_pairs_init(pairs, 200);
    istore_tree_to_pairs(parser->tree, pairs, 0);
    istore_make_empty(parser->tree);
    FINALIZE_ISTORE(out, pairs, ISTOREPAIR);
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
    pairs = FIRST_PAIR(in, ISTOREPAIR);
    for (i = 0; i<in->len; ++i)
    {
        ptr += sprintf(
            out+ptr,
            "\"%d\"=>\"%d\", ",
            pairs[i].key,
            pairs[i].val
        );
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
    FINALIZE_ISTORE_NOSORT(result, creator, ISTOREPAIR);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_send);
Datum
istore_send(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    IStorePair *pairs= FIRST_PAIR(in, ISTOREPAIR);
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
