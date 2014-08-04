#include "os_name.h"

static uint8 check_os_name_num(const char *str, os_name type);
static int os_name_cmp_internal(os_name a, os_name b);

PG_FUNCTION_INFO_V1(os_name_in);
Datum
os_name_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    os_name result;
    if (str == NULL)
        elog(ERROR, "unknown input os_name");
    LOWER_STRING(str);
    result = get_os_name_num(str);
    if (result == 0)
        elog(ERROR, "unknown input os_name");
    PG_RETURN_OS_NAME(result);
}

PG_FUNCTION_INFO_V1(os_name_out);
Datum
os_name_out(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    PG_RETURN_POINTER(get_os_name_string(a));
}

PG_FUNCTION_INFO_V1(os_name_recv);
Datum
os_name_recv(PG_FUNCTION_ARGS)
{
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    os_name result = pq_getmsgbyte(buf);
    PG_RETURN_OS_NAME(result);
}

PG_FUNCTION_INFO_V1(os_name_send);
Datum
os_name_send(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    StringInfoData buf;

    pq_begintypsend(&buf);
    pq_sendbyte(&buf, a);
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}

PG_FUNCTION_INFO_V1(os_name_lt);
Datum
os_name_lt(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    os_name b = PG_GETARG_OS_NAME(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) < 0);
}

PG_FUNCTION_INFO_V1(os_name_le);
Datum
os_name_le(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    os_name b = PG_GETARG_OS_NAME(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) <= 0);
}

PG_FUNCTION_INFO_V1(os_name_eq);
Datum
os_name_eq(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    os_name b = PG_GETARG_OS_NAME(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) == 0);
}

PG_FUNCTION_INFO_V1(os_name_neq);
Datum
os_name_neq(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    os_name b = PG_GETARG_OS_NAME(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) != 0);
}

PG_FUNCTION_INFO_V1(os_name_ge);
Datum
os_name_ge(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    os_name b = PG_GETARG_OS_NAME(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) >= 0);
}

PG_FUNCTION_INFO_V1(os_name_gt);
Datum
os_name_gt(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    os_name b = PG_GETARG_OS_NAME(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) > 0);
}

PG_FUNCTION_INFO_V1(os_name_cmp);
Datum
os_name_cmp(PG_FUNCTION_ARGS)
{
    os_name a = PG_GETARG_OS_NAME(0);
    os_name b = PG_GETARG_OS_NAME(1);
    PG_RETURN_INT32(os_name_cmp_internal(a,b));
}

static int
os_name_cmp_internal(os_name a, os_name b)
{
    if (a < b)
        return -1;
    if (a > b)
        return 1;
    return 0;
}

char *
get_os_name_string(uint8 num)
{
    switch (num)
    {
        case  20: return create_string(CONST_STRING("android"));
        case  40: return create_string(CONST_STRING("bada"));
        case  60: return create_string(CONST_STRING("blackberry"));
        case  80: return create_string(CONST_STRING("ios"));
        case 100: return create_string(CONST_STRING("linux"));
        case 120: return create_string(CONST_STRING("macos"));
        case 140: return create_string(CONST_STRING("server"));
        case 160: return create_string(CONST_STRING("symbian"));
        case 180: return create_string(CONST_STRING("webos"));
        case 200: return create_string(CONST_STRING("windows"));
        case 220: return create_string(CONST_STRING("windows-phone"));
        case 255: return create_string(CONST_STRING("unknown"));
        default: elog(ERROR, "internal error unexpected num in get_os_name_string");
    }
}

int
get_os_name_length(uint8 num)
{
    switch (num)
    {
        case  20: return (CONST_STRING_LENGTH("android"));
        case  40: return (CONST_STRING_LENGTH("bada"));
        case  60: return (CONST_STRING_LENGTH("blackberry"));
        case  80: return (CONST_STRING_LENGTH("ios"));
        case 100: return (CONST_STRING_LENGTH("linux"));
        case 120: return (CONST_STRING_LENGTH("macos"));
        case 140: return (CONST_STRING_LENGTH("server"));
        case 160: return (CONST_STRING_LENGTH("symbian"));
        case 180: return (CONST_STRING_LENGTH("webos"));
        case 200: return (CONST_STRING_LENGTH("windows"));
        case 220: return (CONST_STRING_LENGTH("windows-phone"));
        case 255: return (CONST_STRING_LENGTH("unknown"));
        default: elog(ERROR, "unknown os_name type");
    }
}

static uint8
check_os_name_num(const char *str, os_name os)
{
    char * expected = get_os_name_string(os);
    if (strcmp(expected, str) != 0)
    {
        pfree(expected);
        return 0;
    }
    pfree(expected);
    return os;
}

uint8
get_os_name_num(char *str)
{
    switch (str[0])
    {
        case 'a': return check_os_name_num(str, 20);
        case 'b': return get_os_name_num_b(str);
        case 'i': return check_os_name_num(str, 80);
        case 'l': return check_os_name_num(str, 100);
        case 'm': return check_os_name_num(str, 120);
        case 's': return get_os_name_num_s(str);
        case 'w': return get_os_name_num_w(str);
        case 'u': return check_os_name_num(str, 255);
        default : return 0;
    }
}

uint8
get_os_name_num_b(char *str)
{
    switch (str[1]) {
        case 'a': return check_os_name_num(str, 40);
        case 'l': return check_os_name_num(str, 60);
        default : return 0;
    }
}

uint8
get_os_name_num_s(char *str)
{
    switch (str[1]) {
        case 'e': return check_os_name_num(str, 140);
        case 'y': return check_os_name_num(str, 160);
        default : return 0;
    }
}

uint8
get_os_name_num_w(char *str)
{
    switch (str[1]) {
        case 'e': return check_os_name_num(str, 180);
        case 'i':
            if(str[7] == '-'  )
                return check_os_name_num(str, 220);
            else
                return check_os_name_num(str, 200);
        default : return 0;
    }
}
