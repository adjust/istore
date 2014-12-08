#include "aj_types.h"

char *
create_string (size_t size, const char *device_name)
{
    char *str = palloc0(size);
    memcpy(str, device_name, size);
    return str;
}
