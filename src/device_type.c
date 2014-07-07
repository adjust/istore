#include "device_type.h"

/*
bot => 1
console => 2
ipod => 3
mac => 4
pc => 5
phone => 6
resolver => 7
server => 8
simulator => 9
tablet => 10
unknown => 0
*/

Datum
device_type_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    device_type *result = palloc0(sizeof *result);
    if ( str == NULL )
    {
        PG_RETURN_POINTER(result);
    }
    LOWER_STRING(str);
    *result = get_device_type_num(str);
    PG_RETURN_POINTER(result);
}

Datum
device_type_out(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    PG_RETURN_POINTER(get_device_type_string(a));
}

Datum
device_type_lt(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) < 0);
}

Datum
device_type_le(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) <= 0);
}

Datum
device_type_eq(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) == 0);
}

Datum
device_type_ge(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) >= 0);
}

Datum
device_type_gt(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) > 0);
}

Datum
device_type_cmp(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_INT32(device_type_cmp_internal(a,b));
}

static int
device_type_cmp_internal(device_type * a, device_type * b)
{
    if (*a < *b)
        return -1;
    if (*a > *b)
        return 1;
    return 0;
}

char *
get_device_type_string(uint8 *num)
{
    switch (*num)
    {
        case 1:  return create_string(CONST_STRING("bot"));
        case 2:  return create_string(CONST_STRING("console"));
        case 3:  return create_string(CONST_STRING("ipod"));
        case 4:  return create_string(CONST_STRING("mac"));
        case 5:  return create_string(CONST_STRING("pc"));
        case 6:  return create_string(CONST_STRING("phone"));
        case 7:  return create_string(CONST_STRING("resolver"));
        case 8:  return create_string(CONST_STRING("server"));
        case 9:  return create_string(CONST_STRING("simulator"));
        case 10: return create_string(CONST_STRING("tablet"));
        default: return create_string(CONST_STRING("unknown"));
    }
}

static uint8
check_device_type_num(const char *str, device_type type)
{
    char * expected = get_device_type_string(&type);
    if (strcmp(expected, str) != 0)
    {
        pfree(expected);
        return 0;
    }
    pfree(expected);
    return type;
}

uint8
get_device_type_num(char *str)
{
    switch (str[0])
    {
        case 'b': return check_device_type_num(str, 1);
        case 'c': return check_device_type_num(str, 2);
        case 'i': return check_device_type_num(str, 3);
        case 'm': return check_device_type_num(str, 4);
        case 'p': return get_device_type_num_p(str);
        case 'r': return check_device_type_num(str, 7);
        case 's': return get_device_type_num_s(str);
        case 't': return check_device_type_num(str, 10);
        default : return 0;
    }
}

uint8
get_device_type_num_p(char *str)
{
    switch (str[1]) {
        case 'c': return check_device_type_num(str, 5);
        case 'h': return check_device_type_num(str, 6);
        default : return 0;
    }
}

uint8
get_device_type_num_s(char *str)
{
    switch (str[1]) {
        case 'e': return check_device_type_num(str, 8);
        case 'i': return check_device_type_num(str, 9);
        default : return 0;
    }
}
