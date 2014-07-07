CREATE TYPE istore;

CREATE FUNCTION istore_in(cstring)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_out(istore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE istore (
    INPUT = istore_in,
    OUTPUT = istore_out
);

CREATE FUNCTION exist(istore, integer)
    RETURNS boolean
    AS '$libdir/istore.so', 'is_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(istore, integer)
    RETURNS bigint
    AS '$libdir/istore.so', 'is_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'is_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'is_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'is_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'is_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'is_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'is_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_from_array(integer[])
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_agg(istore[])
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_agg_finalfn(internal)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_sum_up(istore)
    RETURNS bigint
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_array_add(integer[], integer[])
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn
);

