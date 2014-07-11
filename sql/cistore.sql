CREATE TYPE cistore;

CREATE FUNCTION cistore_in(cstring)
    RETURNS cistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION cistore_out(cistore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE cistore (
    INPUT = cistore_in,
    OUTPUT = cistore_out
);
