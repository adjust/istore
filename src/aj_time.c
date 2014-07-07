#include "aj_time.h"

Datum
aj_time_in(PG_FUNCTION_ARGS)
{
    char    *time_str = PG_GETARG_CSTRING(0),
            *ptr;
    int16   year,
            month,
            day,
            hour,
            min,
            sec,
            leaps,
            i;
    aj_time *result;
    if ((time_str == NULL || AJ_INVALID_TIME(time_str)) && !AJ_SHORT_TIME(time_str))
        elog(ERROR, "could not parse time string: %s", time_str);

    result = palloc(sizeof *result);

    year = strtol(time_str, &ptr, 10);
    if (AJ_INVALID_YEAR(year))
        elog(ERROR, "year out of range: %d", year);

    month = strtol(++ptr, &ptr, 10) - 1;
    if (AJ_INVALID_MONTH(month))
        elog(ERROR, "month out of range: %d", month + 1);

    day = strtol(++ptr, &ptr, 10);
    if (AJ_INVALID_DAY(day, month, year))
        elog(ERROR, "day out of range: %d", day);

    if(AJ_SHORT_TIME(time_str))
    {
        hour = min = sec = 0;
    }
    else
    {
        hour = strtol(++ptr, &ptr, 10);
        if (AJ_INVALID_HOUR(hour))
            elog(ERROR, "hour out of range: %d", hour);

        min = strtol(++ptr, &ptr, 10);
        if (AJ_INVALID_MIN(min))
            elog(ERROR, "min out of range: %d", min);

        sec = strtol(++ptr, &ptr, 10);
        if (AJ_INVALID_SEC(sec))
            elog(ERROR, "sec out of range: %d", sec);
    }
    leaps = AJ_LEAP_FROM_YEAR(year);
    if( ((AJ_IS_LEAP_YEAR(year)) && month <= 1 ) )
        --leaps;

    for (i = 0; i < month; ++i)
        day += mon_len[i];
    *result = AJ_DATE2TIME(day + AJ_YEAR2DATE(year) + leaps - 1)
            + AJ_HOUR2TIME(hour)
            + AJ_MIN2TIME(min)
            + AJ_SEC2TIME(sec);

    PG_RETURN_POINTER(result);
}

Datum
aj_time_out(PG_FUNCTION_ARGS)
{
    aj_time *arg = (aj_time *) PG_GETARG_POINTER(0);
    aj_time time = *arg;
    int16 year  = 0,
          month = 0,
          day   = 0,
          hour  = 0,
          min   = 0,
          i     = 0;
    char  *result;

    result = palloc0(AJ_MAX_TIME_LEN);

    for(;;)
    {
        int year_len = 365;
        if (AJ_IS_LEAP_YEAR(year))
            year_len = 366;
        if ( AJ_DATE2TIME(year_len) <= time ) {
            time -= AJ_DATE2TIME(year_len);
            ++year;
        }
        else
            break;
    }

    if (AJ_IS_LEAP_YEAR(year))
    {
        while (time >= AJ_DATE2TIME(mon_len_leap[i]))
        {
            time -= AJ_DATE2TIME(mon_len_leap[i++]);
            ++month;
        }
    }
    else
    {
        while (time >= AJ_DATE2TIME(mon_len[i]))
        {
            time -= AJ_DATE2TIME(mon_len[i++]);
            ++month;
        }
    }

    AJ_SET_DAY_AND_TIME(day, time);
    AJ_SET_HOUR_AND_TIME(hour, time);
    AJ_SET_MIN_AND_TIME(min, time);
    AJ_SET_TIMESTRING(result, year, month, day, hour, min, time);
    PG_RETURN_POINTER(result);
}

Datum
aj_time_lt(PG_FUNCTION_ARGS)
{
    aj_time *a = (aj_time *) PG_GETARG_POINTER(0);
    aj_time *b = (aj_time *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_time_cmp_internal(a,b) < 0);
}

Datum
aj_time_le(PG_FUNCTION_ARGS)
{
    aj_time *a = (aj_time *) PG_GETARG_POINTER(0);
    aj_time *b = (aj_time *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_time_cmp_internal(a,b) <= 0);
}

Datum
aj_time_eq(PG_FUNCTION_ARGS)
{
    aj_time *a = (aj_time *) PG_GETARG_POINTER(0);
    aj_time *b = (aj_time *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_time_cmp_internal(a,b) == 0);
}

Datum
aj_time_ge(PG_FUNCTION_ARGS)
{
    aj_time *a = (aj_time *) PG_GETARG_POINTER(0);
    aj_time *b = (aj_time *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_time_cmp_internal(a,b) >= 0);
}

Datum
aj_time_gt(PG_FUNCTION_ARGS)
{
    aj_time *a = (aj_time *) PG_GETARG_POINTER(0);
    aj_time *b = (aj_time *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_time_cmp_internal(a,b) > 0);
}

Datum
aj_time_cmp(PG_FUNCTION_ARGS)
{
    aj_time *a = (aj_time *) PG_GETARG_POINTER(0);
    aj_time *b = (aj_time *) PG_GETARG_POINTER(1);
    PG_RETURN_INT32(aj_time_cmp_internal(a,b));
}

static int16
aj_time_cmp_internal(aj_time * a, aj_time * b)
{
    if (*a < *b)
        return -1;
    if (*a > *b)
        return 1;
    return 0;
}

Datum
timestamp_to_aj_time(PG_FUNCTION_ARGS)
{
    Timestamp timestamp = PG_GETARG_TIMESTAMP(0);
    aj_time *result = palloc(sizeof *result);
    *result = POSTGRES_TO_AJ_TIME(timestamp);
    PG_RETURN_POINTER(result);
}

Datum
aj_time_to_timestamp(PG_FUNCTION_ARGS)
{
    aj_time *arg = (aj_time *) PG_GETARG_POINTER(0);
    Timestamp result = AJ_TIME_TO_POSTGRES(*arg);
    PG_RETURN_TIMESTAMP(result);
}

Datum
aj_time_to_date(PG_FUNCTION_ARGS)
{
    aj_time *arg = (aj_time *) PG_GETARG_POINTER(0);
    DateADT result = AJ_TIME_TO_POSTGRES_DATE(*arg);
    PG_RETURN_DATEADT(result);
}

Datum
aj_time_date_part(PG_FUNCTION_ARGS)
{
    char    *part = PG_GETARG_CSTRING(0);
    aj_time *date = (aj_time *) PG_GETARG_POINTER(1);
    int result = 0;

    switch (part[0])
    {
        case 'h':
            result = AJ_TIME_EXTRACT_HOUR(date);
            break;
        default:
            elog(ERROR, "unknown time part to extract");
    }
    PG_RETURN_INT32(result);
}
