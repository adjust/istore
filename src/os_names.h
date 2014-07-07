#ifndef AJ_TYPES_DEVICE_TYPE_H
#define AJ_TYPES_DEVICE_TYPE_H

#include "aj_types.h"

/*
android => 1
ios => 2
windows => 3
windows-phone => 4
unknown => 0
*/

typedef uint8 os_name;

PG_FUNCTION_INFO_V1(os_name_in);
PG_FUNCTION_INFO_V1(os_name_out);
PG_FUNCTION_INFO_V1(os_name_lt);
PG_FUNCTION_INFO_V1(os_name_le);
PG_FUNCTION_INFO_V1(os_name_eq);
PG_FUNCTION_INFO_V1(os_name_ge);
PG_FUNCTION_INFO_V1(os_name_gt);
PG_FUNCTION_INFO_V1(os_name_cmp);

Datum os_name_in(PG_FUNCTION_ARGS);
Datum os_name_out(PG_FUNCTION_ARGS);
Datum os_name_lt(PG_FUNCTION_ARGS);
Datum os_name_le(PG_FUNCTION_ARGS);
Datum os_name_eq(PG_FUNCTION_ARGS);
Datum os_name_ge(PG_FUNCTION_ARGS);
Datum os_name_gt(PG_FUNCTION_ARGS);
Datum os_name_cmp(PG_FUNCTION_ARGS);

uint8 get_os_name_num(char *str);

char * get_os_name_string (uint8 *num);
static uint8 check_os_name_num(const char *str, os_name type);

static int os_name_cmp_internal(os_name *a, os_name *b);

#endif // AJ_TYPES_OS_NAME_TYPE_H
