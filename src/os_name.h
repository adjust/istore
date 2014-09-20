#ifndef AJ_TYPES_OS_NAME_H
#define AJ_TYPES_OS_NAME_H

#include "aj_types.h"

/*
android => 1
ios => 2
windows => 3
windows-phone => 4
unknown => 0
*/

typedef uint8 os_name;

Datum os_name_in(PG_FUNCTION_ARGS);
Datum os_name_out(PG_FUNCTION_ARGS);
Datum os_name_lt(PG_FUNCTION_ARGS);
Datum os_name_le(PG_FUNCTION_ARGS);
Datum os_name_eq(PG_FUNCTION_ARGS);
Datum os_name_ge(PG_FUNCTION_ARGS);
Datum os_name_gt(PG_FUNCTION_ARGS);
Datum os_name_cmp(PG_FUNCTION_ARGS);
Datum os_name_neq(PG_FUNCTION_ARGS);
Datum os_name_send(PG_FUNCTION_ARGS);
Datum os_name_recv(PG_FUNCTION_ARGS);

uint8 get_os_name_num(char *str);
uint8 get_os_name_num_b(char *str);
uint8 get_os_name_num_s(char *str);
uint8 get_os_name_num_w(char *str);


char * get_os_name_string (uint8 num);
int get_os_name_length (uint8 num);

#endif // AJ_TYPES_OS_NAME_TYPE_H
