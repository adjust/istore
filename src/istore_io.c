#include "istore.h"

PG_FUNCTION_INFO_V1(istore_in);
PG_FUNCTION_INFO_V1(istore_out);

#define WKEY 0
#define WVAL 1
#define WEQ  2
#define WGT  3
#define WDEL 4

struct ISParser {
    char    *begin;
    char    *ptr;
    int      state;
    AvlNode *tree;
};

typedef struct ISParser ISParser;

static void is_parse_istore(ISParser *parser);

static void
is_parse_istore(ISParser *parser)
{
    long key;
    long val;
    bool escaped;

    parser->state = WKEY;
    parser->ptr   = parser->begin;
    parser->tree  = NULL;
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
            parser->tree = is_insert(key, val, parser->tree);
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
    ISPairs  *pairs;
    parser.begin = PG_GETARG_CSTRING(0);
    pairs = palloc0(sizeof(ISPairs));
    is_pairs_init(pairs, 200);
    is_parse_istore(&parser);
    is_tree_to_pairs(parser.tree, pairs, 0);
    is_make_empty(parser.tree);
    FINALIZE_ISTORE(out, pairs);
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
