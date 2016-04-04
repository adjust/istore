--require types

CREATE FUNCTION exist(bigistore, integer)
    RETURNS boolean
    AS 'istore', 'bigistore_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(bigistore, integer)
    RETURNS integer
    AS 'istore', 'bigistore_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION each(IN is bigistore,
    OUT key integer,
    OUT value bigint)
RETURNS SETOF record
AS 'istore','bigistore_each'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION compact(bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_compact'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(bigistore, bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION add(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_add_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(bigistore, bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_subtract'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION subtract(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(bigistore, bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_multiply'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION multiply(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(bigistore, bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_divide'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION divide(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_divide_integer'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(integer[])
    RETURNS bigistore
    AS 'istore', 'bigistore_from_intarray'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_agg_finalfn(internal)
    RETURNS bigistore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION sum_up(bigistore)
    RETURNS bigint
    AS 'istore', 'bigistore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION sum_up(bigistore, integer)
    RETURNS bigint
    AS 'istore', 'bigistore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(integer[], integer[])
    RETURNS bigistore
    AS 'istore', 'bigistore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(integer[], bigint[])
    RETURNS bigistore
    AS 'istore', 'bigistore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore(integer[], bigint[])
    RETURNS bigistore
    AS 'istore', 'bigistore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fill_gaps(bigistore, integer, bigint DEFAULT 0)
    RETURNS bigistore
    AS 'istore', 'bigistore_fill_gaps'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION accumulate(bigistore, integer)
    RETURNS bigistore
    AS 'istore', 'bigistore_accumulate'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_seed(integer, integer, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_seed'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_val_larger(bigistore, bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_val_larger'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_val_smaller(bigistore, bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_val_smaller'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION akeys(bigistore)
    RETURNS integer[]
    AS 'istore' ,'bigistore_akeys'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION avals(bigistore)
    RETURNS bigint[]
    AS 'istore' ,'bigistore_avals'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION skeys(bigistore)
    RETURNS setof integer
    AS 'istore' ,'bigistore_skeys'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION svals(bigistore)
    RETURNS setof bigint
    AS 'istore' ,'bigistore_svals'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_json(bigistore)
RETURNS json
AS 'istore', 'bigistore_to_json'
LANGUAGE C IMMUTABLE STRICT;


CREATE AGGREGATE SUM (
    sfunc = array_agg_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

CREATE AGGREGATE MIN(bigistore) (
    sfunc = istore_val_smaller,
    stype = bigistore
);

CREATE AGGREGATE MAX(bigistore) (
    sfunc = istore_val_larger,
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

CREATE FUNCTION gin_extract_bigistore_key(internal, internal)
RETURNS internal
AS 'istore'
LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR CLASS bigistore_key_ops
DEFAULT FOR TYPE bigistore USING gin
AS
    OPERATOR 9 ?(bigistore, integer),
    FUNCTION 1 btint4cmp(integer, integer),
    FUNCTION 2 gin_extract_bigistore_key(internal, internal),
    FUNCTION 3 gin_extract_istore_key_query(internal, internal, int2, internal, internal),
    FUNCTION 4 gin_consistent_istore_key(internal, int2, internal, int4, internal, internal),
    STORAGE  integer;
