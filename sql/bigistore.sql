CREATE TYPE bigistore;

CREATE FUNCTION bigistore_in(cstring)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_out(bigistore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_send(bigistore)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_recv(internal)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE bigistore (
    INPUT   = bigistore_in,
    OUTPUT  = bigistore_out,
    RECEIVE = bigistore_recv,
    SEND    = bigistore_send,
    STORAGE = EXTENDED
);

CREATE FUNCTION exist(bigistore, integer)
    RETURNS boolean
    AS '$libdir/istore.so', 'bigistore_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(bigistore, integer)
    RETURNS integer
    AS '$libdir/istore.so', 'bigistore_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION each(IN is bigistore,
    OUT key integer,
    OUT value bigint)
RETURNS SETOF record
AS '$libdir/istore.so','bigistore_each'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION add(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(bigistore, integer)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(bigistore, integer)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(bigistore, integer)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_divide'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(bigistore, integer)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_divide_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_from_array(integer[])
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_agg(bigistore[])
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_agg'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_agg_finalfn(internal)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_sum_up(bigistore)
    RETURNS bigint
    AS '$libdir/istore.so', 'bigistore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_array_add(integer[], integer[])
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(integer[], integer[])
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fill_gaps(bigistore, integer, integer DEFAULT 0)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_fill_gaps'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(bigistore, integer)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_seed(integer, integer, integer)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_val_larger(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_val_smaller(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

CREATE AGGREGATE MIN(bigistore) (
    sfunc = bigistore_val_smaller,
    stype = bigistore
);

CREATE AGGREGATE MAX(bigistore) (
    sfunc = bigistore_val_larger,
    stype = bigistore
);

CREATE OPERATOR -> (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = fetchval
);

CREATE OPERATOR ? (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = exist
);

CREATE OPERATOR + (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = add
);

CREATE OPERATOR + (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = add
);

CREATE OPERATOR - (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = subtract
);

CREATE OPERATOR - (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = subtract
);

CREATE OPERATOR * (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = multiply
);

CREATE OPERATOR * (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = multiply
);

CREATE OPERATOR / (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = divide
);

CREATE OPERATOR / (
    leftarg   = bigistore,
    rightarg  = integer,
    procedure = divide
);
