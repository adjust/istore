#ifndef INTUTILS_H
#define INTUTILS_H

#include <limits.h>

static inline int
digits32(int32 num){
    int sign = 0;
    if (num < 0)
    {
        if (num == INT_MIN)
            // special case for -2^31 because 2^31 can't fit in a two's complement 32-bit integer
            return 12;
        sign = 1;
        num = -num;
    }

    if (num < 1e5)
    {
        if (num < 1e3)
        {
            if (num < 10)
                return 1 + sign;
            else if (num < 1e2)
                return 2 + sign;
            else
                return 3 + sign;
        }
        else
        {
            if (num < 1e4)
                return 4 + sign;
            else
                return 5 + sign;
        }
    }
    else
    {
        if (num < 1e7)
        {
            if (num < 1e6)
                return 6 + sign;
            else
                return 7 + sign;
        }
        else
        {
            if (num < 1e8)
                return 8 + sign;
            else if (num < 1e9)
                return 9 + sign;
            else
                return 10 + sign;
        }
    }
}

static inline int
digits64(int64 num){
    int sign = 0;
    if (num < 0)
    {
        if (num == LLONG_MIN)
            // special case for -2^63 because 2^63 can't fit in a two's complement 64-bit integer
            return 19;
        sign = 1;
        num = -num;
    }

    if (num < 1e10)
    {
        if (num < 1e5)
        {
            if (num < 1e3)
            {
                if (num < 10)
                    return 1 + sign;
                else if (num < 1e2)
                    return 2 + sign;
                else
                    return 3 + sign;
            }
            else
            {
                if (num < 1e4)
                    return 4 + sign;
                else
                    return 5 + sign;
            }
        }
        else
        {
            if (num < 1e7)
            {
                if (num < 1e6)
                    return 6 + sign;
                else
                    return 7 + sign;
            }
            else
            {
                if (num < 1e8)
                    return 8 + sign;
                else if (num < 1e9)
                    return 9 + sign;
                else
                    return 10 + sign;
            }
        }
    }
    else
    {
        if (num < 1e15)
        {
            if (num < 1e12)
            {
                if (num < 1e11)
                    return 11 + sign;
                else
                    return 12 + sign;
            }
            else
            {
                if (num < 1e13)
                    return 13 + sign;
                else if (num < 1e14)
                    return 14 + sign;
                else
                    return 15 + sign;
            }
        }
        else
        {
            if (num < 1e17)
            {
                if (num < 1e16)
                    return 16 + sign;
                else
                    return 17 + sign;
            }
            else
            {
                if (num < 1e18)
                    return 18 + sign;
                else
                    return 19 + sign;
            }
        }
    }
}

static inline int
is_ltoa(int32 value, char *a)
{
  char     *start = a;
  bool    neg = false;
  int   n = 0;

  /*
   * Avoid problems with the most negative integer not being representable
   * as a positive integer.
   */
  if (value == (-2147483647 - 1))
  {
    memcpy(a, "-2147483648", 12);
    return 11;
  }
  else if (value < 0)
  {
    value = -value;
    neg = true;
    ++n;
  }

  /* Compute the result string backwards. */
  do
  {
    int   remainder;
    int   oldval = value;

    value /= 10;
    remainder = oldval - value * 10;
    *a++ = '0' + remainder;
    ++n;
  } while (value != 0);

  if (neg)
      *a++ = '-';

  /* Add trailing NUL byte, and back up 'a' to the last character. */
  *a-- = '\0';

  /* Reverse string. */
  while (start < a)
  {
    char    swap = *start;

    *start++ = *a;
    *a-- = swap;
  }
  return n;
}

static inline int
is_lltoa(int64 value, char *a)
{
    char       *start = a;
    bool        neg = false;
    int         n = 0;

    /*
     * Avoid problems with the most negative integer not being representable
     * as a positive integer.
     */
    if (value == -INT64CONST(0x7FFFFFFFFFFFFFFF) - 1)
    {
        memcpy(a, "-9223372036854775808", 21);
        return 20;
    }
    else if (value < 0)
    {
        value = -value;
        neg = true;
        ++n;
    }

    /* Compute the result string backwards. */
    do
    {
        int64       remainder;
        int64       oldval = value;

        value /= 10;
        remainder = oldval - value * 10;
        *a++ = '0' + remainder;
        ++n;
    } while (value != 0);

    if (neg)
        *a++ = '-';

    /* Add trailing NUL byte, and back up 'a' to the last character. */
    *a-- = '\0';

    /* Reverse string. */
    while (start < a)
    {
        char        swap = *start;

        *start++ = *a;
        *a-- = swap;
    }

    return n;
}


#endif // INTUTILS_H