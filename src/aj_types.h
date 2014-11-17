#ifndef AJ_TYPES_H
#define AJ_TYPES_H

#include "postgres.h"
#include "fmgr.h"
#include "ctype.h"
#include "libpq/pqformat.h"
#include "access/hash.h"

#define CONST_STRING(s) (sizeof(s)/sizeof(s[0])), s
#define CONST_STRING_LENGTH(s) (sizeof(s)/sizeof(s[0]) - 1)

#define PG_RETURN_UINT8(x) return UInt8GetDatum(x)
#define PG_GETARG_UINT8(x) DatumGetUInt8(PG_GETARG_DATUM(x))

#define PG_RETURN_COUNTRY(x) PG_RETURN_UINT8(x)
#define PG_GETARG_COUNTRY(x) PG_GETARG_UINT8(x)

#define PG_RETURN_DEVICE_TYPE(x) PG_RETURN_UINT8(x)
#define PG_GETARG_DEVICE_TYPE(x) PG_GETARG_UINT8(x)

#define PG_RETURN_OS_NAME(x) PG_RETURN_UINT8(x)
#define PG_GETARG_OS_NAME(x) PG_GETARG_UINT8(x)


#define LOWER_STRING(s)       \
    do {                      \
    char *ptr = s;            \
    for ( ; *ptr; ++ptr)      \
        *ptr = tolower(*ptr); \
    } while(0);

char * create_string (size_t size, const char *const_string);

#endif // AJ_TYPES_H
