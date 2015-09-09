-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION istore" to load this file. \quit
--source file sql/types.sql
CREATE FUNCTION istore_in(cstring)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_out(istore)
    RETURNS cstring
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_send(istore)
    RETURNS bytea
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_recv(internal)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE istore (
    INPUT   = istore_in,
    OUTPUT  = istore_out,
    RECEIVE = istore_recv,
    SEND    = istore_send,
    STORAGE = EXTENDED
);

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
 
--source file sql/istore.sql

CREATE FUNCTION exist(istore, integer)
    RETURNS boolean
    AS '$libdir/istore.so', 'istore_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(istore, integer)
    RETURNS integer
    AS '$libdir/istore.so', 'istore_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION each(IN is istore,
    OUT key integer,
    OUT value integer)
RETURNS SETOF record
AS '$libdir/istore.so','istore_each'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION add(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_divide'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_divide_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore(integer[])
    RETURNS istore
    AS '$libdir/istore.so', 'istore_from_intarray'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_agg_finalfn(internal)
    RETURNS bigistore
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

CREATE FUNCTION istore(integer[], integer[])
    RETURNS istore
    AS '$libdir/istore.so', 'istore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fill_gaps(istore, integer, integer DEFAULT 0)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_fill_gaps'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(istore)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(istore, integer)
    RETURNS istore
    AS '$libdir/istore.so', 'istore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_seed(integer, integer, integer)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_val_larger(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_val_smaller(istore, istore)
    RETURNS istore
    AS '$libdir/istore.so'
    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn
);

CREATE AGGREGATE MIN(istore) (
    sfunc = istore_val_smaller,
    stype = istore
);

CREATE AGGREGATE MAX(istore) (
    sfunc = istore_val_larger,
    stype = istore
);

CREATE OPERATOR -> (
    leftarg   = istore,
    rightarg  = integer,
    procedure = fetchval
);

CREATE OPERATOR ? (
    leftarg   = istore,
    rightarg  = integer,
    procedure = exist
);

CREATE OPERATOR + (
    leftarg   = istore,
    rightarg  = istore,
    procedure = add
);

CREATE OPERATOR + (
    leftarg   = istore,
    rightarg  = integer,
    procedure = add
);

CREATE OPERATOR - (
    leftarg   = istore,
    rightarg  = istore,
    procedure = subtract
);

CREATE OPERATOR - (
    leftarg   = istore,
    rightarg  = integer,
    procedure = subtract
);

CREATE OPERATOR * (
    leftarg   = istore,
    rightarg  = istore,
    procedure = multiply
);

CREATE OPERATOR * (
    leftarg   = istore,
    rightarg  = integer,
    procedure = multiply
);

CREATE OPERATOR / (
    leftarg   = istore,
    rightarg  = istore,
    procedure = divide
);

CREATE OPERATOR / (
    leftarg   = istore,
    rightarg  = integer,
    procedure = divide
);


CREATE FUNCTION gin_extract_istore_key(internal, internal)
RETURNS internal
AS '$libdir/istore.so'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION gin_extract_istore_key_query(internal, internal, int2, internal, internal)
RETURNS internal
AS '$libdir/istore.so'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION gin_consistent_istore_key(internal, int2, internal, int4, internal, internal)
RETURNS bool
AS '$libdir/istore.so'
LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS istore_key_ops
DEFAULT FOR TYPE istore USING gin
AS
    OPERATOR 9 ?(istore, integer),
    FUNCTION 1 btint4cmp(integer, integer),
    FUNCTION 2 gin_extract_istore_key(internal, internal),
    FUNCTION 3 gin_extract_istore_key_query(internal, internal, int2, internal, internal),
    FUNCTION 4 gin_consistent_istore_key(internal, int2, internal, int4, internal, internal),
    STORAGE  integer;
 
--source file sql/casts.sql

CREATE FUNCTION istore(bigistore)
    RETURNS istore
    AS '$libdir/istore.so', 'bigistore_to_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(istore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'istore_to_big_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (istore as bigistore) WITH FUNCTION bigistore(istore) AS IMPLICIT;
CREATE CAST (bigistore as istore) WITH FUNCTION istore(bigistore) AS ASSIGNMENT;
 
--source file sql/bigistore.sql

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

CREATE FUNCTION add(bigistore, bigint)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(bigistore, bigint)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(bigistore, bigint)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(bigistore, bigistore)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_divide'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(bigistore, bigint)
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_divide_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(integer[])
    RETURNS bigistore
    AS '$libdir/istore.so', 'bigistore_from_intarray'
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

CREATE FUNCTION fill_gaps(bigistore, integer, bigint DEFAULT 0)
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

CREATE FUNCTION bigistore_seed(integer, integer, bigint)
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
    rightarg  = bigint,
    procedure = add
);

CREATE OPERATOR - (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = subtract
);

CREATE OPERATOR - (
    leftarg   = bigistore,
    rightarg  = bigint,
    procedure = subtract
);

CREATE OPERATOR * (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = multiply
);

CREATE OPERATOR * (
    leftarg   = bigistore,
    rightarg  = bigint,
    procedure = multiply
);

CREATE OPERATOR / (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = divide
);

CREATE OPERATOR / (
    leftarg   = bigistore,
    rightarg  = bigint,
    procedure = divide
);
 
