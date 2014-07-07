#include "aj_date.h"

Datum
aj_date_in(PG_FUNCTION_ARGS)
{
    char    *date_str = PG_GETARG_CSTRING(0),
            *ptr;
    int16   year,
            month,
            day,
            i,
            leaps;
    aj_date *result;

    if (date_str == NULL || AJ_INVALID_DATE(date_str))
        elog(ERROR, "could not parse date string: %s", date_str);

    result = palloc(sizeof *result);

    year = strtol(date_str, &ptr, 10);
    if (AJ_INVALID_YEAR(year))
        elog(ERROR, "year out of range: %d", year);

    month = strtol(++ptr, &ptr, 10) - 1;
    if (AJ_INVALID_MONTH(month))
        elog(ERROR, "month out of range: %d", month + 1);

    day = strtol(++ptr, &ptr, 10);
    if (AJ_INVALID_DAY(day, month, year))
        elog(ERROR, "day out of range: %d", day);

    leaps = AJ_LEAP_FROM_YEAR(year);
    if ( ((AJ_IS_LEAP_YEAR(year)) && month <= 1 ) )
        --leaps;

    for (i = 0; i < month; ++i)
        day += mon_len[i];

    *result = day + AJ_YEAR2DATE(year) + leaps - 1;
    PG_RETURN_POINTER(result);
}

Datum
aj_date_out(PG_FUNCTION_ARGS)
{
    aj_date *arg = (aj_date *) PG_GETARG_POINTER(0);
    aj_date date = *arg;
    int16   year    = 0,
            month   = 0,
            i       = 0;
    char    *result;

    result = palloc0(AJ_MAX_DATE_LEN);

    for(;;)
    {
        int16 year_len = 365;
        if (AJ_IS_LEAP_YEAR(year))
            year_len = 366;
        if ( year_len <= date ) {
            date -= year_len;
            ++year;
        }
        else
            break;
    }

    if (AJ_IS_LEAP_YEAR(year))
    {
        while (date >= mon_len_leap[i])
        {
            date -= mon_len_leap[i++];
            ++month;
        }
    }
    else
    {
        while(date >= mon_len[i])
        {
            date -= mon_len[i++];
            ++month;
        }
    }
    AJ_SET_DATESTRING(result, year, month, date);
    PG_RETURN_POINTER(result);
}

Datum
aj_date_lt(PG_FUNCTION_ARGS)
{
    aj_date *a = (aj_date *) PG_GETARG_POINTER(0);
    aj_date *b = (aj_date *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_date_cmp_internal(a,b) < 0);
}

Datum
aj_date_le(PG_FUNCTION_ARGS)
{
    aj_date *a = (aj_date *) PG_GETARG_POINTER(0);
    aj_date *b = (aj_date *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_date_cmp_internal(a,b) <= 0);
}

Datum
aj_date_eq(PG_FUNCTION_ARGS)
{
    aj_date *a = (aj_date *) PG_GETARG_POINTER(0);
    aj_date *b = (aj_date *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_date_cmp_internal(a,b) == 0);
}

Datum
aj_date_ge(PG_FUNCTION_ARGS)
{
    aj_date *a = (aj_date *) PG_GETARG_POINTER(0);
    aj_date *b = (aj_date *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_date_cmp_internal(a,b) >= 0);
}

Datum
aj_date_gt(PG_FUNCTION_ARGS)
{
    aj_date *a = (aj_date *) PG_GETARG_POINTER(0);
    aj_date *b = (aj_date *) PG_GETARG_POINTER(1);
    PG_RETURN_BOOL(aj_date_cmp_internal(a,b) > 0);
}

Datum
aj_date_cmp(PG_FUNCTION_ARGS)
{
    aj_date *a = (aj_date *) PG_GETARG_POINTER(0);
    aj_date *b = (aj_date *) PG_GETARG_POINTER(1);
    PG_RETURN_INT32(aj_date_cmp_internal(a,b));
}

static int16
aj_date_cmp_internal(aj_date * a, aj_date * b)
{
    if (*a < *b)
        return -1;
    if (*a > *b)
        return 1;
    return 0;
}

Datum
aj_date_to_date(PG_FUNCTION_ARGS)
{
    aj_date *arg = (aj_date *) PG_GETARG_POINTER(0);
    DateADT date = AJ_DATE_TO_POSTGRES((DateADT)(*arg));
    PG_RETURN_DATEADT(date);
}

Datum
date_to_aj_date(PG_FUNCTION_ARGS)
{
    DateADT arg  = PG_GETARG_DATEADT(0);
    aj_date *date = palloc(sizeof *date);
    *date = POSTGRES_TO_AJ_DATE((aj_date)(arg));
    PG_RETURN_POINTER(date);
}

Datum
aj_date_add(PG_FUNCTION_ARGS)
{
    aj_date *date,
            *result;
    int      diff;

    date   = (aj_date *) PG_GETARG_POINTER(0);
    diff = PG_GETARG_INT32(1);

    if ((int)(*date + diff) > MAX_AJ_DATE || (int)(*date + diff) < MIN_AJ_DATE)
        elog(ERROR, "resulting date is out of aj_date range");
    result = palloc(sizeof *result);
    *result = (aj_date)(*date + diff);
    PG_RETURN_POINTER(result);
}

Datum
aj_date_subtract(PG_FUNCTION_ARGS)
{
    aj_date *date,
            *result;
    int      diff;

    date   = (aj_date *) PG_GETARG_POINTER(0);
    diff = PG_GETARG_INT32(1);

    if ((int)(*date - diff) > MAX_AJ_DATE || (int)(*date - diff) < MIN_AJ_DATE)
        elog(ERROR, "resulting date is out of aj_date range");
    result = palloc(sizeof *result);
    *result = (aj_date)(*date - diff);
    PG_RETURN_POINTER(result);
}

Datum
aj_date_diff(PG_FUNCTION_ARGS)
{
    aj_date *date1,
            *date2;

    date1 = (aj_date *) PG_GETARG_POINTER(0);
    date2 = (aj_date *) PG_GETARG_POINTER(1);

    PG_RETURN_INT32((int)(*date1 - *date2));
}
