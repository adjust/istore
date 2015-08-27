#ifndef INTUTILS_H
#define INTUTILS_H

#include "istore.h"
#include <limits.h>

#define SAMESIGN(a,b) (((a) < 0) == ((b) < 0))

static inline int32
int32add(int32 arg1, int32 arg2)
{
  int32   result;

  result = arg1 + arg2;

  /*
   * Overflow check.  If the inputs are of different signs then their sum
   * cannot overflow.  If the inputs are of the same sign, their sum had
   * better be that sign too.
   */
  if (SAMESIGN(arg1, arg2) && !SAMESIGN(result, arg1))
    ereport(ERROR,
        (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
         errmsg("integer out of range")));

  return result;
}

static inline int32
int32sub(int32 arg1, int32 arg2)
{
  int32   result;

  result = arg1 - arg2;

  /*
   * Overflow check.  If the inputs are of the same sign then their
   * difference cannot overflow.  If they are of different signs then the
   * result should be of the same sign as the first input.
   */
  if (!SAMESIGN(arg1, arg2) && !SAMESIGN(result, arg1))
    ereport(ERROR,
        (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
         errmsg("integer out of range")));

  return result;
}

static inline int32
int32mul(int32 arg1, int32 arg2)
{
  int32   result;

  result = arg1 * arg2;

  /*
   * Overflow check.  We basically check to see if result / arg2 gives arg1
   * again.  There are two cases where this fails: arg2 = 0 (which cannot
   * overflow) and arg1 = INT_MIN, arg2 = -1 (where the division itself will
   * overflow and thus incorrectly match).
   *
   * Since the division is likely much more expensive than the actual
   * multiplication, we'd like to skip it where possible.  The best bang for
   * the buck seems to be to check whether both inputs are in the int16
   * range; if so, no overflow is possible.
   */
  if (!(arg1 >= (int32) SHRT_MIN && arg1 <= (int32) SHRT_MAX &&
      arg2 >= (int32) SHRT_MIN && arg2 <= (int32) SHRT_MAX) &&
    arg2 != 0 &&
    ((arg2 == -1 && arg1 < 0 && result < 0) ||
     result / arg2 != arg1))
    ereport(ERROR,
        (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
         errmsg("integer out of range")));

  return result;
}

static inline int32
int32div(int32 arg1, int32 arg2)
{
  int32   result;

  /* allow division by zero if nominator is zero */
  if (arg1 == 0)
    return 0;

  if (arg2 == 0 )
  {
    ereport(ERROR,
        (errcode(ERRCODE_DIVISION_BY_ZERO),
         errmsg("division by zero")));
  }

  /*
   * INT_MIN / -1 is problematic, since the result can't be represented on a
   * two's-complement machine.  Some machines produce INT_MIN, some produce
   * zero, some throw an exception.  We can dodge the problem by recognizing
   * that division by -1 is the same as negation.
   */
  if (arg2 == -1)
  {
    result = -arg1;
    /* overflow check (needed for INT_MIN) */
    if (arg1 != 0 && SAMESIGN(result, arg1))
      ereport(ERROR,
          (errcode(ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE),
           errmsg("integer out of range")));
    PG_RETURN_INT32(result);
  }

  /* No overflow is possible */

  result = arg1 / arg2;

  return result;
}

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

#endif // INTUTILS_H