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
static int device_type_cmp_internal(device_type a, device_type b);

PG_FUNCTION_INFO_V1(device_type_in);
Datum
device_type_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);
    device_type result;

    if (str == NULL)
        elog(ERROR, "NULL input for device_type not defined");
    LOWER_STRING(str);
    result = get_device_type_num(str);
    if (result == 0)
        elog(ERROR, "unknown input device_type: %s", str);
    PG_RETURN_DEVICE_TYPE(result);
}

PG_FUNCTION_INFO_V1(device_type_out);
Datum
device_type_out(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    PG_RETURN_POINTER(get_device_type_string(a));
}

PG_FUNCTION_INFO_V1(device_type_recv);
Datum
device_type_recv(PG_FUNCTION_ARGS)
{
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    device_type result = pq_getmsgbyte(buf);
    PG_RETURN_DEVICE_TYPE(result);
}

PG_FUNCTION_INFO_V1(device_type_send);
Datum
device_type_send(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    StringInfoData buf;

    pq_begintypsend(&buf);
    pq_sendbyte(&buf, a);
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}


PG_FUNCTION_INFO_V1(device_type_lt);
Datum
device_type_lt(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    device_type b = PG_GETARG_DEVICE_TYPE(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) < 0);
}

PG_FUNCTION_INFO_V1(device_type_le);
Datum
device_type_le(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    device_type b = PG_GETARG_DEVICE_TYPE(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) <= 0);
}

PG_FUNCTION_INFO_V1(device_type_eq);
Datum
device_type_eq(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    device_type b = PG_GETARG_DEVICE_TYPE(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) == 0);
}

PG_FUNCTION_INFO_V1(device_type_neq);
Datum
device_type_neq(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    device_type b = PG_GETARG_DEVICE_TYPE(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) != 0);
}

PG_FUNCTION_INFO_V1(device_type_ge);
Datum
device_type_ge(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    device_type b = PG_GETARG_DEVICE_TYPE(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) >= 0);
}

PG_FUNCTION_INFO_V1(device_type_gt);
Datum
device_type_gt(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    device_type b = PG_GETARG_DEVICE_TYPE(1);
    PG_RETURN_BOOL(device_type_cmp_internal(a,b) > 0);
}

PG_FUNCTION_INFO_V1(device_type_cmp);
Datum
device_type_cmp(PG_FUNCTION_ARGS)
{
    device_type a = PG_GETARG_DEVICE_TYPE(0);
    device_type b = PG_GETARG_DEVICE_TYPE(1);
    PG_RETURN_INT32(device_type_cmp_internal(a,b));
}

static int
device_type_cmp_internal(device_type a, device_type b)
{
    if (a < b)
        return -1;
    if (a > b)
        return 1;
    return 0;
}

char *
get_device_type_string(uint8 num)
{
    switch (num)
    {
        case  20:  return create_string(CONST_STRING("bot"));
        case  40:  return create_string(CONST_STRING("console"));
        case  80:  return create_string(CONST_STRING("ipod"));
        case 100:  return create_string(CONST_STRING("mac"));
        case 120:  return create_string(CONST_STRING("pc"));
        case 140:  return create_string(CONST_STRING("phone"));
        case 160:  return create_string(CONST_STRING("server"));
        case 180:  return create_string(CONST_STRING("simulator"));
        case 200: return create_string(CONST_STRING("tablet"));
        case 220: return create_string(CONST_STRING("tv"));
        case 255: return create_string(CONST_STRING("unknown"));
        default: elog(ERROR, "unknown device_type num");
    }
}

int
get_device_type_length(uint8 num)
{
    switch (num)
    {
        case  20:  return (CONST_STRING_LENGTH("bot"));
        case  40:  return (CONST_STRING_LENGTH("console"));
        case  80:  return (CONST_STRING_LENGTH("ipod"));
        case 100:  return (CONST_STRING_LENGTH("mac"));
        case 120:  return (CONST_STRING_LENGTH("pc"));
        case 140:  return (CONST_STRING_LENGTH("phone"));
        case 160:  return (CONST_STRING_LENGTH("server"));
        case 180:  return (CONST_STRING_LENGTH("simulator"));
        case 200: return (CONST_STRING_LENGTH("tablet"));
        case 220: return (CONST_STRING_LENGTH("tv"));
        case 255: return (CONST_STRING_LENGTH("unknown"));
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
        case 'b': return check_device_type_num(str, 20);
        case 'c': return check_device_type_num(str, 40);
        case 'i': return check_device_type_num(str, 80);
        case 'm': return check_device_type_num(str, 100);
        case 'p': return get_device_type_num_p(str);
        case 's': return get_device_type_num_s(str);
        case 't': return get_device_type_num_t(str);
        case 'u': return check_device_type_num(str, 255);
        default : return 0;
    }
}

uint8
get_device_type_num_p(char *str)
{
    switch (str[1]) {
        case 'c': return check_device_type_num(str, 120);
        case 'h': return check_device_type_num(str, 140);
        default : return 0;
    }
}

uint8
get_device_type_num_s(char *str)
{
    switch (str[1]) {
        case 'e': return check_device_type_num(str, 160);
        case 'i': return check_device_type_num(str, 180);
        default : return 0;
    }
}

uint8
get_device_type_num_t(char *str)
{
    switch (str[1]) {
        case 'a': return check_device_type_num(str, 200);
        case 'v': return check_device_type_num(str, 220);
        default : return 0;
    }
}

PG_FUNCTION_INFO_V1(hashdevice_type);
Datum
hashdevice_type(PG_FUNCTION_ARGS)
{
    return hash_uint32((int32) PG_GETARG_CHAR(0));
}
