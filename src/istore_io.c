#include "istore.h"

PG_FUNCTION_INFO_V1(istore_in);
PG_FUNCTION_INFO_V1(istore_out);

void
parse_istore(ISParser *parser)
{
    long key;
    long val;
    bool escaped;

    parser->state  = WKEY;
    parser->ptr    = parser->begin;
    IS_ESCAPED(parser->ptr, escaped);
    while(1)
    {
        if (parser->state == WKEY)
        {
            GET_KEY(parser, key, escaped);
            parser->state = WEQ;
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
            GET_VAL(parser, val, escaped);
            parser->state = WDEL;
            Pairs_insert(parser->pairs, key, val);
        }
        else if (parser->state == WDEL)
        {
            if (*(parser->ptr) == ',')
                parser->state = WKEY;
            else if (*(parser->ptr) == '\0')
                break;
            parser->ptr++;
        }
        else
        {
            elog(ERROR, "unknown parser state");
        }
    }
}

Datum
istore_in(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    IStore   *out;
    parser.begin = PG_GETARG_CSTRING(0);
    parser.pairs = palloc0(sizeof(ISPairs));
    Pairs_init(parser.pairs, 200);
    parse_istore(&parser);
    Pairs_sort(parser.pairs);
    FINALIZE_ISTORE(out, parser.pairs);
    PG_RETURN_POINTER(out);
}

Datum
istore_out(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    ISPair *pairs;
    int     i,
            ptr = 0;
    char   *out = palloc0(in->buflen);
    pairs = FIRST_PAIR(in);
    for (i = 0; i<in->len; ++i)
    {
        ptr += sprintf(
            out+ptr,
            "\"%ld\"=>\"%ld\",",
            pairs[i].key,
            pairs[i].val
        );
    }
    out[in->buflen - 1] = '\0';
    PG_RETURN_CSTRING(out);
}
