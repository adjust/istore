#include "bigistore.h"
#include "is_parser.h"

PG_FUNCTION_INFO_V1(bigistore_out);
Datum
bigistore_out(PG_FUNCTION_ARGS)
{
    BigIStore     *in;
    int            i;
    char          *out,
                  *walk;
    BigIStorePair *pairs;

    in = PG_GETARG_BIGIS(0);

    if (in->len == 0)
    {
        out = palloc0(1);
        PG_RETURN_CSTRING(out);
    }

    out = palloc0(in->buflen + 1);
    pairs = FIRST_PAIR(in, BigIStorePair);
    walk = out;

    for (i = 0; i<in->len; ++i)
    {
        *walk++ = '"';
        pg_lltoa(pairs[i].key, walk);
        while (*++walk != '\0') ;

        *walk++ = '"';
        *walk++ = '=';
        *walk++ = '>';
        *walk++ = '"';
        pg_lltoa(pairs[i].val, walk);
        while (*++walk != '\0') ;

        *walk++ = '"';
        *walk++ = ',';
        *walk++ = ' ';

    }
    // replace trailing ", " with terminating null
    --walk;
    *--walk = '\0';
    PG_RETURN_CSTRING(out);
}

PG_FUNCTION_INFO_V1(bigistore_in);
Datum
bigistore_in(PG_FUNCTION_ARGS)
{
    ISParser       parser;
    BigIStore      *out;
    BigIStorePairs *pairs;
    AvlNode        *tree;
    int             n;

    parser.begin = PG_GETARG_CSTRING(0);

    if (parser.begin[0] == '\0')
    {
        EMPTY_ISTORE(out);
        PG_RETURN_POINTER(out);
    }

    tree = parse_istore(&parser);

    pairs = palloc0(sizeof(BigIStorePairs));
    n = tree_length(tree);
    bigistore_pairs_init(pairs, n);
    bigistore_tree_to_pairs(tree, pairs);
    istore_make_empty(tree);
    FINALIZE_BIGISTORE(out, pairs);
    PG_RETURN_POINTER(out);
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
    FINALIZE_BIGISTORE(result, creator);
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
