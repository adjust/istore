#include "istore.h"
#include "is_parser.h"

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
    ISParser     parser;
    IStore      *out;
    IStorePairs *pairs;
    AvlNode     *tree;
    int          n;

    parser.begin = PG_GETARG_CSTRING(0);

    if (parser.begin[0] == '\0')
    {
        EMPTY_ISTORE(out);
        PG_RETURN_POINTER(out);
    }

    tree = parse_istore(&parser);

    pairs = palloc0(sizeof(IStorePairs));
    n = tree_length(tree);
    istore_pairs_init(pairs, n);
    istore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);
    FINALIZE_ISTORE(out, pairs);
    PG_RETURN_POINTER(out);
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
    FINALIZE_ISTORE(result, creator);
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
