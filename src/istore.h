#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"

/* TODO remove either that or the following macro */
size_t get_digit_num(long number);

#define DIGIT_WIDTH(_digit, _width) \
    do {                            \
        long _local = _digit;       \
        _width = 0;                 \
        if (_local <= 0)            \
            ++_width;               \
        while (_local != 0)         \
        {                           \
            _local /= 10;           \
            ++_width;               \
        }                           \
    } while (0)

#endif // ISTORE_H
