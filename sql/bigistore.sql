--require types
--require istore

CREATE FUNCTION exist(bigistore, integer)
    RETURNS boolean
    AS 'istore', 'bigistore_exist'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION fetchval(bigistore, integer)
    RETURNS bigint
    AS 'istore', 'bigistore_fetchval'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION each(IN is bigistore,
    OUT key integer,
    OUT value bigint)
RETURNS SETOF record
AS 'istore','bigistore_each'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION min_key(bigistore)
    RETURNS integer
    AS 'istore', 'bigistore_min_key'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION max_key(bigistore)
    RETURNS integer
    AS 'istore', 'bigistore_max_key'
    LANGUAGE C IMMUTABLE STRICT;

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

CREATE FUNCTION concat(bigistore, bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_concat'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(integer[])
    RETURNS bigistore
    AS 'istore', 'bigistore_from_intarray'
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

CREATE FUNCTION row_to_bigistore(record)
    RETURNS bigistore
    AS 'istore', 'row_to_bigistore'
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

CREATE FUNCTION istore_length(bigistore)
    RETURNS integer
    AS 'istore', 'bigistore_length'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_json(bigistore)
RETURNS json
AS 'istore', 'bigistore_to_json'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_array(bigistore)
    RETURNS int[]
    AS 'istore', 'bigistore_to_array'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_matrix(bigistore)
    RETURNS int[]
    AS 'istore', 'bigistore_to_matrix'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION slice(bigistore, integer[])
    RETURNS bigistore
    AS 'istore', 'bigistore_slice'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION slice(bigistore, min integer, max integer)
    RETURNS bigistore
    AS 'istore', 'bigistore_slice_min_max'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION slice_array(bigistore, integer[])
    RETURNS integer[]
    AS 'istore', 'bigistore_slice_to_array'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION clamp_below(bigistore,int)
    RETURNS bigistore
    AS 'istore', 'bigistore_clamp_below'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION clamp_above(bigistore,int)
    RETURNS bigistore
    AS 'istore', 'bigistore_clamp_above'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION delete(bigistore,int)
    RETURNS bigistore
    AS 'istore', 'bigistore_delete'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION delete(bigistore,int[])
    RETURNS bigistore
    AS 'istore', 'bigistore_delete_array'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION exists_all(bigistore,integer[])
    RETURNS boolean
    AS 'istore', 'bigistore_exists_all'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION exists_any(bigistore,integer[])
    RETURNS boolean
    AS 'istore', 'bigistore_exists_any'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION delete(bigistore,bigistore)
    RETURNS bigistore
    AS 'istore', 'bigistore_delete_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_sum_transfn(internal, bigistore)
    RETURNS internal
    AS 'istore' ,'bigistore_sum_transfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_min_transfn(internal, bigistore)
    RETURNS internal
    AS 'istore' ,'bigistore_min_transfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_max_transfn(internal, bigistore)
    RETURNS internal
    AS 'istore' ,'bigistore_max_transfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION bigistore_avl_transfn(internal, int, bigint)
    RETURNS internal
    AS 'istore' ,'bigistore_avl_transfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION bigistore_avl_finalfn(internal)
    RETURNS bigistore
    AS 'istore' ,'bigistore_avl_finalfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_in_range(bigistore, bigint, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_in_range'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_less_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than_or_equal(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_less_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_greater_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than_or_equal(bigistore, bigint)
    RETURNS boolean
    AS 'istore', 'bigistore_greater_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_floor(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_floor'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_ceiling(bigistore, bigint)
    RETURNS bigistore
    AS 'istore', 'bigistore_ceiling'
    LANGUAGE C IMMUTABLE STRICT;


CREATE AGGREGATE SUM (
    sfunc = istore_sum_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

CREATE AGGREGATE MIN (
    sfunc = istore_min_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

CREATE AGGREGATE MAX (
    sfunc = istore_max_transfn,
    basetype = bigistore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

CREATE AGGREGATE ISAGG(int, bigint) (
    sfunc = bigistore_avl_transfn,
    stype = internal,
    finalfunc = bigistore_avl_finalfn
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

CREATE OPERATOR -> (
    leftarg   = bigistore,
    rightarg  = integer[],
    procedure = slice_array
);

CREATE OPERATOR %% (
    rightarg  = bigistore,
    procedure = istore_to_array
);

CREATE OPERATOR %# (
    rightarg  = bigistore,
    procedure = istore_to_matrix
);

CREATE OPERATOR ?& (
    leftarg   = bigistore,
    rightarg  = integer[],
    procedure = exists_all
);

CREATE OPERATOR ?| (
    leftarg   = bigistore,
    rightarg  = integer[],
    procedure = exists_any
);

CREATE OPERATOR || (
    leftarg   = bigistore,
    rightarg  = bigistore,
    procedure = concat
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
