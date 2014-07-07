#ifndef AJ_TYPES_DATE_H
#define AJ_TYPES_DATE_H

#include "aj_types.h"
#include "time.h"

typedef uint16 aj_date;

#define MIN_AJ_DATE 0
#define MAX_AJ_DATE 65535

PG_FUNCTION_INFO_V1(aj_date_in);
PG_FUNCTION_INFO_V1(aj_date_out);
PG_FUNCTION_INFO_V1(aj_date_lt);
PG_FUNCTION_INFO_V1(aj_date_le);
PG_FUNCTION_INFO_V1(aj_date_eq);
PG_FUNCTION_INFO_V1(aj_date_ge);
PG_FUNCTION_INFO_V1(aj_date_gt);
PG_FUNCTION_INFO_V1(aj_date_cmp);

PG_FUNCTION_INFO_V1(aj_date_to_date);
PG_FUNCTION_INFO_V1(date_to_aj_date);
PG_FUNCTION_INFO_V1(aj_date_add);
PG_FUNCTION_INFO_V1(aj_date_subtract);
PG_FUNCTION_INFO_V1(aj_date_diff);

Datum aj_date_in(PG_FUNCTION_ARGS);
Datum aj_date_out(PG_FUNCTION_ARGS);
Datum aj_date_lt(PG_FUNCTION_ARGS);
Datum aj_date_le(PG_FUNCTION_ARGS);
Datum aj_date_eq(PG_FUNCTION_ARGS);
Datum aj_date_ge(PG_FUNCTION_ARGS);
Datum aj_date_gt(PG_FUNCTION_ARGS);
Datum aj_date_cmp(PG_FUNCTION_ARGS);

Datum aj_date_to_date(PG_FUNCTION_ARGS);
Datum date_to_aj_date(PG_FUNCTION_ARGS);

Datum aj_date_add(PG_FUNCTION_ARGS);
Datum aj_date_subtract(PG_FUNCTION_ARGS);
Datum aj_date_diff(PG_FUNCTION_ARGS);

inline static int16 aj_date_cmp_internal(aj_date *a, aj_date *b);

#endif // AJ_TYPES_DEVICE_TYPE_H
