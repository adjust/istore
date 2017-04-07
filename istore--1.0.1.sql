-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION istore" to load this file. \quit
--source file sql/types.sql
CREATE FUNCTION istore_in(cstring)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_out(istore)
    RETURNS cstring
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_send(istore)
    RETURNS bytea
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION istore_recv(internal)
    RETURNS istore
    AS 'istore'
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
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_out(bigistore)
    RETURNS cstring
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_send(bigistore)
    RETURNS bytea
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore_recv(internal)
    RETURNS bigistore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE bigistore (
    INPUT   = bigistore_in,
    OUTPUT  = bigistore_out,
    RECEIVE = bigistore_recv,
    SEND    = bigistore_send,
    STORAGE = EXTENDED
);
 
--source file sql/parallel_agg.sql
CREATE FUNCTION istore_serial(internal)
    RETURNS bytea
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_deserial(bytea, internal)
    RETURNS internal
    AS 'istore', 'istore_deserial'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_agg_combine(internal, internal)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;
 
--source file sql/casts.sql
--require types

CREATE FUNCTION istore(bigistore)
    RETURNS istore
    AS 'istore', 'bigistore_to_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION bigistore(istore)
    RETURNS bigistore
    AS 'istore', 'istore_to_big_istore'
    LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (istore as bigistore) WITH FUNCTION bigistore(istore) AS IMPLICIT;
CREATE CAST (bigistore as istore) WITH FUNCTION istore(bigistore) AS ASSIGNMENT;
 
--source file sql/istore.sql
--require types
--require parallel_agg

CREATE FUNCTION exist(istore, integer)
    RETURNS boolean
    AS 'istore', 'istore_exist'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION fetchval(istore, integer)
    RETURNS integer
    AS 'istore', 'istore_fetchval'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION each(IN is istore,
    OUT key integer,
    OUT value integer)
RETURNS SETOF record
AS 'istore','istore_each'
LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION compact(istore)
    RETURNS istore
    AS 'istore', 'istore_compact'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION add(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_add'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION add(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_add_integer'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION subtract(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_subtract'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION subtract(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_subtract_integer'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION multiply(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_multiply'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION multiply(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_multiply_integer'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION divide(istore, istore)
    RETURNS istore
    AS 'istore', 'istore_divide'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION divide(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_divide_integer'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore(integer[])
    RETURNS istore
    AS 'istore', 'istore_from_intarray'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_eq(istore, istore)
    RETURNS bool
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_ne(istore, istore)
    RETURNS bool
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sum_up(istore)
    RETURNS bigint
    AS 'istore', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sum_up(istore, integer)
    RETURNS bigint
    AS 'istore', 'istore_sum_up'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore(integer[], integer[])
    RETURNS istore
    AS 'istore', 'istore_array_add'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION fill_gaps(istore, integer, integer DEFAULT 0)
    RETURNS istore
    AS 'istore', 'istore_fill_gaps'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION accumulate(istore)
    RETURNS istore
    AS 'istore', 'istore_accumulate'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION accumulate(istore, integer)
    RETURNS istore
    AS 'istore', 'istore_accumulate'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_seed(integer, integer, integer)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_val_larger(istore, istore)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_val_smaller(istore, istore)
    RETURNS istore
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION akeys(istore)
    RETURNS integer[]
    AS 'istore' ,'istore_akeys'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION avals(istore)
    RETURNS integer[]
    AS 'istore' ,'istore_avals'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION skeys(istore)
    RETURNS setof int
    AS 'istore' ,'istore_skeys'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION svals(istore)
    RETURNS setof int
    AS 'istore' ,'istore_svals'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_sum_transfn(internal, istore)
    RETURNS internal
    AS 'istore' ,'istore_sum_transfn'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION istore_min_transfn(internal, istore)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION istore_max_transfn(internal, istore)
    RETURNS internal
    AS 'istore'
    LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE FUNCTION istore_agg_finalfn_pairs(internal)
    RETURNS istore
    AS 'istore' ,'istore_agg_finalfn_pairs'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION istore_to_json(istore)
RETURNS json
AS 'istore', 'istore_to_json'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION bigistore_agg_finalfn(internal)
    RETURNS bigistore
    AS 'istore' ,'bigistore_agg_finalfn_pairs'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE AGGREGATE SUM(istore) (
    sfunc = istore_sum_transfn,
    stype = internal,
    finalfunc = bigistore_agg_finalfn,
    combinefunc = istore_agg_combine,
    serialfunc = istore_serial,
    deserialfunc = istore_deserial,
    parallel = safe
);

CREATE AGGREGATE MIN(istore) (
    sfunc = istore_min_transfn,
    stype = internal,
    finalfunc = istore_agg_finalfn_pairs,
    combinefunc = istore_agg_combine,
    serialfunc = istore_serial,
    deserialfunc = istore_deserial,
    parallel = safe
);

CREATE AGGREGATE MAX(istore) (
    sfunc = istore_max_transfn,
    stype = internal,
    finalfunc = istore_agg_finalfn_pairs,
    combinefunc = istore_agg_combine,
    serialfunc = istore_serial,
    deserialfunc = istore_deserial,
    parallel = safe
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

CREATE OPERATOR = (
    leftarg    = istore,
    rightarg   = istore,
    commutator = =,
    negator    = <>,
    restrict   = eqsel,
    procedure  = istore_eq
);

CREATE OPERATOR <> (
    leftarg    = istore,
    rightarg   = istore,
    commutator = <>,
    negator    = =,
    restrict   = neqsel,
    procedure  = istore_ne
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
 
--source file sql/bigistore.sql
--require types
--require parallel_agg

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

CREATE FUNCTION bigistore_eq(bigistore, bigistore)
    RETURNS bool
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION bigistore_ne(bigistore, bigistore)
    RETURNS bool
    AS 'istore'
    LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

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

CREATE AGGREGATE SUM(bigistore) (
    sfunc = istore_sum_transfn,
    stype = internal,
    finalfunc = bigistore_agg_finalfn,
    combinefunc = istore_agg_combine,
    serialfunc = istore_serial,
    deserialfunc = istore_deserial,
    parallel = safe
);

CREATE AGGREGATE MIN(bigistore) (
    sfunc = istore_min_transfn,
    stype = internal,
    finalfunc = bigistore_agg_finalfn,
    combinefunc = istore_agg_combine,
    serialfunc = istore_serial,
    deserialfunc = istore_deserial,
    parallel = safe
);

CREATE AGGREGATE MAX(bigistore) (
    sfunc = istore_max_transfn,
    stype = internal,
    finalfunc = bigistore_agg_finalfn,
    combinefunc = istore_agg_combine,
    serialfunc = istore_serial,
    deserialfunc = istore_deserial,
    parallel = safe
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

CREATE OPERATOR = (
    leftarg    = bigistore,
    rightarg   = bigistore,
    commutator = =,
    negator    = <>,
    restrict   = eqsel,
    procedure  = bigistore_eq
);

CREATE OPERATOR <> (
    leftarg    = bigistore,
    rightarg   = bigistore,
    commutator = <>,
    negator    = =,
    restrict   = neqsel,
    procedure  = bigistore_ne
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
 
