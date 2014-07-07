#ifndef AJ_TYPES_TIME_H
#define AJ_TYPES_TIME_H

#include "aj_types.h"
#include "time.h"

typedef uint32 aj_time;

#define AJ_TIME_EXTRACT_HOUR(x) ((*x % 86400)/3600)

PG_FUNCTION_INFO_V1(aj_time_in);
PG_FUNCTION_INFO_V1(aj_time_out);
PG_FUNCTION_INFO_V1(aj_time_lt);
PG_FUNCTION_INFO_V1(aj_time_le);
PG_FUNCTION_INFO_V1(aj_time_eq);
PG_FUNCTION_INFO_V1(aj_time_ge);
PG_FUNCTION_INFO_V1(aj_time_gt);
PG_FUNCTION_INFO_V1(aj_time_cmp);
PG_FUNCTION_INFO_V1(timestamp_to_aj_time);
PG_FUNCTION_INFO_V1(aj_time_to_timestamp);
PG_FUNCTION_INFO_V1(aj_time_to_date);
PG_FUNCTION_INFO_V1(aj_time_date_part);

Datum aj_time_in(PG_FUNCTION_ARGS);
Datum aj_time_out(PG_FUNCTION_ARGS);
Datum aj_time_lt(PG_FUNCTION_ARGS);
Datum aj_time_le(PG_FUNCTION_ARGS);
Datum aj_time_eq(PG_FUNCTION_ARGS);
Datum aj_time_ge(PG_FUNCTION_ARGS);
Datum aj_time_gt(PG_FUNCTION_ARGS);
Datum aj_time_cmp(PG_FUNCTION_ARGS);

Datum timestamp_to_aj_time(PG_FUNCTION_ARGS);
Datum aj_time_to_timestamp(PG_FUNCTION_ARGS);
Datum aj_time_to_date(PG_FUNCTION_ARGS);
Datum aj_time_date_part(PG_FUNCTION_ARGS);

inline static int16 aj_time_cmp_internal(aj_time *a, aj_time *b);

#endif // AJ_TYPES_TIME_H
