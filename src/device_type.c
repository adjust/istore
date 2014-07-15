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

static uint8 check_device_type_num(const char *str, device_type type);
static int device_type_cmp_internal(device_type *a, device_type *b);

PG_FUNCTION_INFO_V1(device_type_in);
Datum
device_type_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    device_type *result = palloc0(sizeof *result);
    if (str == NULL)
        elog(ERROR, "NULL input for device_type not defined");
    LOWER_STRING(str);
    *result = get_device_type_num(str);
    if (*result == 0)
        elog(ERROR, "unknown input device_type");
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(device_type_out);
Datum
device_type_out(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    PG_RETURN_POINTER(get_device_type_string(*a));
}

PG_FUNCTION_INFO_V1(device_type_recv);
Datum
device_type_recv(PG_FUNCTION_ARGS)
{
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    device_type *result = palloc0(sizeof *result);
    *result = pq_getmsgbyte(buf);
    PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(device_type_send);
Datum
device_type_send(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    StringInfoData buf;

    pq_begintypsend(&buf);
    pq_sendbyte(&buf, *a);
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}


PG_FUNCTION_INFO_V1(device_type_lt);
Datum
device_type_lt(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) < 0);
}

PG_FUNCTION_INFO_V1(device_type_le);
Datum
device_type_le(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) <= 0);
}

PG_FUNCTION_INFO_V1(device_type_eq);
Datum
device_type_eq(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) == 0);
}

PG_FUNCTION_INFO_V1(device_type_ge);
Datum
device_type_ge(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) >= 0);
}

PG_FUNCTION_INFO_V1(device_type_gt);
Datum
device_type_gt(PG_FUNCTION_ARGS)
{
    device_type *a = (device_type *) PG_GETARG_POINTER(0);
    device_type *b = (device_type *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) > 0);
}

PG_FUNCTION_INFO_V1(device_type_cmp);
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
get_device_type_string(uint8 num)
{
    switch (num)
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
        case 11: return create_string(CONST_STRING("unknown"));
        default: elog(ERROR, "unknown device_type num");
    }
}

int
get_device_type_length(uint8 num)
{
    switch (num)
    {
        case 1:  return (CONST_STRING_LENGTH("bot"));
        case 2:  return (CONST_STRING_LENGTH("console"));
        case 3:  return (CONST_STRING_LENGTH("ipod"));
        case 4:  return (CONST_STRING_LENGTH("mac"));
        case 5:  return (CONST_STRING_LENGTH("pc"));
        case 6:  return (CONST_STRING_LENGTH("phone"));
        case 7:  return (CONST_STRING_LENGTH("resolver"));
        case 8:  return (CONST_STRING_LENGTH("server"));
        case 9:  return (CONST_STRING_LENGTH("simulator"));
        case 10: return (CONST_STRING_LENGTH("tablet"));
        case 11: return (CONST_STRING_LENGTH("unknown"));
        default: elog(ERROR, "unknown device_type num");
    }
}


static uint8
check_device_type_num(const char *str, device_type type)
{
    char *expected = get_device_type_string(type);
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
        case 'u': return check_device_type_num(str, 11);
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
