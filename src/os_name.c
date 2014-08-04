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
    PG_RETURN_POINTER(result);
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
        case 1:  return create_string(CONST_STRING("android"));
        case 2:  return create_string(CONST_STRING("ios"));
        case 3:  return create_string(CONST_STRING("windows"));
        case 4:  return create_string(CONST_STRING("windows-phone"));
        case 5:  return create_string(CONST_STRING("unknown"));
        default: return NULL;
    }
}

int
get_os_name_length(uint8 num)
{
    switch (num)
    {
        case 1:  return (CONST_STRING_LENGTH("android"));
        case 2:  return (CONST_STRING_LENGTH("ios"));
        case 3:  return (CONST_STRING_LENGTH("windows"));
        case 4:  return (CONST_STRING_LENGTH("windows-phone"));
        case 5:  return (CONST_STRING_LENGTH("unknown"));
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
        case 'a': return check_os_name_num(str, 1);
        case 'i': return check_os_name_num(str, 2);
        case 'w':
                  if (str[7] == '-')
                      return check_os_name_num(str, 4);
                  else
                      return check_os_name_num(str, 3);
        case 'u': return check_os_name_num(str, 5);
        default : return 0;
    }
}
