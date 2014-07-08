#ifndef AJ_TYPES_H
#define AJ_TYPES_H

#include "postgres.h"
#include "fmgr.h"
#include "ctype.h"

#define CONST_STRING(s) (sizeof(s)/sizeof(s[0])), s
#define CONST_STRING_LENGTH(s) (sizeof(s)/sizeof(s[0]) - 1)

#define LOWER_STRING(s)       \
    do {                      \
    char *ptr = s;            \
    for ( ; *ptr; ++ptr)      \
        *ptr = tolower(*ptr); \
    } while(0);

char * create_string (size_t size, const char *const_string);

#endif // AJ_TYPES_H
