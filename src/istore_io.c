#include "istore.h"

#define WKEY 0
#define WVAL 1
#define WEQ  2
#define WGT  3
#define WDEL 4

typedef struct ISParser {
    char    *begin;
    char    *ptr;
    int      state;
    AvlNode *tree;
    uint8    type;
} ISParser;

static Datum is_parse_istore(ISParser *parser);

static Datum
is_parse_istore(ISParser *parser)
{
    IStore  *out;
    ISPairs *pairs;
    int32 key;
    long  val;

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
            GET_PLAIN_KEY(parser, key);
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
                elog(ERROR, "unexpected sign %c, expected eq", *(parser->ptr));
        }
        else if (parser->state == WGT)
        {
            if (*(parser->ptr) == '>')
            {
                parser->state = WVAL;
                parser->ptr++;
            }
            else
                elog(ERROR, "unexpected sign %c", *(parser->ptr));
        }
        else if (parser->state == WVAL)
        {
            bool null = false;
            SKIP_SPACES(parser->ptr);
            SKIP_ESCAPED(parser->ptr);
            GET_VAL(parser, val, null);
            SKIP_ESCAPED(parser->ptr);
            parser->state = WDEL;
            parser->tree = is_insert(key, val, null, parser->tree);
        }
        else if (parser->state == WDEL)
        {
            if (*(parser->ptr) == '\0')
                break;
            else if (*(parser->ptr) == ',')
                parser->state = WKEY;
            parser->ptr++;
        }
        else
        {
            elog(ERROR, "unknown parser state");
        }
    }

    pairs = palloc0(sizeof(ISPairs));
    is_pairs_init(pairs, 200, parser->type);
    is_tree_to_pairs(parser->tree, pairs, 0);
    is_make_empty(parser->tree);
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
    ISPair *pairs;

    if (in->len == 0)
    {
        out = palloc0(1);
        PG_RETURN_CSTRING(out);
    }
    out = palloc0(in->buflen + 1);
    pairs = FIRST_PAIR(in);
    for (i = 0; i<in->len; ++i)
    {
        if (pairs[i].null)
            ptr += sprintf(
                out+ptr,
                "\"%d\"=>NULL, ",
                pairs[i].key
            );
        else
            ptr += sprintf(
                out+ptr,
                "\"%d\"=>\"%ld\", ",
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
    parser.type  = PLAIN_ISTORE;
    return is_parse_istore(&parser);
}

PG_FUNCTION_INFO_V1(istore_recv);
Datum
istore_recv(PG_FUNCTION_ARGS)
{
    IStore *result;
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    int i = 0;
    ISPairs *creator = palloc0(sizeof *creator);
    int32 len = pq_getmsgint(buf, 4);
    uint8 type = pq_getmsgbyte(buf);
    is_pairs_init(creator, len, type);
    for (; i < len; ++i)
    {
        int32 key  = pq_getmsgint(buf, 4);
        long  val  = pq_getmsgint64(buf);
        bool  null = pq_getmsgbyte(buf);
        if (null)
            is_pairs_insert(creator, key, val, null_type_for(type));
        else
            is_pairs_insert(creator, key, val, type);
    }
    FINALIZE_ISTORE(result, creator);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_send);
Datum
istore_send(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    ISPair *pairs= FIRST_PAIR(in);
    int i = 0;
    StringInfoData buf;
    pq_begintypsend(&buf);
    pq_sendint(&buf, in->len, 4);
    pq_sendbyte(&buf, in->type);
    for (; i < in->len; ++i)
    {
        int32 key = pairs[i].key;
        long val = pairs[i].val;
        pq_sendint(&buf, key, 4);
        pq_sendint64(&buf, val);
        pq_sendbyte(&buf, pairs[i].null);
    }
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}
