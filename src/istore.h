#ifndef ISTORE_H
#define ISTORE_H

#include "postgres.h"
#include "fmgr.h"

PG_FUNCTION_INFO_V1(istore_in);
PG_FUNCTION_INFO_V1(istore_out);

Datum istore_in(PG_FUNCTION_ARGS);
Datum istore_out(PG_FUNCTION_ARGS);

#endif // ISTORE_H
