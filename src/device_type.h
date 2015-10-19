#ifndef AJ_TYPES_DEVICE_TYPE_H
#define AJ_TYPES_DEVICE_TYPE_H

#include "aj_types.h"

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

typedef uint8 device_type;

Datum device_type_in(PG_FUNCTION_ARGS);
Datum device_type_out(PG_FUNCTION_ARGS);
Datum device_type_lt(PG_FUNCTION_ARGS);
Datum device_type_le(PG_FUNCTION_ARGS);
Datum device_type_eq(PG_FUNCTION_ARGS);
Datum device_type_ge(PG_FUNCTION_ARGS);
Datum device_type_gt(PG_FUNCTION_ARGS);
Datum device_type_cmp(PG_FUNCTION_ARGS);
Datum device_type_neq(PG_FUNCTION_ARGS);
Datum device_type_send(PG_FUNCTION_ARGS);
Datum device_type_recv(PG_FUNCTION_ARGS);
Datum hashdevice_type(PG_FUNCTION_ARGS);

uint8 get_device_type_num(char *str);
uint8 get_device_type_num_p(char *str);
uint8 get_device_type_num_s(char *str);
uint8 get_device_type_num_t(char *str);

char * get_device_type_string(uint8 num);
int get_device_type_length(uint8 num);

#endif // AJ_TYPES_DEVICE_TYPE_H
