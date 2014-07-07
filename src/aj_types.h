#ifndef AJ_TYPES_H
#define AJ_TYPES_H

#include "postgres.h"
#include "fmgr.h"
#include "ctype.h"
#include "utils/date.h"
#include "utils/timestamp.h"

#define CONST_STRING(s) (sizeof(s)/sizeof(s[0])), s

#define CONST_STRING_LENGTH(s) (sizeof(s)/sizeof(s[0]) - 1)

#define LOWER_STRING(s)       \
    do {                      \
    char *ptr = s;            \
    for ( ; *ptr; ++ptr)      \
        *ptr = tolower(*ptr); \
    } while(0);

#define AJ_MAX_DATE_LEN 11
#define AJ_MAX_TIME_LEN 20

#define AJ_SET_DAY_AND_TIME(d, t) \
    d = AJ_TIME2DATE(t); \
    t -= AJ_DATE2TIME(d);

#define AJ_SET_HOUR_AND_TIME(h, t) \
    h = AJ_TIME2HOUR(t); \
    t -= AJ_HOUR2TIME(h);

#define AJ_SET_MIN_AND_TIME(m, t) \
    m = AJ_TIME2MIN(t); \
    t -= AJ_MIN2TIME(m);

#define AJ_LEAP_FROM_YEAR(y) \
    (y - 2008) / 4

#define AJ_SET_DATESTRING(result, y, m, d) \
    snprintf( result, AJ_MAX_DATE_LEN, "%d-%02d-%02d", y + 2012, m + 1, d + 1 );

#define AJ_SET_TIMESTRING(result, y, m, d, h, min, s) \
    snprintf(result, AJ_MAX_TIME_LEN, "%d-%02d-%02d %02d:%02d:%02d", y + 2012, m + 1, d + 1, h, min, s);

#define AJ_YEAR2DATE(y) (((y) - 2012) * 365)
#define AJ_DATE2TIME(d) ((d) * 86400)
#define AJ_TIME2DATE(d) ((d) / 86400)
#define AJ_HOUR2TIME(h) ((h) * 3600)
#define AJ_TIME2HOUR(h) ((h) / 3600)
#define AJ_MIN2TIME(m)  ((m) * 60)
#define AJ_TIME2MIN(m)  ((m) / 60)
#define AJ_SEC2TIME(s)  (s)

#define AJ_MIN_YEAR     2012
#define AJ_MAX_YEAR     2037 // end of unixdate
#define AJ_MIN_MONTH    0
#define AJ_MAX_MONTH    11
#define AJ_MIN_HOUR     0
#define AJ_MAX_HOUR     23
#define AJ_MIN_MIN      0
#define AJ_MAX_MIN      59
#define AJ_MIN_SEC      0
#define AJ_MAX_SEC      59

#define AJ_DATE_TO_POSTGRES(x) (x + 4383)
#define POSTGRES_TO_AJ_DATE(x) (x - 4383)
#define AJ_TIME_TO_POSTGRES(x) (((Timestamp)x + 378691200) * 1000000)
#define POSTGRES_TO_AJ_TIME(x) ((x/1000000) - 378691200)
#define AJ_TIME_TO_POSTGRES_DATE(x) (AJ_DATE_TO_POSTGRES(x/86400))
#define AJ_INVALID_DATE(s) \
        (s[4] != '-' || s[7] != '-' || ! isdigit(s[9]) || s[10] != '\0')

#define AJ_INVALID_TIME(s) \
        (s[4] != '-' || s[7] != '-' || s[10] != ' ' || s[13] != ':' || s[16] != ':' )

#define AJ_SHORT_TIME(s) \
        (s[4] == '-' && s[7] == '-' && s[10] == '\0')

#define AJ_IS_LEAP_YEAR(y) \
        (!(y % 4) && y % 100) || !(y % 400)

#define AJ_INVALID_YEAR(y) \
        (y < AJ_MIN_YEAR || y > AJ_MAX_YEAR)

#define AJ_INVALID_MONTH(m) \
        (m < AJ_MIN_MONTH || m > AJ_MAX_MONTH)

#define AJ_INVALID_DAY(d, m, y) \
        (((AJ_IS_LEAP_YEAR(y)) && (m == 1)  && (d < 1 || d > 29)) \
              || ((AJ_IS_LEAP_YEAR(y)) && (m != 1)  && (d < 1 || d > mon_len[m])) \
              || (!(AJ_IS_LEAP_YEAR(y)) && (d < 1 || d > mon_len[m])))

#define AJ_INVALID_HOUR(m) \
        (m < AJ_MIN_HOUR || m > AJ_MAX_HOUR)

#define AJ_INVALID_MIN(m) \
        (m < AJ_MIN_MIN || m > AJ_MAX_MIN)

#define AJ_INVALID_SEC(m) \
        (m < AJ_MIN_SEC || m > AJ_MAX_SEC)

static const int16 mon_len [] =
    {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

static const int16 mon_len_leap [] =
    {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

char * create_string (size_t size, const char *const_string);

#endif // AJ_TYPES_H
