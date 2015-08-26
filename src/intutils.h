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
#endif // INTUTILS_H