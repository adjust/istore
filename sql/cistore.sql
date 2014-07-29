-- require country
-- require device_type
-- require os_name
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

CREATE FUNCTION cistore(country, device_type, os_name, bigint)
    RETURNS cistore
    AS '$libdir/istore.so', 'cistore_from_types'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION cistore(country, device_type, os_name, smallint, bigint)
    RETURNS cistore
    AS '$libdir/istore.so', 'cistore_cohort_from_types'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(cistore, cistore)
    RETURNS cistore
    AS '$libdir/istore.so', 'is_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR + (
    leftarg   = cistore,
    rightarg  = cistore,
    procedure = add
);
