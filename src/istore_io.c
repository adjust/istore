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
    bool first = true;

    parser->state = WKEY;
    parser->ptr   = parser->begin;
    parser->tree  = NULL;
    if (parser->begin[0] == '\0')
        goto end;

    while(1)
    {
        if (parser->state == WKEY)
        {
            SKIP_SPACES(parser->ptr);
            SKIP_ESCAPED(parser->ptr);
            switch (parser->type)
            {
                case PLAIN_ISTORE:
                    GET_PLAIN_KEY(parser, key);
                    break;
                case DEVICE_ISTORE:
                    GET_DEVICE_KEY(parser, key);
                    break;
                case COUNTRY_ISTORE:
                    GET_COUNTRY_KEY(parser, key);
                    break;
                case OS_NAME_ISTORE:
                    GET_OS_NAME_KEY(parser, key);
                    break;
                case C_ISTORE:
                    GET_C_ISTORE(parser, key);
                    if (parser->type == C_ISTORE_COHORT && !first)
                        elog(ERROR, "cannot mix cistores with and without cohort size");
                    break;
                case C_ISTORE_COHORT:
                    GET_C_ISTORE(parser, key);
                    if (parser->type == C_ISTORE)
                        elog(ERROR, "cannot mix cistores with and without cohort size");
                    break;
                default:
                    elog(ERROR, "unknown parser type");
            }
            first = false;
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
end:
    pairs = palloc0(sizeof(ISPairs));
    is_pairs_init(pairs, 200, parser->type);
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
        {
            switch (in->type)
            {
                case PLAIN_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%d\"=>NULL, ",
                        pairs[i].key
                    );
                    break;
                case DEVICE_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>NULL, ",
                        get_device_type_string(pairs[i].key)
                    );
                    break;
                case COUNTRY_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>NULL, ",
                        get_country_string(pairs[i].key)
                    );
                    break;
                case OS_NAME_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>NULL, ",
                        get_os_name_string(pairs[i].key)
                    );
                    break;
                default:
                    elog(ERROR, "unknown istore type");
            }
        }
        else
        {
            switch (in->type)
            {
                case PLAIN_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%d\"=>\"%ld\", ",
                        pairs[i].key,
                        pairs[i].val
                    );
                    break;
                case DEVICE_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>\"%ld\", ",
                        get_device_type_string(pairs[i].key),
                        pairs[i].val
                    );
                    break;
                case COUNTRY_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>\"%ld\", ",
                        get_country_string(pairs[i].key),
                        pairs[i].val
                    );
                    break;
                case OS_NAME_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s\"=>\"%ld\", ",
                        get_os_name_string(pairs[i].key),
                        pairs[i].val
                    );
                    break;
                case C_ISTORE:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s::%s::%s\"=>\"%ld\", ",
                        get_country_string(C_ISTORE_GET_COUNTRY_KEY(pairs[i].key)),
                        get_device_type_string(C_ISTORE_GET_DEVICE_KEY(pairs[i].key)),
                        get_os_name_string(C_ISTORE_GET_OS_NAME_KEY(pairs[i].key)),
                        pairs[i].val
                    );
                    break;
                case C_ISTORE_COHORT:
                    ptr += sprintf(
                        out+ptr,
                        "\"%s::%s::%s::%d\"=>\"%ld\", ",
                        get_country_string(C_ISTORE_GET_COUNTRY_KEY(pairs[i].key)),
                        get_device_type_string(C_ISTORE_GET_DEVICE_KEY(pairs[i].key)),
                        get_os_name_string(C_ISTORE_GET_OS_NAME_KEY(pairs[i].key)),
                        C_ISTORE_GET_COHORT_SIZE(pairs[i].key),
                        pairs[i].val
                    );
                    break;
                default:
                    elog(ERROR, "serializer: unknown istore type %d", in->type);
            }
        }
    }
    // replace trailing , with terminating null
    out[in->buflen - 2] = '\0';
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
        result->buflen += keylen + vallen + BUFLEN_OFFSET;
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
        result->buflen += get_device_type_length(pairs[i].key) + vallen + BUFLEN_OFFSET;
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
        result->buflen += 2 + vallen + BUFLEN_OFFSET;
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
        result->buflen += get_os_name_length(pairs[i].key) + vallen + BUFLEN_OFFSET;
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

PG_FUNCTION_INFO_V1(cistore_out);
Datum
cistore_out(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    return is_serialize_istore(in);
}

PG_FUNCTION_INFO_V1(cistore_in);
Datum
cistore_in(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    parser.begin = PG_GETARG_CSTRING(0);
    parser.type  = C_ISTORE;
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

PG_FUNCTION_INFO_V1(cistore_from_types);
Datum
cistore_from_types(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    int32 key = 0,
          keylen,
          vallen,
          ptr = 0;
    char *out;
    country     c  = PG_GETARG_COUNTRY(0);
    device_type d  = PG_GETARG_DEVICE_TYPE(1);
    os_name     o  = PG_GETARG_OS_NAME(2);
    long        val = PG_GETARG_INT64(3);

    C_ISTORE_CREATE_KEY(key, c, d, o, 0);
    C_ISTORE_KEY_LEN(key, keylen);
    DIGIT_WIDTH(val, vallen);

    out = palloc0(vallen + keylen + 6 + 1);

    ptr += sprintf(
        out+ptr,
        "\"%s::%s::%s\"=>\"%ld\"",
        get_country_string(C_ISTORE_GET_COUNTRY_KEY(key)),
        get_device_type_string(C_ISTORE_GET_DEVICE_KEY(key)),
        get_os_name_string(C_ISTORE_GET_OS_NAME_KEY(key)),
        val
    );

    parser.begin = out;
    parser.type  = C_ISTORE;
    return is_parse_istore(&parser);
}

PG_FUNCTION_INFO_V1(cistore_cohort_from_types);
Datum
cistore_cohort_from_types(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    int32 key = 0,
          keylen,
          vallen,
          ptr = 0;
    char *out;
    country     c   = PG_GETARG_COUNTRY(0);
    device_type d   = PG_GETARG_DEVICE_TYPE(1);
    os_name     o   = PG_GETARG_OS_NAME(2);
    uint16      s   = PG_GETARG_UINT16(3);
    long        val = PG_GETARG_INT64(4);

    C_ISTORE_CREATE_KEY(key, c, d, o, s);
    C_ISTORE_COHORT_KEY_LEN(key, keylen);
    DIGIT_WIDTH(val, vallen);

    out = palloc0(vallen + keylen + 6 + 1);
    ptr += sprintf(
        out+ptr,
        "\"%s::%s::%s::%d\"=>\"%ld\"",
        get_country_string(C_ISTORE_GET_COUNTRY_KEY(key)),
        get_device_type_string(C_ISTORE_GET_DEVICE_KEY(key)),
        get_os_name_string(C_ISTORE_GET_OS_NAME_KEY(key)),
        C_ISTORE_GET_COHORT_SIZE(key),
        val
    );

    parser.begin = out;
    parser.type  = C_ISTORE;
    return is_parse_istore(&parser);
}
