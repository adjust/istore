#include "istore.h"

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
    uint8    type;
};

typedef struct ISParser ISParser;

static Datum is_parse_istore(ISParser *parser);

static Datum
is_parse_istore(ISParser *parser)
{
    IStore   *out;
    ISPairs  *pairs;

    int  key;
    long val;
    bool escaped;

    pairs = palloc0(sizeof(ISPairs));
    is_pairs_init(pairs, 200);
    pairs->type = parser->type;

    parser->state = WKEY;
    parser->ptr   = parser->begin;
    parser->tree  = NULL;
    IS_ESCAPED(parser->ptr, escaped);
    while(1)
    {
        if (parser->state == WKEY)
        {
            switch (parser->type) {
                case PLAIN_ISTORE:
                    GET_PLAIN_KEY(parser, key, escaped);
                    break;
                case DEVICE_ISTORE:
                    GET_DEVICE_KEY(parser, key, escaped);
                    break;
                case COUNTRY_ISTORE:
                    GET_COUNTRY_KEY(parser, key, escaped);
                    break;
                case OS_NAME_ISTORE:
                    GET_OS_NAME_KEY(parser, key, escaped);
                    break;
                default:
                    elog(ERROR, "unknown parser type");
            }
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
    is_tree_to_pairs(parser->tree, pairs, 0);
    is_make_empty(parser->tree);
    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
}

static Datum is_serialize_istore(IStore *in);

static Datum
is_serialize_istore(IStore *in)
{
    int   i,
          ptr = 0;
    char *out;
    ISPair *pairs;

    out = palloc0(in->buflen);
    pairs = FIRST_PAIR(in);
    for (i = 0; i<in->len; ++i)
    {
        if (pairs[i].null)
        {
            ptr += sprintf(
                out+ptr,
                "\"%d\"=>NULL,",
                pairs[i].key
            );
        }
        else
        {
            switch (in->type)
            {
                case PLAIN_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%d\"=>\"%ld\",",
                        pairs[i].key,
                        pairs[i].val
                    );
                    break;
                case DEVICE_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>\"%ld\",",
                        get_device_type_string(pairs[i].key),
                        pairs[i].val
                    );
                    break;
                case COUNTRY_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>\"%ld\",",
                        get_country_string(pairs[i].key),
                        pairs[i].val
                    );
                    break;
                case OS_NAME_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>\"%ld\",",
                        get_os_name_string(pairs[i].key),
                        pairs[i].val
                    );
                    break;
                default:
                    elog(ERROR, "serializer: unknown istore type");
            }
        }
    }
    out[in->buflen - 1] = '\0';
    PG_RETURN_CSTRING(out);
}

/*
 * casts for istores
 */
PG_FUNCTION_INFO_V1(type_istore_to_istore);
Datum
type_istore_to_istore(PG_FUNCTION_ARGS)
{
    IStore *in,
           *result;
    ISPair *pairs;
    int i;

    in = PG_GETARG_IS(0);
    COPY_ISTORE(result, in);
    result->type = PLAIN_ISTORE;
    pairs = FIRST_PAIR(result);
    result->buflen = 0;
    for (i = 0; i < result->len; ++i)
    {
        int keylen,
            vallen;
        DIGIT_WIDTH(pairs[i].key, keylen);
        DIGIT_WIDTH(pairs[i].val, vallen);
        result->buflen += keylen + vallen + 7;
    }
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_to_device_istore);
Datum
istore_to_device_istore(PG_FUNCTION_ARGS)
{
    IStore *in,
           *result;
    ISPair *pairs;
    int i;

    in = PG_GETARG_IS(0);
    COPY_ISTORE(result, in);
    pairs = FIRST_PAIR(result);
    result->type   = DEVICE_ISTORE;
    result->buflen = 0;
    for (i = 0; i < result->len; ++i)
    {
        int vallen;
        DIGIT_WIDTH(pairs[i].val, vallen);
        result->buflen += get_device_type_length(pairs[i].key) + vallen + 7;
    }
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_to_country_istore);
Datum
istore_to_country_istore(PG_FUNCTION_ARGS)
{
    IStore *in,
           *result;
    ISPair *pairs;
    int i;

    in = PG_GETARG_IS(0);
    COPY_ISTORE(result, in);
    pairs = FIRST_PAIR(result);
    result->type   = COUNTRY_ISTORE;
    result->buflen = 0;
    for (i = 0; i < result->len; ++i)
    {
        int vallen;
        DIGIT_WIDTH(pairs[i].val, vallen);
        result->buflen += 2 + vallen + 7;
    }
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_to_os_name_istore);
Datum
istore_to_os_name_istore(PG_FUNCTION_ARGS)
{
    IStore *in,
           *result;
    ISPair *pairs;
    int i;

    in = PG_GETARG_IS(0);
    COPY_ISTORE(result, in);
    pairs = FIRST_PAIR(result);
    result->type   = OS_NAME_ISTORE;
    result->buflen = 0;
    for (i = 0; i < result->len; ++i)
    {
        int vallen;
        DIGIT_WIDTH(pairs[i].val, vallen);
        result->buflen += get_os_name_length(pairs[i].key) + vallen + 7;
    }
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(istore_out);
Datum
istore_out(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    return is_serialize_istore(in);
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

PG_FUNCTION_INFO_V1(device_istore_in);
Datum
device_istore_in(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    parser.begin = PG_GETARG_CSTRING(0);
    parser.type  = DEVICE_ISTORE;
    return is_parse_istore(&parser);
}

PG_FUNCTION_INFO_V1(country_istore_in);
Datum
country_istore_in(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    parser.begin = PG_GETARG_CSTRING(0);
    parser.type  = COUNTRY_ISTORE;
    return is_parse_istore(&parser);
}

PG_FUNCTION_INFO_V1(os_name_istore_in);
Datum
os_name_istore_in(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    parser.begin = PG_GETARG_CSTRING(0);
    parser.type  = OS_NAME_ISTORE;
    return is_parse_istore(&parser);
}
