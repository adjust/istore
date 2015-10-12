--require types

CREATE FUNCTION exist(istore, integer)
    RETURNS boolean
    AS 'istore', 'istore_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(istore, integer)
    RETURNS integer
    AS 'istore', 'istore_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION each(IN is istore,
    OUT key integer,
    OUT value integer)
RETURNS SETOF record
AS 'istore','istore_each'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION compact(istore)
    RETURNS istore
    AS 'istore', 'istore_compact'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_divide'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_divide_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore(integer[])
    RETURNS istore
    AS 'istore', 'istore_from_intarray'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_agg_finalfn(internal)
    RETURNS bigistore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION sum_up(istore)
    RETURNS bigint
    AS 'istore', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore(integer[], integer[])
    RETURNS istore
    AS 'istore', 'istore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fill_gaps(istore, integer, integer DEFAULT 0)
    RETURNS istore
    AS 'istore', 'istore_fill_gaps'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(istore)
    RETURNS istore
    AS 'istore', 'istore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_seed(integer, integer, integer)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_val_larger(istore, istore)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_val_smaller(istore, istore)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION akeys(istore)
    RETURNS integer[]
    AS 'istore' ,'istore_akeys'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION avals(istore)
    RETURNS integer[]
    AS 'istore' ,'istore_avals'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION skeys(istore)
    RETURNS setof int
    AS 'istore' ,'istore_skeys'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION svals(istore)
    RETURNS setof int
    AS 'istore' ,'istore_svals'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_json(istore)
RETURNS json
AS 'istore', 'istore_to_json'
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
AS 'istore'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION gin_extract_istore_key_query(internal, internal, int2, internal, internal)
RETURNS internal
AS 'istore'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION gin_consistent_istore_key(internal, int2, internal, int4, internal, internal)
RETURNS bool
AS 'istore'
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
