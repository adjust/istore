/*
 * input and output functions for istore
 */

#include "istore.h"
#include "is_parser.h"
#include "libpq/pqformat.h"
#include "utils/builtins.h"

PG_FUNCTION_INFO_V1(istore_out);
Datum
istore_out(PG_FUNCTION_ARGS)
{
    IStore       *in;
    int           i;
    char         *out,
                 *walk;
    IStorePair   *pairs;

    in = PG_GETARG_IS(0);

    if (in->len == 0)
    {
        out = palloc0(1);
        PG_RETURN_CSTRING(out);
    }
    out = palloc0(in->buflen + 1);
    pairs = FIRST_PAIR(in, IStorePair);
    walk = out;

    for (i = 0; i<in->len; ++i)
    {
        *walk++ = '"';
        pg_ltoa(pairs[i].key, walk);
        while (*++walk != '\0') ;

        *walk++ = '"';
        *walk++ = '=';
        *walk++ = '>';
        *walk++ = '"';
        pg_ltoa(pairs[i].val, walk);
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
	else if (parser.begin[0] == '(')
		tree = is_parse_arr(&parser);
	else
		tree = is_parse(&parser);

    pairs = palloc0(sizeof(IStorePairs));
    n = is_tree_length(tree);
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

/*
 * json representation of an istore
 */
PG_FUNCTION_INFO_V1(istore_to_json);
Datum
istore_to_json(PG_FUNCTION_ARGS)
{
    IStore         *is = PG_GETARG_IS(0);
    IStorePair     *pairs;
    int             i;
    StringInfoData  dst;

    if (is->len == 0)
        PG_RETURN_TEXT_P(cstring_to_text_with_len("{}", 2));

    pairs   = FIRST_PAIR(is, IStorePair);
    initStringInfo(&dst);
    appendStringInfoChar(&dst, '{');

    for (i = 0; i < is->len; i++)
    {
        char            buf[12];
        appendStringInfoString(&dst, "\"");
        pg_ltoa(pairs[i].key, buf);
        appendStringInfoString(&dst, buf);
        appendStringInfoString(&dst, "\": ");
        pg_ltoa(pairs[i].val, buf);
        appendStringInfoString(&dst, buf);
        if (i + 1 != is->len)
            appendStringInfoString(&dst, ", ");
    }
    appendStringInfoChar(&dst, '}');

    PG_RETURN_TEXT_P(cstring_to_text(dst.data));
}

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
	else if (parser.begin[0] == '(')
		tree = is_parse_arr(&parser);
	else
		tree = is_parse(&parser);

    pairs = palloc0(sizeof(BigIStorePairs));
    n = is_tree_length(tree);
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

/*
 * json representation of a bigistore
 */
PG_FUNCTION_INFO_V1(bigistore_to_json);
Datum
bigistore_to_json(PG_FUNCTION_ARGS)
{
    BigIStore      *is = PG_GETARG_BIGIS(0);
    BigIStorePair  *pairs;
    int             i;
    StringInfoData  dst;

    if (is->len == 0)
        PG_RETURN_TEXT_P(cstring_to_text_with_len("{}", 2));

    pairs   = FIRST_PAIR(is, BigIStorePair);
    initStringInfo(&dst);
    appendStringInfoChar(&dst, '{');

    for (i = 0; i < is->len; i++)
    {
        char            buf[25 + 1];

        appendStringInfoString(&dst, "\"");
        pg_ltoa(pairs[i].key, buf);
        appendStringInfoString(&dst, buf);
        appendStringInfoString(&dst, "\": ");
        pg_lltoa(pairs[i].val, buf);
        appendStringInfoString(&dst, buf);
        if (i + 1 != is->len)
            appendStringInfoString(&dst, ", ");
    }
    appendStringInfoChar(&dst, '}');
    PG_RETURN_TEXT_P(cstring_to_text(dst.data));
}
