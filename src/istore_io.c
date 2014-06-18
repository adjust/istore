#include "istore_io.h"

void
parse_istore(ISParser *parser)
{
    int key;
    long val;

    parser->state  = WKEY;
    parser->ptr    = parser->begin;
    parser->buflen = 0;
    while(1)
    {
        if (parser->state == WKEY)
        {
            while (isspace(*(parser->ptr)))
                parser->ptr++;
            key = strtol(parser->ptr, &parser->ptr, 10);
            parser->state = WEQ;
        }
        else if (parser->state == WEQ)
        {
            if (*(parser->ptr) == '=')
            {
                parser->state = WGT;
                parser->ptr++;
            }
            else if (!isspace(*(parser->ptr)))
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
            int key_len;
            int val_len;
            while (isspace(*(parser->ptr)))
                parser->ptr++;
            val = strtol(parser->ptr, &parser->ptr, 10);
            parser->state = WDEL;
            key_len = get_digit_num(key);
            val_len = get_digit_num(val);
            Pairs_insert(parser->pairs, key, val, key_len, val_len);
            parser->buflen += key_len + val_len + 7;
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

size_t get_digit_num(long number)
{
    size_t count = 0;
    if( number == 0 || number < 0 )
        ++count;
    while( number != 0 )
    {
        number /= 10;
        ++count;
    }
    return count;
}

Datum
istore_in(PG_FUNCTION_ARGS)
{
    ISParser  parser;
    IStore   *out;
    parser.begin = PG_GETARG_CSTRING(0);
    parser.pairs = palloc0(sizeof(ISPairs));
    Pairs_init(parser.pairs, 1);
    parse_istore(&parser);
    Pairs_sort(parser.pairs);
    out = palloc0(sizeof *out);
    SET_VARSIZE(out, VARHDRSZ + sizeof *out + parser.pairs->used * sizeof(ISPair)+ sizeof(ISPairs*));
    out->buflen = parser.buflen;
    out->len = parser.pairs->used;
    out->pairs = parser.pairs->pairs;
    PG_RETURN_POINTER(out);
}

Datum
istore_out(PG_FUNCTION_ARGS)
{
    IStore *in = PG_GETARG_IS(0);
    int i;
    char *out = palloc0(in->buflen);
    int ptr = 0;
    for (i=0; i<in->len; ++i)
    {
        ptr += sprintf(
            out+ptr,
            "\"%d\"=>\"%ld\",",
            in->pairs[i].key,
            in->pairs[i].val
        );
    }
    out[in->buflen - 1] = '\0';
    PG_RETURN_CSTRING(out);
}
