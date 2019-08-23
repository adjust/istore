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

CREATE FUNCTION min_key(istore)
    RETURNS integer
    AS 'istore', 'istore_min_key'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION max_key(istore)
    RETURNS integer
    AS 'istore', 'istore_max_key'
    LANGUAGE C IMMUTABLE STRICT;

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

CREATE FUNCTION concat(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_concat'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore(integer[])
    RETURNS istore
    AS 'istore', 'istore_from_intarray'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION sum_up(istore)
    RETURNS bigint
    AS 'istore', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION sum_up(istore, integer)
    RETURNS bigint
    AS 'istore', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore(integer[], integer[])
    RETURNS istore
    AS 'istore', 'istore_array_add'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION row_to_istore(record)
    RETURNS istore
    AS 'istore', 'row_to_istore'
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

CREATE FUNCTION istore_sum_transfn(internal, istore)
    RETURNS internal
    AS 'istore' ,'istore_sum_transfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_min_transfn(internal, istore)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_max_transfn(internal, istore)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_agg_finalfn_pairs(internal)
    RETURNS istore
    AS 'istore' ,'istore_agg_finalfn_pairs'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_json(istore)
    RETURNS json
    AS 'istore', 'istore_to_json'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_array(istore)
    RETURNS int[]
    AS 'istore', 'istore_to_array'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_to_matrix(istore)
    RETURNS int[]
    AS 'istore', 'istore_to_matrix'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION slice(istore, integer[])
    RETURNS istore
    AS 'istore', 'istore_slice'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION slice(istore, min integer, max integer)
    RETURNS istore
    AS 'istore', 'istore_slice_min_max'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION slice_array(istore, integer[])
    RETURNS integer[]
    AS 'istore', 'istore_slice_to_array'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION clamp_below(istore,int)
    RETURNS istore
    AS 'istore', 'istore_clamp_below'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION clamp_above(istore,int)
    RETURNS istore
    AS 'istore', 'istore_clamp_above'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION delete(istore,int)
    RETURNS istore
    AS 'istore', 'istore_delete'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION delete(istore,int[])
    RETURNS istore
    AS 'istore', 'istore_delete_array'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION exists_all(istore,integer[])
    RETURNS boolean
    AS 'istore', 'istore_exists_all'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION exists_any(istore,integer[])
    RETURNS boolean
    AS 'istore', 'istore_exists_any'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION delete(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_delete_istore'
    LANGUAGE C IMMUTABLE STRICT;

/*
    -- populate_record(record,hstore)
*/

CREATE FUNCTION bigistore_agg_finalfn(internal)
    RETURNS bigistore
    AS 'istore' ,'bigistore_agg_finalfn_pairs'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_avl_transfn(internal, int, int)
    RETURNS internal
    AS 'istore' ,'istore_avl_transfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_avl_finalfn(internal)
    RETURNS istore
    AS 'istore' ,'istore_avl_finalfn'
    LANGUAGE C IMMUTABLE;

CREATE FUNCTION istore_length(istore)
    RETURNS integer
    AS 'istore', 'istore_length'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_in_range(istore, int, int)
    RETURNS boolean
    AS 'istore', 'istore_in_range'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_less_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_less_than_or_equal(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_less_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_greater_than'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_greater_than_or_equal(istore, int)
    RETURNS boolean
    AS 'istore', 'istore_greater_than_or_equal'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_floor(istore, int)
    RETURNS istore
    AS 'istore', 'istore_floor'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_ceiling(istore, int)
    RETURNS istore
    AS 'istore', 'istore_ceiling'
    LANGUAGE C IMMUTABLE STRICT;

CREATE AGGREGATE SUM (
    sfunc = istore_sum_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = bigistore_agg_finalfn
);

CREATE AGGREGATE MIN (
    sfunc = istore_min_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn_pairs
);

CREATE AGGREGATE MAX (
    sfunc = istore_max_transfn,
    basetype = istore,
    stype = internal,
    finalfunc = istore_agg_finalfn_pairs
);

CREATE AGGREGATE ISAGG(int, int) (
    sfunc = istore_avl_transfn,
    stype = internal,
    finalfunc = istore_avl_finalfn
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


CREATE OPERATOR -> (
    leftarg   = istore,
    rightarg  = integer[],
    procedure = slice_array
);

CREATE OPERATOR %% (
    rightarg  = istore,
    procedure = istore_to_array
);

CREATE OPERATOR %# (
    rightarg  = istore,
    procedure = istore_to_matrix
);

CREATE OPERATOR ?& (
    leftarg   = istore,
    rightarg  = integer[],
    procedure = exists_all
);

CREATE OPERATOR ?| (
    leftarg   = istore,
    rightarg  = integer[],
    procedure = exists_any
);

CREATE OPERATOR || (
    leftarg   = istore,
    rightarg  = istore,
    procedure = concat
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
