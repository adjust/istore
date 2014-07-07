#include "os_name.h"

static uint8 check_os_name_num(const char *str, os_name type);
static int os_name_cmp_internal(os_name *a, os_name *b);

PG_FUNCTION_INFO_V1(os_name_in);
PG_FUNCTION_INFO_V1(os_name_out);
PG_FUNCTION_INFO_V1(os_name_lt);
PG_FUNCTION_INFO_V1(os_name_le);
PG_FUNCTION_INFO_V1(os_name_eq);
PG_FUNCTION_INFO_V1(os_name_ge);
PG_FUNCTION_INFO_V1(os_name_gt);
PG_FUNCTION_INFO_V1(os_name_cmp);

Datum
os_name_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    os_name *result = palloc0(sizeof *result);
    if ( str == NULL )
    {
        PG_RETURN_POINTER(result);
    }
    LOWER_STRING(str);
    *result = get_os_name_num(str);
    PG_RETURN_POINTER(result);
}

Datum
os_name_out(PG_FUNCTION_ARGS)
{
    os_name *a = (os_name *) PG_GETARG_POINTER(0);
    PG_RETURN_POINTER(get_os_name_string(*a));
}

Datum
os_name_lt(PG_FUNCTION_ARGS)
{
    os_name *a = (os_name *) PG_GETARG_POINTER(0);
    os_name *b = (os_name *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) < 0);
}

Datum
os_name_le(PG_FUNCTION_ARGS)
{
    os_name *a = (os_name *) PG_GETARG_POINTER(0);
    os_name *b = (os_name *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) <= 0);
}

Datum
os_name_eq(PG_FUNCTION_ARGS)
{
    os_name *a = (os_name *) PG_GETARG_POINTER(0);
    os_name *b = (os_name *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) == 0);
}

Datum
os_name_ge(PG_FUNCTION_ARGS)
{
    os_name *a = (os_name *) PG_GETARG_POINTER(0);
    os_name *b = (os_name *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) >= 0);
}

Datum
os_name_gt(PG_FUNCTION_ARGS)
{
    os_name *a = (os_name *) PG_GETARG_POINTER(0);
    os_name *b = (os_name *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(os_name_cmp_internal(a,b) > 0);
}

Datum
os_name_cmp(PG_FUNCTION_ARGS)
{
    os_name *a = (os_name *) PG_GETARG_POINTER(0);
    os_name *b = (os_name *) PG_GETARG_POINTER(1);
    PG_RETURN_INT32(os_name_cmp_internal(a,b));
}

static int
os_name_cmp_internal(os_name * a, os_name * b)
{
    if (*a < *b)
        return -1;
    if (*a > *b)
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
        default: return create_string(CONST_STRING("unknown"));
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
        default: return (CONST_STRING_LENGTH("unknown"));
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
        default : return 0;
    }
}
